local type, pairs, ipairs, tonumber = type, pairs, ipairs, tonumber
local getmetatable, setmetatable = getmetatable, setmetatable
local str_find, str_sub = string.find, string.sub
local math_max, math_min, math_huge = math.max, math.min, math.huge
local table_sort = table.sort

local vim = vim
local api, fn = vim.api, vim.fn
local defer_fn = vim.defer_fn

local M = {}

-- ============================================================================
-- Dependencies
-- ============================================================================

--- Lazy load renderer module.
local Renderer = {}
setmetatable(Renderer, {
    __index = function(_, key)
        Renderer = require("witch-colors.renderer")
        return Renderer[key]
    end,
})

local Config = require("witch-colors.config")
local config = Config.current
local is_excluded = Config.is_excluded

-- ============================================================================
-- Constants
-- ============================================================================

-- The first invalidation starts the timer. Later invalidations are merged
-- into the same batch; they do not restart the timer.
local DEBOUNCE_MS = 100
local AUGROUP_NAME = "witch-colors"

-- ============================================================================
-- State
-- ============================================================================

--- A half-open interval of buffer rows that need to be rendered.
--- `first` is included; `last` is the first row after the interval.
--- For example, [10, 15) represents rows 10, 11, 12, 13, and 14.
--- @class witch-colors.DirtyInterval
--- @field first integer 0-based inclusive
--- @field last number 0-based exclusive

--- Pending row intervals for one buffer.
--- Separate intervals stay separate so rendering does not fill the gaps
--- between distant windows or separately exposed viewport strips.
--- @class witch-colors.DirtyRange
--- @field ranges witch-colors.DirtyInterval[] Disjoint or adjacent ranges awaiting rendering.

--- The last visible range remembered for a window. It is used to detect
--- which rows become visible after scrolling or resizing.
--- @class witch-colors.Viewport
--- @field bufnr integer Buffer currently displayed in the window.
--- @field first integer 0-based inclusive visible row.
--- @field last integer 0-based exclusive visible row.

--- @class witch-colors.State
--- Whether automatic rendering is active.
--- @field enabled boolean
---
--- Attached buffers: bufnr -> attachment token.
--- Attachments are retained across enable/disable cycles to avoid creating
--- duplicate callbacks. A disabled attachment detaches on its next line change.
--- @field attached table<integer, table>
---
--- Rows to re-render: bufnr -> pending dirty ranges.
--- An entry also means a render is already scheduled for that buffer.
--- @field dirty table<integer, witch-colors.DirtyRange>
---
--- Last known visible range: winid -> viewport.
--- @field viewports table<integer, witch-colors.Viewport>
local state = {
    enabled = false,
    attached = {},
    dirty = {},
    viewports = {},
}

-- ============================================================================
-- Parsers
-- ============================================================================

--- Metatable `__index` of a lazy parser: resolve a missing field from the
--- parser's module.
---
--- Loads the module on first access and replaces itself with the loaded
--- module in the parser's metatable.
---
--- @param parser witch-colors.Parser
--- @param key any
--- @return any
local function lazy_parser_index(parser, key)
    local path = parser.path

    --- Recheck to ensure the path is still existing to avoid user change this value after the parser is loaded.
    if not path then return nil end

    --- No need to use `pcall` here, the parser module must exist.
    --- If it doesn't, `require` will throw an error before this point.
    --- So the user will see the error message instead of a silent failure to let them know the parser is invalid and must be fixed.
    local module = require(path)

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

    for _, parser in pairs(config.parsers) do
        local enabled = parser.enabled

        if enabled == true or (type(enabled) == "function" and enabled(bufnr)) then
            -- Insert in priority order. Using `>` keeps the original order
            -- when two parsers have the same priority.
            local priority = parser.priority or 999
            local pos = count + 1

            while pos > 1 and (result[pos - 1].priority or 999) > priority do
                result[pos] = result[pos - 1]
                pos = pos - 1
            end

            result[pos] = lazy_parser(parser)
            count = count + 1
        end
    end

    return result, count
end

-- ============================================================================
-- Matching
-- ============================================================================

--- Find all non-empty matches of the given Lua patterns in `str`.
--- `string.find()` returns 1-based columns. The stored start column is
--- converted to 0-based, while its end becomes the exclusive end column.
--- @param str string
--- @param patterns string|string[]
--- @return witch-colors.PatternMatch[]|nil matches
--- @return integer count
local function find_matches(str, patterns)
    local str_len = #str
    if str_len == 0 then
        return nil, 0
    end

    local is_list_pattern = type(patterns) == "table"
    local pattern_count = is_list_pattern and #patterns or 1

    local matches = nil
    local match_count = 0

    for i = 1, pattern_count do
        local pattern = is_list_pattern and patterns[i] or patterns
        --- @cast pattern string

        local init = 1

        while init <= str_len + 1 do
            local s, e = str_find(str, pattern, init)
            if not s then
                break
            end
            --- @cast e integer

            if e >= s then
                -- Convert Lua string positions into the decoration
                -- convention: 0-based start and exclusive end.
                match_count = match_count + 1
                matches = matches or {}
                matches[match_count] = {
                    col_start = s - 1,
                    col_end = e,
                    value = str_sub(str, s, e),
                    pattern = pattern,
                }

                -- Continue after this match so matches from the same
                -- pattern do not overlap.
                init = e + 1
            else
                -- Avoid infinite loops for empty matches.
                init = s + 1
            end
        end
    end

    return matches, match_count
end

-- ============================================================================
-- Decorations
-- ============================================================================

--- Normalize a decoration in place.
---
--- Semantic `color` is translated into the configured highlight attribute:
---   style = "fg" -> fg
---   style = "bg" -> bg
---
--- Explicit fg/bg values are ignored when semantic `color` is provided.
---
--- @param decor witch-colors.Decoration
--- @param row integer 0-based buffer row
--- @return witch-colors.RowDecoration
local function normalize_decoration(decor, row)
    --- @cast decor witch-colors.RowDecoration
    decor.row = row

    local style = config.style

    -- `color` is a semantic shortcut: move it into fg or bg according
    -- to the configured style, then remove the temporary field.
    --- @cast decor witch-colors.SemanticColorDecoration
    local color = decor.color

    if color ~= nil then
        if style == "bg" then
            decor.bg = color
            decor.fg = nil
        else
            decor.fg = color
            decor.bg = nil
        end

        decor.color = nil
    end

    if style == "ornament" then
        local ornament = config.ornament

        decor.ornament = decor.ornament or ornament.text
        decor.ornament_side = decor.ornament_side or ornament.side
    end

    --- @cast decor witch-colors.RowDecoration
    return decor
end

-- ============================================================================
-- Rendering
-- ============================================================================

--- Render decorations within a buffer range.
---
--- The caller decides which rows need work. This function only processes
--- the range it receives; it does not inspect windows or calculate viewports.
--- The requested range must already be clipped to the visible viewport.
---
--- @param bufnr integer
--- @param first_row integer 0-based inclusive
--- @param last_row integer 0-based exclusive
--- @param parsers witch-colors.Parser[]
--- @param parser_count integer
local function render_range(bufnr, first_row, last_row, parsers, parser_count)
    -- Clear old decorations only in this interval before applying the
    -- newly calculated decorations. This also removes stale marks.
    Renderer.clear(bufnr, first_row, last_row)

    if parser_count == 0 then
        return
    end

    local lines = api.nvim_buf_get_lines(bufnr, first_row, last_row, false)
    local decors
    local decor_count = 0

    for line_index = 1, #lines do
        local line = lines[line_index]
        -- `line_index` starts at 1, but buffer rows start at 0.
        local row = first_row + line_index - 1

        for parser_index = 1, parser_count do
            local parser = parsers[parser_index]
            local parse = parser.parse

            if parse then
                local parsed = parse(parser, line, bufnr, row)

                if parsed then
                    for i = 1, #parsed do
                        local decor = parsed[i]

                        normalize_decoration(decor, row)

                        decor_count = decor_count + 1
                        decors = decors or {}
                        decors[decor_count] = decor
                    end
                end
            else
                local patterns = parser.pattern

                if type(patterns) == "function" then
                    patterns = patterns(parser, line, bufnr, row)
                end

                if patterns then
                    local matches, match_count = find_matches(line, patterns)

                    if matches then
                        local resolve = parser.resolve

                        for i = 1, match_count do
                            local match = matches[i]
                            local decor

                            if resolve then
                                decor = resolve(parser, match, bufnr, row)
                            else
                                decor = {
                                    color = match.value,
                                    col_start = match.col_start,
                                    col_end = match.col_end,
                                }
                            end

                            if decor then
                                normalize_decoration(decor, row)

                                decor_count = decor_count + 1
                                decors = decors or {}
                                decors[decor_count] = decor
                            end
                        end
                    end
                end
            end
        end
    end

    if decors then
        Renderer.render_many(bufnr, decors)
    end
end

--- Get the visible buffer rows of a window.
--- Neovim reports `topline` using 1-based line numbers. Convert it to
--- the plugin's 0-based rows; `botline` is used as the exclusive end.
--- @param win integer
--- @param line_count integer
--- @return integer|nil first_row 0-based inclusive
--- @return integer|nil last_row 0-based exclusive
local function visible_rows(win, line_count)
    local info = fn.getwininfo(win)[1]
    if not info then
        return nil
    end

    local first_row = info.topline - 1
    local last_row = math_min(info.botline, line_count)

    if first_row >= last_row then
        return nil
    end

    return first_row, last_row
end

--- Remember the current viewport so the next scroll can be compared with it.
--- @param win integer
--- @param bufnr integer
--- @param first_row integer
--- @param last_row integer
local function update_viewport(win, bufnr, first_row, last_row)
    local viewport = state.viewports[win]

    if viewport and viewport.bufnr == bufnr then
        viewport.first = first_row
        viewport.last = last_row
    else
        state.viewports[win] = {
            bufnr = bufnr,
            first = first_row,
            last = last_row,
        }
    end
end

--- Forget every window viewport that currently refers to this buffer.
--- This is needed when its decorations are cleared or the buffer detaches.
--- @param bufnr integer
local function clear_buffer_viewports(bufnr)
    for win, viewport in pairs(state.viewports) do
        if viewport.bufnr == bufnr then
            state.viewports[win] = nil
        end
    end
end

-- ============================================================================
-- Deferred rendering
-- ============================================================================

--- Whether a row range starts before another range.
--- @param a integer[]
--- @param b integer[]
--- @return boolean
local function range_less(a, b)
    return a[1] < b[1]
end

--- Render dirty intervals of a buffer, clipped to currently visible windows.
--- A dirty interval may be outside the viewport by the time this timer runs.
--- Intersecting it with visible rows prevents parsing invisible buffer content.
--- @param bufnr integer
--- @param expected witch-colors.DirtyRange
local function flush_dirty(bufnr, expected)
    -- Ignore callbacks belonging to replaced or cancelled dirty ranges.
    -- This matters when the plugin is disabled or the buffer is excluded
    -- before the deferred callback gets a chance to run.
    if state.dirty[bufnr] ~= expected then
        return
    end

    -- Consume this batch before rendering. If rendering causes another
    -- invalidation, mark_dirty() can now create a fresh batch.
    state.dirty[bufnr] = nil

    if not state.enabled or not api.nvim_buf_is_loaded(bufnr) then
        return
    end

    if is_excluded(bufnr) then
        clear_buffer_viewports(bufnr)
        Renderer.clear(bufnr)
        return
    end

    local line_count = api.nvim_buf_line_count(bufnr)
    local ranges = {}
    local range_count = 0
    local dirty_ranges = expected.ranges

    -- A buffer can appear in more than one window. Collect the parts of
    -- the dirty intervals that are visible in any window in this tab.
    -- Inactive tabs are handled when their TabEnter event schedules them.
    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        if api.nvim_win_get_buf(win) == bufnr then
            local first_row, last_row = visible_rows(win, line_count)

            if first_row then
                --- @cast last_row integer

                -- Text edits can move the visible line numbers, so keep the
                -- remembered viewport synchronized with Neovim's current view.
                update_viewport(win, bufnr, first_row, last_row)

                -- Keep only the intersection: dirty rows that are also visible.
                for dirty_index = 1, #dirty_ranges do
                    local dirty = dirty_ranges[dirty_index]
                    local range_first = math_max(first_row, dirty.first)
                    local range_last = math_min(last_row, dirty.last)

                    if range_first < range_last then
                        range_count = range_count + 1
                        ranges[range_count] = { range_first, range_last }
                    end
                end
            end
        end
    end

    -- Nothing from this dirty batch is visible in the current tab.
    if range_count == 0 then return end

    if range_count > 1 then
        table_sort(ranges, range_less)
    end

    -- Sort the visible intersections, then merge overlaps so the same row
    -- is never parsed twice when multiple windows show overlapping rows.
    -- Enabled parsers are shared by every range in this flush.
    local parsers, parser_count = enabled_parsers(bufnr)

    local first_row = ranges[1][1]
    local last_row = ranges[1][2]

    for i = 2, range_count do
        local range = ranges[i]

        if range[1] <= last_row then
            -- Merge overlapping or adjacent ranges.
            if range[2] > last_row then
                last_row = range[2]
            end
        else
            render_range(bufnr, first_row, last_row, parsers, parser_count)

            first_row = range[1]
            last_row = range[2]
        end
    end

    render_range(bufnr, first_row, last_row, parsers, parser_count)
end

--- Add rows to a buffer's pending render batch.
---
--- The first call starts one delayed flush. Further calls before that flush
--- only add or merge intervals; they do not create more timers.
--- This is useful for both text edits and newly exposed viewport rows.
--- Separate intervals stay separate so scrolling one window does not render
--- the invisible gap between distant visible windows.
---
--- The caller must ensure automatic rendering is enabled.
---
--- @param bufnr integer
--- @param first_row integer 0-based inclusive
--- @param last_row number 0-based exclusive (may be math.huge)
local function mark_dirty(bufnr, first_row, last_row)
    local dirty = state.dirty[bufnr]

    if not dirty then
        dirty = { ranges = {} }
        state.dirty[bufnr] = dirty

        defer_fn(function()
            flush_dirty(bufnr, dirty)
        end, DEBOUNCE_MS)
    end

    -- Merge only overlapping or touching intervals. For example, [10, 15)
    -- and [15, 18) become [10, 18), but [10, 15) and [20, 25) stay apart.
    local ranges = dirty.ranges
    local i = #ranges

    while i > 0 do
        local range = ranges[i]

        if first_row <= range.last and last_row >= range.first then
            if range.first < first_row then
                first_row = range.first
            end

            if range.last > last_row then
                last_row = range.last
            end

            -- Remove this interval without shifting the rest of the array.
            -- Re-check the replacement at this index: the enlarged range
            -- may also overlap another interval.
            ranges[i] = ranges[#ranges]
            ranges[#ranges] = nil
            i = #ranges
        else
            i = i - 1
        end
    end

    ranges[#ranges + 1] = {
        first = first_row,
        last = last_row,
    }
end

-- ============================================================================
-- Text change tracking (nvim_buf_attach)
-- ============================================================================

--- Attach to a buffer once during the module lifetime.
---
--- Attachments are retained across enable/disable cycles to avoid duplicate
--- callbacks. If a line change happens while disabled, the callback detaches
--- itself. If re-enabled before that happens, the existing callback is reused.
---
--- The caller must ensure the buffer is loaded and not excluded.
---
--- @param bufnr integer
local function attach_buffer(bufnr)
    if state.attached[bufnr] then return end

    -- Identifies this attachment. Replacing `attached[bufnr]` makes an
    -- older callback detach itself without affecting a newer attachment.
    local token = {}

    local ok = api.nvim_buf_attach(bufnr, false, {
        on_lines = function(_, buf, _, first_row, last_row, new_last_row)
            -- Neovim reports the changed rows as a half-open interval.
            -- Returning true detaches (plugin disabled or attachment invalidated).
            if state.attached[buf] ~= token then
                return true
            end

            -- Detach lazily when the plugin is disabled.
            if not state.enabled then
                state.attached[buf] = nil
                state.dirty[buf] = nil
                clear_buffer_viewports(buf)
                return true
            end

            if is_excluded(buf) then
                state.attached[buf] = nil
                state.dirty[buf] = nil
                clear_buffer_viewports(buf)
                Renderer.clear(buf)
                return true
            end

            if last_row ~= new_last_row then
                -- Line count changed: inserting or deleting lines shifts
                -- later rows (including rows that are already dirty), so
                -- invalidate from the first changed row through the end.
                mark_dirty(buf, first_row, math_huge)
            else
                -- The line count stayed the same. Invalidate only the
                -- replaced rows, while keeping at least one row included.
                mark_dirty(buf, first_row, math_max(new_last_row, first_row + 1))
            end
        end,

        -- :edit!, reload from disk, etc.
        on_reload = function(_, buf)
            if state.attached[buf] ~= token or not state.enabled then
                return
            end

            if is_excluded(buf) then
                state.dirty[buf] = nil
                clear_buffer_viewports(buf)
                Renderer.clear(buf)
                return
            end

            mark_dirty(buf, 0, math_huge)
        end,

        on_detach = function(_, buf)
            if state.attached[buf] == token then
                state.attached[buf] = nil
                state.dirty[buf] = nil
                clear_buffer_viewports(buf)
            end
        end,
    })

    if ok then
        state.attached[bufnr] = token
    end
end

--- Schedule rows that need rendering after a window changes its viewport.
--- A full refresh renders the whole visible range. A scroll/resize only
--- renders rows that were not in the previous viewport.
--- @param win integer
--- @param full boolean Whether to invalidate the entire visible range.
local function schedule_window(win, full)
    if not api.nvim_win_is_valid(win) then
        return
    end

    local bufnr = api.nvim_win_get_buf(win)

    if not api.nvim_buf_is_loaded(bufnr) then
        state.viewports[win] = nil
        return
    end

    if is_excluded(bufnr) then
        clear_buffer_viewports(bufnr)
        state.dirty[bufnr] = nil
        Renderer.clear(bufnr)
        return
    end

    local line_count = api.nvim_buf_line_count(bufnr)
    local first_row, last_row = visible_rows(win, line_count)

    if not first_row then
        state.viewports[win] = nil
        return
    end
    --- @cast last_row integer

    attach_buffer(bufnr)

    local previous = state.viewports[win]
    local same_buffer = previous and previous.bufnr == bufnr

    if not full and same_buffer then
        -- The buffer is unchanged, so rows in the overlap were already
        -- rendered. Only the strips entering at the top or bottom are new.
        local old_first = previous.first
        local old_last = previous.last

        -- Update the cached viewport before scheduling the render.
        previous.first = first_row
        previous.last = last_row

        -- Scrolling upward (or expanding the top) reveals rows before the
        -- previous first row.
        if first_row < old_first then
            local exposed_last = math_min(last_row, old_first)

            if first_row < exposed_last then
                mark_dirty(bufnr, first_row, exposed_last)
            end
        end

        -- Scrolling downward (or expanding the bottom) reveals rows after
        -- the previous last row.
        if last_row > old_last then
            local exposed_first = math_max(first_row, old_last)

            if exposed_first < last_row then
                mark_dirty(bufnr, exposed_first, last_row)
            end
        end

        return
    end

    -- First time this window is seen, or it switched buffers: there is no
    -- previous rendered viewport to compare with, so render the current view.
    update_viewport(win, bufnr, first_row, last_row)
    mark_dirty(bufnr, first_row, last_row)
end

--- Queue a full visible-range render for every window in the current tab.
--- This is used on startup/tab entry because a newly active view may not
--- have a trustworthy viewport cache yet.
local function schedule_displayed_buffers()
    if not state.enabled then return end

    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        schedule_window(win, true)
    end
end

--- Queue newly exposed rows for windows reported by WinScrolled.
--- `vim.v.event` contains one key per affected window plus an `all` summary.
local function schedule_scrolled_buffers()
    for key in pairs(vim.v.event) do
        if key ~= "all" then
            local win = tonumber(key)

            if win then
                schedule_window(win, false)
            end
        end
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Enable automatic rendering.
---
--- Attaches to displayed buffers, registers autocmds for events that
--- nvim_buf_attach cannot cover (viewport changes, buffer display),
--- and schedules their initial rendering.
--- Calling this function multiple times has no additional effect.
function M.enable()
    if state.enabled then return end
    state.enabled = true

    local group = api.nvim_create_augroup(AUGROUP_NAME, { clear = true })

    -- A newly displayed buffer needs a full visible render. Scrolling or
    -- resizing an existing window only needs its newly exposed rows.
    api.nvim_create_autocmd({
        "BufWinEnter",
        "WinScrolled",
        "TabEnter",
        "WinClosed",
    }, {
        group = group,
        callback = function(args)
            local event = args.event

            if event == "WinScrolled" then
                schedule_scrolled_buffers()
            elseif event == "TabEnter" then
                schedule_displayed_buffers()
            elseif event == "WinClosed" then
                local win = tonumber(args.match)
                if win then
                    state.viewports[win] = nil
                end
            else
                -- BufWinEnter: the current window has just displayed a buffer.
                schedule_window(api.nvim_get_current_win(), true)
            end
        end,
    })

    -- Buffers that are already displayed in the current tabpage.
    schedule_displayed_buffers()
end

--- Disable automatic rendering and clear every highlight.
---
--- Removes the autocmds. Scheduled renders and attached buffers
--- clean themselves up: timers find nothing running, and on_lines
--- callbacks detach on their next call.
--- Calling this function multiple times has no additional effect.
function M.disable()
    if not state.enabled then return end
    state.enabled = false

    -- Pending defer_fn callbacks may still run, but their identity check
    -- will fail because the dirty table is replaced here.
    state.dirty = {}
    state.viewports = {}

    api.nvim_del_augroup_by_name(AUGROUP_NAME)

    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_valid(bufnr) then
            Renderer.clear(bufnr)
        end
    end
end

--- Re-render a window immediately.
---
--- @param win? integer
function M.refresh(win)
    if not state.enabled then return end

    if not win or win == 0 then
        win = api.nvim_get_current_win()
    end

    if not api.nvim_win_is_valid(win) then
        return
    end

    local bufnr = api.nvim_win_get_buf(win)

    if not api.nvim_buf_is_loaded(bufnr) then
        return
    end

    if is_excluded(bufnr) then
        clear_buffer_viewports(bufnr)
        Renderer.clear(bufnr)
        return
    end

    local line_count = api.nvim_buf_line_count(bufnr)
    local first_row, last_row = visible_rows(win, line_count)
    if not first_row then
        state.viewports[win] = nil
        return
    end
    --- @cast last_row integer

    -- Keep the incremental-scroll baseline in sync with this manual render.
    update_viewport(win, bufnr, first_row, last_row)

    local parsers, parser_count = enabled_parsers(bufnr)

    render_range(bufnr, first_row, last_row, parsers, parser_count)
end

return M
