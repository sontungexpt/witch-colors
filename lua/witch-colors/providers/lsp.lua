--- LSP document color provider.
---
--- Discovers colors through textDocument/documentColor and converts
--- LSP color ranges into Witch Colors normalized results.
---
--- Features:
---   - Multiple LSP client support
---   - Asynchronous document color requests
---   - Per-buffer result caching
---   - Stale response protection
---   - UTF-8, UTF-16, and UTF-32 position encoding support
---   - RGB and RGBA color conversion
---   - Duplicate result elimination
---   - Shared normalized result format
---
--- Result format:
--- {
---     color = integer,
---     row = integer,
---     col_start = integer,
---     col_end = integer,
---     source = "lsp",
--- }
---
--- Public API:
---   attach(buffer, callback)
---   refresh(buffer)
---   get_results(buffer)
---   detach(buffer)

local type = type
local pairs = pairs
local sort = table.sort

local api = vim.api
local lsp = vim.lsp
local huge = math.huge

local nvim_buf_is_valid = api.nvim_buf_is_valid
local nvim_buf_get_lines = api.nvim_buf_get_lines

local converters = require("witch-colors.util.converters")
local rgb_to_marked = converters.rgb_to_marked
local rgba_to_marked = converters.rgba_to_marked

local DOCUMENT_COLOR_METHOD = "textDocument/documentColor"
local DEFAULT_ENCODING = "utf-16"

---@class witch-colors.ColorResult
---@field color integer
---@field row integer
---@field col_start integer
---@field col_end integer
---@field source? string

---@class witch-colors.LspBufferState
---@field callback fun(results: witch-colors.ColorResult[])?
---@field generation integer
---@field results witch-colors.ColorResult[]
---@field clients table<integer, witch-colors.ColorResult[]>
---@field client_order integer[]

---@class witch-colors.LspProvider
local M = {}

---@type table<integer, witch-colors.LspBufferState>
local buffers = {}

-- ============================================================================
-- Position conversion
-- ============================================================================

---Return the UTF-8 byte length of the codepoint beginning at `index`.
---
---Neovim buffer lines are expected to contain valid UTF-8.
---
---@param line string
---@param index integer
---@return integer
local function utf8_char_length(line, index)
    local byte = line:byte(index)

    if byte == nil or byte < 0x80 then
        return 1
    end

    if byte >= 0xC2 and byte <= 0xDF then
        return 2
    end

    if byte >= 0xE0 and byte <= 0xEF then
        return 3
    end

    if byte >= 0xF0 and byte <= 0xF4 then
        return 4
    end

    return 1
end

---Convert an LSP character offset into a UTF-8 byte offset.
---
---LSP positions may use UTF-8, UTF-16, or UTF-32 encoding.
---Neovim buffer APIs require byte-based columns.
---
---Returns nil when the requested offset is invalid or falls inside
---a multi-byte UTF-8 character or UTF-16 surrogate pair.
---
---@param line string
---@param character integer
---@param encoding string
---@return integer|nil byte_index
local function character_to_byte(line, character, encoding)
    if type(character) ~= "number"
        or character < 0
        or character % 1 ~= 0
    then
        return nil
    end

    if character == 0 then
        return 0
    end

    local byte_index = 1
    local character_index = 0
    local byte_length = #line

    while byte_index <= byte_length do
        if character_index == character then
            return byte_index - 1
        end

        local char_length = utf8_char_length(line, byte_index)

        if byte_index + char_length - 1 > byte_length then
            char_length = 1
        end

        local next_character_index

        if encoding == "utf-8" then
            next_character_index = character_index + char_length
        elseif encoding == "utf-32" then
            next_character_index = character_index + 1
        else
            -- UTF-16 represents supplementary codepoints with two code units.
            next_character_index = character_index
                + (char_length == 4 and 2 or 1)
        end

        if next_character_index > character then
            return nil
        end

        character_index = next_character_index
        byte_index = byte_index + char_length
    end

    if character_index == character then
        return byte_length
    end

    return nil
end

---Convert an LSP position into a normalized row and byte column.
---
---@param buffer integer
---@param position table
---@param encoding string
---@return integer|nil row
---@return integer|nil column
local function convert_position(buffer, position, encoding)
    if type(position) ~= "table" then
        return nil, nil
    end

    local row = position.line

    if type(row) ~= "number"
        or row < 0
        or row % 1 ~= 0
    then
        return nil, nil
    end

    local line = nvim_buf_get_lines(buffer, row, row + 1, false)[1]

    if line == nil then
        return nil, nil
    end

    local column = character_to_byte(
        line,
        position.character,
        encoding
    )

    if column == nil then
        return nil, nil
    end

    return row, column
end

-- ============================================================================
-- Color conversion
-- ============================================================================

---Check whether a number is finite.
---
---@param value any
---@return boolean
local function is_finite_number(value)
    return type(value) == "number"
        and value == value
        and value ~= huge
        and value ~= -huge
end

---Convert an LSP Color object into a Witch Colors marked color.
---
---LSP RGB and alpha components are normalized to [0, 1].
---The converters handle channel clamping and rounding.
---
---@param color table
---@return integer|nil
local function convert_color(color)
    if type(color) ~= "table" then
        return nil
    end

    local red = color.red
    local green = color.green
    local blue = color.blue

    if not is_finite_number(red)
        or not is_finite_number(green)
        or not is_finite_number(blue)
    then
        return nil
    end

    local r = red * 255
    local g = green * 255
    local b = blue * 255

    local alpha = color.alpha

    -- Treat a missing alpha component as fully opaque.
    if alpha == nil then
        alpha = 1
    elseif not is_finite_number(alpha) then
        return nil
    end

    if alpha >= 1 then
        return rgb_to_marked(r, g, b)
    end

    return rgba_to_marked(r, g, b, alpha * 255)
end

-- ============================================================================
-- Result conversion
-- ============================================================================

---Convert one LSP ColorInformation result.
---
---@param buffer integer
---@param match table
---@param encoding string
---@return witch-colors.ColorResult|nil
local function convert_match(buffer, match, encoding)
    if type(match) ~= "table" then
        return nil
    end

    local range = match.range

    if type(range) ~= "table"
        or type(range.start) ~= "table"
        or type(range["end"]) ~= "table"
    then
        return nil
    end

    local start_position = range.start
    local end_position = range["end"]

    if start_position.line ~= end_position.line then
        return nil
    end

    local color = convert_color(match.color)

    if color == nil then
        return nil
    end

    local row, start_column = convert_position(
        buffer,
        start_position,
        encoding
    )

    if row == nil then
        return nil
    end

    local end_row, end_column = convert_position(
        buffer,
        end_position,
        encoding
    )

    if end_row ~= row or end_column == nil then
        return nil
    end

    if end_column <= start_column then
        return nil
    end

    return {
        color = color,
        row = row,
        col_start = start_column,
        col_end = end_column,
        source = "lsp",
    }
end

---Convert an entire LSP document color response.
---
---@param buffer integer
---@param response table
---@param encoding string
---@return witch-colors.ColorResult[]
local function convert_response(buffer, response, encoding)
    local results = {}

    if type(response) ~= "table" then
        return results
    end

    for i = 1, #response do
        local result = convert_match(buffer, response[i], encoding)

        if result ~= nil then
            results[#results + 1] = result
        end
    end

    return results
end

-- ============================================================================
-- Buffer state
-- ============================================================================

---Get or create buffer state.
---
---@param buffer integer
---@return witch-colors.LspBufferState
local function get_state(buffer)
    local state = buffers[buffer]

    if state == nil then
        state = {
            generation = 0,
            results = {},
            clients = {},
            client_order = {},
        }

        buffers[buffer] = state
    end

    return state
end

---Merge results from all LSP clients.
---
---Deduplicates identical ranges and colors.
---Client order is preserved to make merging deterministic.
---
---@param client_results table<integer, witch-colors.ColorResult[]>
---@param client_order integer[]
---@return witch-colors.ColorResult[]
local function merge_results(client_results, client_order)
    local results = {}
    local seen = {}

    for i = 1, #client_order do
        local client_result = client_results[client_order[i]]

        if client_result ~= nil then
            for j = 1, #client_result do
                local result = client_result[j]

                local key = result.row
                    .. ":"
                    .. result.col_start
                    .. ":"
                    .. result.col_end
                    .. ":"
                    .. result.color

                if not seen[key] then
                    seen[key] = true
                    results[#results + 1] = result
                end
            end
        end
    end

    sort(results, function(a, b)
        if a.row ~= b.row then
            return a.row < b.row
        end

        if a.col_start ~= b.col_start then
            return a.col_start < b.col_start
        end

        if a.col_end ~= b.col_end then
            return a.col_end < b.col_end
        end

        return a.color < b.color
    end)

    return results
end

---Publish the current result set to the registered callback.
---
---@param state witch-colors.LspBufferState
local function publish_results(state)
    local results = merge_results(
        state.clients,
        state.client_order
    )

    state.results = results

    if state.callback then
        state.callback(results)
    end
end

-- ============================================================================
-- LSP client access
-- ============================================================================

---Get clients attached to a buffer that support document colors.
---
---The method filter uses Neovim's current LSP client capability handling,
---including dynamically registered capabilities.
---
---@param buffer integer
---@return vim.lsp.Client[]
local function get_document_color_clients(buffer)
    return lsp.get_clients({
        bufnr = buffer,
        method = DOCUMENT_COLOR_METHOD,
    })
end

-- ============================================================================
-- Public API
-- ============================================================================

---Attach the LSP provider to a buffer.
---
---Registers the callback and immediately requests document colors.
---
---@param buffer integer
---@param callback fun(results: witch-colors.ColorResult[])
function M.attach(buffer, callback)
    if not nvim_buf_is_valid(buffer) then
        return
    end

    local state = get_state(buffer)

    state.callback = callback

    M.refresh(buffer)
end

---Refresh document colors for a buffer.
---
---Every refresh creates a new generation. Responses from older requests
---are ignored to prevent stale results from overwriting newer results.
---
---@param buffer integer
function M.refresh(buffer)
    if not nvim_buf_is_valid(buffer) then
        return
    end

    local state = get_state(buffer)

    state.generation = state.generation + 1

    local generation = state.generation

    -- Discard previous results before collecting fresh responses.
    state.clients = {}
    state.client_order = {}

    local clients = get_document_color_clients(buffer)
    local client_count = #clients

    if client_count == 0 then
        publish_results(state)
        return
    end

    local params = lsp.util.make_text_document_params(buffer)
    local pending = client_count
    local completed = {}

    for i = 1, client_count do
        local client = clients[i]
        state.client_order[i] = client.id
    end

    ---Complete one client's request exactly once.
    ---
    ---@param client vim.lsp.Client
    ---@param response table?
    local function complete_request(client, response)
        local client_id = client.id

        if completed[client_id] then
            return
        end

        completed[client_id] = true

        if buffers[buffer] ~= state
            or state.generation ~= generation
            or not nvim_buf_is_valid(buffer)
        then
            return
        end

        local client_results = {}

        if type(response) == "table" then
            client_results = convert_response(
                buffer,
                response,
                client.offset_encoding or DEFAULT_ENCODING
            )
        end

        state.clients[client_id] = client_results

        pending = pending - 1

        if pending == 0 then
            publish_results(state)
        end
    end

    for i = 1, client_count do
        local client = clients[i]

        -- Current Neovim API:
        --   success, request_id = client:request(...)
        local ok, success = pcall(
            client.request,
            client,
            DOCUMENT_COLOR_METHOD,
            params,
            function(err, response)
                if err ~= nil then
                    complete_request(client, nil)
                    return
                end

                complete_request(client, response)
            end,
            buffer
        )

        -- A failed request may never invoke its callback.
        if not ok or not success then
            complete_request(client, nil)
        end
    end
end

---Get the cached document color results for a buffer.
---
---@param buffer integer
---@return witch-colors.ColorResult[]
function M.get_results(buffer)
    local state = buffers[buffer]

    return state and state.results or {}
end

---Detach the LSP provider from a buffer and clear its cache.
---
---Outstanding asynchronous responses are invalidated by incrementing
---the generation before removing the buffer state.
---
---@param buffer integer
function M.detach(buffer)
    local state = buffers[buffer]

    if state == nil then
        return
    end

    state.generation = state.generation + 1
    buffers[buffer] = nil
end

return M
