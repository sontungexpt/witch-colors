local type, pairs, next = type, pairs, next
local getmetatable, setmetatable = getmetatable, setmetatable
local str_find, str_sub = string.find, string.sub

local vim = vim
local api, fn = vim.api, vim.fn

local M = {}

--- Lazy load renderer module
local Renderer = {}
setmetatable(Renderer, {
    __index = function(t, k)
        Renderer = require("witch-colors.renderer")
        return Renderer[k]
    end,
})

local Config = require("witch-colors.config")
local is_excluded = Config.is_excluded
local config = Config.current

local active = false
local augroup


local DEBOUNCE_MS = 30


--- Resolve missing parser fields from a lazily loaded module.
---
--- Loads the module on first access and replaces the lazy resolver
--- with the loaded module in the parser's metatable.
---
--- @param parser witch-colors.Parser
--- @param key any
--- @return any
local function lazy_parser_index(parser, key)
    local path = parser.path
    --- Recheck to ensure the path is still existing to avoid user change this value after the parser is loaded.
    if not path then return nil end

    local module = require(path)

    if not module then
        return nil
    end

    --- Update the metatable to let the parser resolve lazy fields directly from the module.
    local mt = getmetatable(parser)
    mt.__index = module

    --- Protect the metatable from being modified after the module is loaded.
    mt.__metatable = path
    return module[key]
end

--- Enable lazy loading for a parser's implementation fields.
---
--- Attaches a metatable that loads the parser module on first field access.
--- Parsers without a lazy path or with an existing metatable are returned unchanged.
---
--- @param parser witch-colors.Parser
--- @return witch-colors.Parser
local function lazy_parser(parser)
    if parser.path and not getmetatable(parser) then
        return setmetatable(parser, {
            __index = lazy_parser_index,
        })
    end
    return parser
end

--- Get enabled parsers sorted by ascending priority.
---
--- @param bufnr integer
--- @return witch-colors.Parser[] parsers
--- @return integer count
local function enabled_parsers(bufnr)
    local result = {}
    local count = 0

    local parsers = config.parsers
    for _, parser in pairs(parsers) do
        local enabled = parser.enabled

        if enabled == true or (type(enabled) == "function" and enabled(bufnr)) then
            count = count + 1

            local priority = parser.priority or 999
            local pos = count

            while pos > 1 and (result[pos - 1].priority or 999) > priority do
                result[pos] = result[pos - 1]
                pos = pos - 1
            end

            result[pos] = lazy_parser(parser)
        end
    end

    return result, count
end


--- Finds all non-empty matches of the given Lua patterns in `str`.
--- @param str string
--- @param patterns string[]
--- @return witch-colors.PatternMatch[] matches
--- @return integer count
local function collect_matches(str, patterns)
    local matches, count = {}, 0
    local str_len = #str

    if str_len == 0 then
        return matches, count
    end

    for i = 1, #patterns do
        local pattern = patterns[i]
        local init = 1

        while init <= str_len + 1 do
            local s, e = str_find(str, pattern, init)
            if not s then break end

            if e >= s then
                count = count + 1

                matches[count] = {
                    col_start = s - 1,
                    col_end = e,
                    value = str_sub(str, s, e),
                    pattern = pattern,
                }

                init = e + 1
            else
                init = s + 1
            end
        end
    end

    return matches, count
end

--- Normalize a drawer mark in place.
---
--- Semantic `color` is translated into the configured highlight attribute:
---   style = "fg" -> fg
---   style = "bg" -> bg
---
--- Explicit fg/bg values are ignored when semantic `color` is provided.
---
--- @param mark witch-colors.Decoration
--- @param row integer 0-based buffer row
--- @return witch-colors.DecorationWithRow
local function normalize_decoration(mark, row)
    --- @cast mark witch-colors.DecorationWithRow
    mark.row = row

    local config_style = config.style

    --- @cast mark witch-colors.DecorationWithColor
    local color = mark.color
    if color ~= nil then
        if config_style == "bg" then
            mark.bg = color
            mark.fg = nil
        else
            mark.fg = color
            mark.bg = nil
        end
        mark.color = nil
    end

    if config_style == "ornament" then
        mark.ornament = mark.ornament or config.ornament.text
        mark.ornament_side = mark.ornament_side or config.ornament.side
    end

    --- @cast mark witch-colors.DecorationWithRow
    return mark
end


--- Render decorations within a buffer range.
--- @param bufnr integer
--- @param first_row integer 0-based inclusive
--- @param last_row integer 0-based exclusive
local function render_buf_range(bufnr, first_row, last_row)
    local active_parsers, parser_count = enabled_parsers(bufnr)
    if parser_count == 0 then return end

    local lines = api.nvim_buf_get_lines(bufnr, first_row, last_row, false)
    local line_count = #lines

    if line_count == 0 then return end

    Renderer.clear(bufnr, first_row, last_row)

    local decorations, dec_count = {}, 0

    for i = 1, line_count do
        local line = lines[i]
        local row = first_row + i - 1

        for j = 1, parser_count do
            local parser = active_parsers[j]

            -- Custom line parser.
            local parse = parser.parse

            if parse then
                local ds = parse(line, row)

                if ds then
                    for k = 1, #ds do
                        dec_count = dec_count + 1
                        decorations[dec_count] = normalize_decoration(ds[k], row)
                    end
                end
            end

            -- Pattern-based resolver.
            local patterns = parser.patterns

            if patterns and next(patterns) then
                local matches, match_count = collect_matches(line, patterns)
                local resolve = parser.resolve

                for k = 1, match_count do
                    local match = matches[k]
                    local decoration

                    if resolve then
                        decoration = resolve(match, row)
                    else
                        decoration = {
                            color = match.value,
                            col_start = match.col_start,
                            col_end = match.col_end,
                        }
                    end

                    if decoration then
                        dec_count = dec_count + 1
                        decorations[dec_count] = normalize_decoration(decoration, row)
                    end
                end
            end
        end
    end

    if dec_count > 0 then
        Renderer.render_many(bufnr, decorations)
    end
end

--- Get the visible buffer rows of a window.
--- @param win integer
--- @param bufnr integer
--- @return integer|nil first 0-based inclusive
--- @return integer|nil last 0-based exclusive
local function view_range(win, bufnr)
    local info = fn.getwininfo(win)[1]
    if not info then return nil end

    local line_count = api.nvim_buf_line_count(bufnr)
    local first = math.max(info.topline - 1, 0)
    local last = math.min(info.botline, line_count)

    if first >= last then return nil end

    return first, last
end


--- Render the visible rows of a window.
--- @param win integer
local function render_viewport(win)
    if not active or not api.nvim_win_is_valid(win) then
        return
    end

    local bufnr = api.nvim_win_get_buf(win)
    if not api.nvim_buf_is_loaded(bufnr) or is_excluded(bufnr) then
        return
    end

    local first_row, last_row = view_range(win, bufnr)
    if not first_row then return end
    --- @cast last_row integer

    render_buf_range(bufnr, first_row, last_row)
end

local pending = {} --- @type table<integer, boolean>

local function schedule_render(win)
    if not active or pending[win] then return end

    pending[win] = true

    vim.defer_fn(function()
        pending[win] = nil
        render_viewport(win)
    end, DEBOUNCE_MS)
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Enable automatic rendering.
---
--- Registers autocmds and renders the current viewport.
--- Calling this function multiple times has no additional effect.
function M.enable()
    if active then return end

    active = true

    augroup = api.nvim_create_augroup("witch-colors", {
        clear = true,
    })

    api.nvim_create_autocmd({
        "TextChanged",
        "TextChangedP",
        "InsertLeave",
        "BufWinEnter",
        "WinScrolled",
        "WinResized",
    }, {
        group = augroup,
        callback = function()
            schedule_render(api.nvim_get_current_win())
        end,
    })

    render_viewport(api.nvim_get_current_win())
end

--- Disable automatic rendering and clear every highlight.
---
--- Removes registered autocmds and invalidates pending render requests.
--- Calling this function multiple times has no additional effect.
function M.disable()
    if not active then return end

    active = false

    if augroup then
        augroup = api.nvim_del_augroup_by_id(augroup)
    end

    pending = {}

    if not Renderer then return end

    for _, buf in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_valid(buf) then
            Renderer.clear(buf)
        end
    end
end

--- Re-render a window immediately.
---
--- @param win? integer
function M.refresh(win)
    render_viewport(win or api.nvim_get_current_win())
end

return M
