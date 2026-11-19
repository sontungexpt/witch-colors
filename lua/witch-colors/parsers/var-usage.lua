--- CSS custom property usage source.
---
--- Resolves `var(--name)` by searching custom property declarations
--- in loaded buffers.
---
--- Supported:
---   - var(--name)
---   - #RGB, #RGBA, #RRGGBB, #RRGGBBAA
---   - CSS named colors
---   - rgb(), rgba(), hsl(), hsla()
---   - Legacy comma-separated syntax
---   - Modern space-separated syntax with optional alpha
---   - Multiline declarations
---
--- Not supported:
---   - Fallback values
---   - Nested var()
---   - calc() and relative colors
---   - CSS cascade and selector specificity

local vim = vim

local str_match = string.match
local str_sub = string.sub
local str_lower = string.lower
local str_byte = string.byte
local str_find = string.find
local str_gsub = string.gsub
local concat = table.concat

local tonumber = tonumber
local min, max = math.min, math.max
local floor = math.floor
local HUGE = math.huge

local converters = require("witch-colors.util.converters")
local rgb_to_marked = converters.rgb_to_marked
local rgba_to_marked = converters.rgba_to_marked
local hsl_to_marked = converters.hsl_to_marked

local PALETTE = require("witch-colors.palette.css")

-- ============================================================================
-- Constants
-- ============================================================================

local VAR_USAGE_PATTERN = "var%(%s*%-%-[%w_-]+%s*%)"

local util = require("witch-colors.parsers.shared.util")

local PLUS = 43
local MINUS = 45
local DOT = 46
local ZERO = 48
local NINE = 57
local PERCENT = 37
local COMMA = 44
local SLASH = 47
local OPEN = 40
local CLOSE = 41
local SEMICOLON = 59
local COLON = 58
local RBRACE = 125
local LBRACE = 123

local QUOTE_SINGLE = 39
local QUOTE_DOUBLE = 34
local BACKSLASH = 92

-- ============================================================================
-- Helpers
-- ============================================================================

---@param byte integer|nil
---@return boolean
local function is_digit(byte)
    return byte ~= nil and byte >= ZERO and byte <= NINE
end

---@param byte integer|nil
---@return boolean
local function is_ident(byte)
    return is_digit(byte)
        or (byte ~= nil and byte >= 65 and byte <= 90)
        or (byte ~= nil and byte >= 97 and byte <= 122)
        or byte == MINUS
        or byte == 95
end

---@param value string
---@return string
local function trim(value)
    return str_match(value, "^%s*(.-)%s*$") or ""
end

---@param value string
---@return string
local function remove_comments(value)
    return str_gsub(value, "/%*.-%*/", " ")
end

-- ============================================================================
-- Number parsing
-- ============================================================================

---@param value string
---@param pos integer
---@return number|nil
---@return integer
local function read_number(value, pos)
    local len = #value
    local start = pos
    local byte = str_byte(value, pos)

    if byte == PLUS or byte == MINUS then
        pos = pos + 1
    end

    local digits = 0

    while pos <= len and is_digit(str_byte(value, pos)) do
        digits = digits + 1
        pos = pos + 1
    end

    if str_byte(value, pos) == DOT then
        pos = pos + 1

        while pos <= len and is_digit(str_byte(value, pos)) do
            digits = digits + 1
            pos = pos + 1
        end
    end

    if digits == 0 then
        return nil, start
    end

    local number = tonumber(str_sub(value, start, pos - 1))

    if number == nil
        or number ~= number
        or number == HUGE
        or number == -HUGE
    then
        return nil, start
    end

    return number, pos
end

---@param value string
---@return number|nil
---@return boolean
local function parse_channel(value)
    local number, pos = read_number(value, 1)

    if number == nil then
        return nil, false
    end

    local percentage = str_byte(value, pos) == PERCENT

    if percentage then
        pos = pos + 1
    end

    if pos <= #value then
        return nil, false
    end

    return number, percentage
end

---@param value string
---@return number|nil
local function parse_alpha(value)
    local number, percentage = parse_channel(value)

    if number == nil then
        return nil
    end

    if percentage then
        number = number / 100
    end

    return min(1, max(0, number))
end

-- ============================================================================
-- Hex colors
-- ============================================================================

---@param value string
---@return integer|nil
local function parse_hex(value)
    local len = #value

    if str_byte(value, 1) ~= 35 then
        return nil
    end

    local r, g, b, a = 0, 0, 0, 255

    if len == 4 or len == 5 then
        local rn = tonumber(str_sub(value, 2, 2), 16)
        local gn = tonumber(str_sub(value, 3, 3), 16)
        local bn = tonumber(str_sub(value, 4, 4), 16)

        if rn == nil or gn == nil or bn == nil then
            return nil
        end

        r = rn * 17
        g = gn * 17
        b = bn * 17

        if len == 5 then
            local an = tonumber(str_sub(value, 5, 5), 16)

            if an == nil then
                return nil
            end

            a = an * 17
        end
    elseif len == 7 or len == 9 then
        r = tonumber(str_sub(value, 2, 3), 16)
        g = tonumber(str_sub(value, 4, 5), 16)
        b = tonumber(str_sub(value, 6, 7), 16)

        if r == nil or g == nil or b == nil then
            return nil
        end

        if len == 9 then
            a = tonumber(str_sub(value, 8, 9), 16)

            if a == nil then
                return nil
            end
        end
    else
        return nil
    end

    if a == 255 then
        return rgb_to_marked(r, g, b)
    end

    return rgba_to_marked(r, g, b, a)
end

-- ============================================================================
-- Hue parsing
-- ============================================================================

---@param token string
---@return number|nil
local function parse_hue(token)
    token = str_lower(trim(token))

    if token == "none" then
        return 0
    end

    local value, unit = str_match(
        token,
        "^([+-]?%d*%.?%d+)([%a]*)$"
    )

    if not value then
        return nil
    end

    value = tonumber(value)

    if value == nil
        or value ~= value
        or value == HUGE
        or value == -HUGE
    then
        return nil
    end

    if unit == "" or unit == "deg" then
        return value
    elseif unit == "grad" then
        return value * 0.9
    elseif unit == "rad" then
        return value * (180 / math.pi)
    elseif unit == "turn" then
        return value * 360
    end

    return nil
end

-- ============================================================================
-- Function arguments
-- ============================================================================

---@param body string
---@return table
---@return boolean
local function split_arguments(body)
    local parts = {}
    local count = 0
    local comma_mode = str_find(body, ",", 1, true) ~= nil

    local start = 1
    local pos = 1
    local len = #body

    while pos <= len do
        local byte = str_byte(body, pos)

        if byte == COMMA or byte == SLASH or util.is_space(byte) then
            local token = trim(str_sub(body, start, pos - 1))

            if token ~= "" then
                count = count + 1
                parts[count] = token
            end

            if byte == SLASH then
                count = count + 1
                parts[count] = "/"
            end

            pos = pos + 1

            if byte ~= COMMA and byte ~= SLASH then
                pos = util.skip_space(body, pos)
            end

            start = pos
        else
            pos = pos + 1
        end
    end

    local token = trim(str_sub(body, start))

    if token ~= "" then
        count = count + 1
        parts[count] = token
    end

    return parts, comma_mode
end

-- ============================================================================
-- RGB
-- ============================================================================

---@param value string
---@return number|nil
local function parse_rgb_component(value)
    local number, percentage = parse_channel(value)

    if number == nil then
        return nil
    end

    if percentage then
        return number / 100 * 255
    end

    return number
end

---@param r number
---@param g number
---@param b number
---@param alpha number|nil
---@return integer
local function rgb_to_color(r, g, b, alpha)
    r = floor(min(255, max(0, r)) + 0.5)
    g = floor(min(255, max(0, g)) + 0.5)
    b = floor(min(255, max(0, b)) + 0.5)

    if alpha == nil then
        return rgb_to_marked(r, g, b)
    end

    local a = floor(min(1, max(0, alpha)) * 255 + 0.5)

    return rgba_to_marked(r, g, b, a)
end

---@param parts table
---@param comma_mode boolean
---@return number|nil
---@return number|nil
---@return number|nil
---@return number|nil
local function parse_rgb_channels(parts, comma_mode)
    if comma_mode then
        if #parts ~= 3 and #parts ~= 4 then
            return nil, nil, nil, nil
        end
    else
        if #parts ~= 3 and #parts ~= 5 then
            return nil, nil, nil, nil
        end

        if #parts == 5 and parts[4] ~= "/" then
            return nil, nil, nil, nil
        end
    end

    local r = parse_rgb_component(parts[1])
    local g = parse_rgb_component(parts[2])
    local b = parse_rgb_component(parts[3])

    if r == nil or g == nil or b == nil then
        return nil, nil, nil, nil
    end

    local alpha

    if comma_mode and #parts == 4 then
        alpha = parse_alpha(parts[4])
    elseif not comma_mode and #parts == 5 then
        alpha = parse_alpha(parts[5])
    end

    if (comma_mode and #parts == 4)
        or (not comma_mode and #parts == 5)
    then
        if alpha == nil then
            return nil, nil, nil, nil
        end
    end

    return r, g, b, alpha
end

-- ============================================================================
-- HSL
-- ============================================================================

---@param parts table
---@param comma_mode boolean
---@return number|nil
---@return number|nil
---@return number|nil
---@return number|nil
local function parse_hsl_channels(parts, comma_mode)
    if comma_mode then
        if #parts ~= 3 and #parts ~= 4 then
            return nil, nil, nil, nil
        end
    else
        if #parts ~= 3 and #parts ~= 5 then
            return nil, nil, nil, nil
        end

        if #parts == 5 and parts[4] ~= "/" then
            return nil, nil, nil, nil
        end
    end

    local h = parse_hue(parts[1])
    local s, sp = parse_channel(parts[2])
    local l, lp = parse_channel(parts[3])

    if h == nil or s == nil or l == nil then
        return nil, nil, nil, nil
    end

    if not sp or not lp then
        return nil, nil, nil, nil
    end

    local alpha

    if comma_mode and #parts == 4 then
        alpha = parse_alpha(parts[4])
    elseif not comma_mode and #parts == 5 then
        alpha = parse_alpha(parts[5])
    end

    if (comma_mode and #parts == 4)
        or (not comma_mode and #parts == 5)
    then
        if alpha == nil then
            return nil, nil, nil, nil
        end
    end

    return h % 360, s, l, alpha
end

-- ============================================================================
-- Color resolution
-- ============================================================================

---@param value string
---@return integer|nil
local function resolve_color_value(value)
    value = trim(value)

    if value == "" then
        return nil
    end

    local lower = str_lower(value)

    -- Hex.
    if str_byte(lower, 1) == 35 then
        return parse_hex(lower)
    end

    -- Named colors.
    local named = PALETTE[lower]

    if named ~= nil then
        return named
    end

    -- Functional colors.
    local name, body = str_match(lower, "^([%a]+)%((.*)%)$")

    if not name or not body or str_find(body, "[()]") then
        return nil
    end

    local parts, comma_mode = split_arguments(body)

    if name == "rgb" or name == "rgba" then
        local r, g, b, alpha = parse_rgb_channels(parts, comma_mode)

        if r == nil then
            return nil
        end

        return rgb_to_color(r, g, b, alpha)
    end

    if name == "hsl" or name == "hsla" then
        local h, s, l, alpha = parse_hsl_channels(parts, comma_mode)

        if h == nil then
            return nil
        end

        return hsl_to_marked(h, s, l, alpha)
    end

    return nil
end

-- ============================================================================
-- Custom property lookup
-- ============================================================================

---@param value string
---@return string|nil
local function extract_var_name(value)
    if type(value) ~= "string" then
        return nil
    end

    return str_match(value, "var%(%s*(%-%-[%w_-]+)%s*%)")
end

---Read a declaration value until its top-level terminator.
---Handles multiline values, parentheses, and quoted strings.
---@param text string
---@param pos integer
---@return string
---@return integer
---@return integer|nil
local function read_declaration_value(text, pos)
    local start = pos
    local depth = 0
    local quote = nil
    local escaped = false
    local len = #text

    while pos <= len do
        local byte = str_byte(text, pos)

        if quote then
            if escaped then
                escaped = false
            elseif byte == BACKSLASH then
                escaped = true
            elseif byte == quote then
                quote = nil
            end
        elseif byte == QUOTE_SINGLE or byte == QUOTE_DOUBLE then
            quote = byte
        elseif byte == OPEN then
            depth = depth + 1
        elseif byte == CLOSE then
            if depth == 0 then
                break
            end

            depth = depth - 1
        elseif depth == 0 and (byte == SEMICOLON or byte == RBRACE) then
            break
        end

        pos = pos + 1
    end

    return trim(str_sub(text, start, pos - 1)), pos, str_byte(text, pos)
end

---Find the next custom property declaration.
---@param text string
---@param var_name string
---@param search_pos integer
---@return integer|nil
local function find_declaration(text, var_name, search_pos)
    local len = #text
    local name_len = #var_name
    local depth = 0
    local quote = nil
    local escaped = false
    local segment_start = 1

    for pos = 1, len do
        local byte = str_byte(text, pos)

        if quote then
            if escaped then
                escaped = false
            elseif byte == BACKSLASH then
                escaped = true
            elseif byte == quote then
                quote = nil
            end
        elseif byte == QUOTE_SINGLE or byte == QUOTE_DOUBLE then
            quote = byte
        elseif byte == LBRACE then
            depth = depth + 1
            segment_start = pos + 1
        elseif byte == RBRACE then
            depth = max(0, depth - 1)
            segment_start = pos + 1
        elseif byte == SEMICOLON and depth > 0 then
            segment_start = pos + 1
        elseif depth > 0
            and pos >= search_pos
            and byte == MINUS
            and str_sub(text, pos, pos + name_len - 1) == var_name
        then
            local valid_start = true

            for i = segment_start, pos - 1 do
                if not util.is_space(str_byte(text, i)) then
                    valid_start = false
                    break
                end
            end

            if valid_start then
                local end_pos = pos + name_len

                if not is_ident(str_byte(text, end_pos)) then
                    local colon_pos = util.skip_space(text, end_pos)

                    if str_byte(text, colon_pos) == COLON then
                        return colon_pos + 1
                    end
                end
            end
        end
    end

    return nil
end

---Resolve a custom property from loaded buffers.
---@param var_name string
---@return integer|nil
local function resolve_var_declaration(var_name)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr)
            and vim.api.nvim_buf_is_loaded(bufnr)
        then
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local text = remove_comments(concat(lines, "\n"))

            local search_pos = 1

            while search_pos <= #text do
                local value_start = find_declaration(
                    text,
                    var_name,
                    search_pos
                )

                if not value_start then
                    break
                end

                local value, terminator_pos, terminator =
                    read_declaration_value(text, value_start)

                local color = resolve_color_value(value)

                if color ~= nil then
                    return color
                end

                if terminator == RBRACE then
                    search_pos = terminator_pos
                else
                    search_pos = terminator_pos + 1
                end
            end
        end
    end

    return nil
end

-- ============================================================================
-- Source
-- ============================================================================

---@type witch-colors.Parser
return {
    pattern = {
        VAR_USAGE_PATTERN,
    },

    resolve = function(_parser, match, _bufnr, _row)
        if type(match) ~= "table" or type(match.value) ~= "string" then
            return nil
        end

        local var_name = extract_var_name(match.value)

        if not var_name then
            return nil
        end

        local color = resolve_var_declaration(var_name)

        if color == nil then
            return nil
        end

        return {
            color = color,
            col_start = match.col_start,
            col_end = match.col_end,
        }
    end,
}
