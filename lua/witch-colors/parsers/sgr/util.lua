--- Shared utilities for SGR (Select Graphic Rendition) escape sequence parsers.
---
--- @class witch-colors.parsers.sgr.util
local M = {}

-- Escape introducers for SGR sequences.
M.ESC = "\27"
M.ESC_27 = "\\27"
M.ESC_033 = "\\033"

--- Find the beginning of the SGR parameters.
---
--- Supports:
---   - `ESC[`  (actual escape byte)
---   - `\27[`  (literal escape representation)
---   - `\033[` (literal escape representation)
---
--- @param value string
--- @return integer|nil position after the introducer, or nil when not found
function M.get_param_start(value)
    local first = value:byte(1)

    -- Actual ESC character.
    if first == 27 and value:byte(2) == 91 then
        return 3
    end

    -- Literal "\27[".
    if first == 92
        and value:byte(2) == 50
        and value:byte(3) == 55
        and value:byte(4) == 91
    then
        return 5
    end

    -- Literal "\033[".
    if first == 92
        and value:byte(2) == 48
        and value:byte(3) == 51
        and value:byte(4) == 51
        and value:byte(5) == 91
    then
        return 6
    end
end

return M
