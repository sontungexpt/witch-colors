--- Shared utilities for color parsers.
---
--- Provides helpers that are duplicated across multiple parser sources so
--- they can be maintained in one place.
---
--- @class witch-colors.parsers.shared.util
local M = {}

--- Check whether a byte is CSS whitespace.
--- @param byte integer|nil
--- @return boolean
function M.is_space(byte)
    return byte == 32 -- space
        or byte == 9  -- tab
        or byte == 10 -- line feed
        or byte == 13 -- carriage return
        or byte == 12 -- form feed
end

--- Skip CSS whitespace.
--- @param value string
--- @param pos integer
--- @return integer next_pos
--- @return boolean had_space
function M.skip_space(value, pos)
    local len = #value
    local start = pos
    while pos <= len and M.is_space(value:byte(pos)) do
        pos = pos + 1
    end
    return pos, pos > start
end

return M
