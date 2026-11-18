--- CSS named color source.
---
--- Supports all CSS named colors, including:
---   - Standard color names
---   - Gray and grey aliases
---   - Aqua and cyan aliases
---   - Fuchsia and magenta aliases
---   - Rebecca purple
---
--- Matching is case-insensitive.
--- Color names must not be part of a larger identifier.

local str_lower = string.lower

local PALETTE = require("witch-colors.palette.css")

-- Match a complete alphabetic color name.
--
-- The leading frontier prevents matching inside identifiers.
-- The trailing frontier rejects word characters, underscores, and hyphens.
local CSS_NAMED_COLOR_PATTERN = "%f[%a][%a]+%f[^%w_%-]"

---@type witch-colors.Parser
return {
    patterns = {
        CSS_NAMED_COLOR_PATTERN,
    },

    resolve = function(match)
        local color = PALETTE[str_lower(match.value)]

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
