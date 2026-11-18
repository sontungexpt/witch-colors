local PALETTE = require("witch-colors.palette.tailwind")

local PREFIXES = {
    "ring-offset",
    "placeholder",
    "decoration",
    "divide",
    "outline",
    "accent",
    "caret",
    "shadow",
    "stroke",
    "border",
    "ring",
    "fill",
    "from",
    "via",
    "to",
    "bg",
    "text",
}

local patterns = {}
local prefix_lengths = {}

for i = 1, #PREFIXES do
    local prefix = PREFIXES[i]

    patterns[i] = "%f[%w]"
        .. prefix:gsub("%-", "%%-")
        .. "%-"
        .. "[%a]+%-?%d*"
        .. "%f[^%w%-]"

    prefix_lengths[prefix] = #prefix
end

---@type witch-colors.Parser
return {
    patterns = patterns,

    resolve = function(match)
        local value = match.value
        local separator = value:find("-", 1, true)

        if not separator then
            return nil
        end

        -- Resolve the prefix, including multi-part prefixes.
        local prefix = value:sub(1, separator - 1)

        if prefix == "ring" then
            local next_separator = value:find("-", separator + 1, true)

            if next_separator then
                local extended_prefix = value:sub(1, next_separator - 1)

                if prefix_lengths[extended_prefix] then
                    separator = next_separator
                    prefix = extended_prefix
                end
            end
        end

        if not prefix_lengths[prefix] then
            return nil
        end

        local color = PALETTE[value:sub(separator + 1)]

        if not color then
            return nil
        end

        return {
            color = color,
            col_start = match.col_start,
            col_end = match.col_end,
        }
    end,
}
