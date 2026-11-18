--- ANSI SGR 16-color source.
---
--- @deprecated Use `witch-colors.parsers.sgr` (unified SGR parser) instead.
---
--- Recognizes standard ANSI foreground and background color sequences.
---
--- Supported:
---   - Standard foreground colors (30–37).
---   - Standard background colors (40–47).
---   - Bright foreground colors (90–97).
---   - Bright background colors (100–107).
---   - Foreground and background reset parameters (39 and 49).
---   - Global SGR reset (0).
---   - Multiple color declarations in a single SGR sequence.
---   - Actual ESC bytes and common literal escape representations.
---
--- Extended colors (256-color and truecolor) are handled by their
--- dedicated sources.
---
--- Unrelated SGR attributes are ignored.

local str_byte = string.byte
local sgr = require("witch-colors.parsers.sgr.util")

local SEMICOLON = sgr.SEMICOLON
local DIGIT_ZERO = sgr.DIGIT_ZERO
local DIGIT_NINE = sgr.DIGIT_NINE
local TERMINATOR = sgr.TERMINATOR

-- ANSI color approximations.
-- Actual RGB values depend on the terminal's configurable palette.
-- Indices 1–8 are normal colors; 9–16 are bright colors.
local ANSI_COLORS = {
    0x000000, 0xFF0000, 0x00FF00, 0xD2691E,
    0x0000FF, 0x800080, 0x00FFFF, 0xD3D3D3,

    0xA9A9A9, 0xFF5555, 0x55FF55, 0xFFFF55,
    0x5555FF, 0xFF55FF, 0x55FFFF, 0xFFFFFF,
}

-- Resolves an ANSI foreground or background color parameter.
local function resolve_color(code)
    if code >= 30 and code <= 37 then
        return ANSI_COLORS[code - 29]
    end

    if code >= 40 and code <= 47 then
        return ANSI_COLORS[code - 39]
    end

    if code >= 90 and code <= 97 then
        return ANSI_COLORS[code - 81]
    end

    if code >= 100 and code <= 107 then
        return ANSI_COLORS[code - 91]
    end
end

local function parse_sgr(value, first, last)
    local foreground
    local background

    local index = first
    local skip = 0
    local extended_mode = false

    -- An empty parameter list is equivalent to SGR 0.
    local has_parameter = true

    while has_parameter do
        local param = 0

        if index <= last then
            local start = index

            while index <= last do
                local byte = str_byte(value, index)

                if byte < DIGIT_ZERO or byte > DIGIT_NINE then
                    break
                end

                param = param * 10 + byte - DIGIT_ZERO
                index = index + 1
            end

            -- Empty parameters are interpreted as zero.
            if index == start and str_byte(value, index) ~= SEMICOLON then
                return nil
            end

            if str_byte(value, index) == SEMICOLON then
                index = index + 1
            else
                has_parameter = false
            end
        else
            -- Handles an empty sequence or a trailing semicolon.
            has_parameter = false
        end

        if skip > 0 then
            -- Skip extended color components.
            skip = skip - 1

        elseif extended_mode then
            -- The parameter after 38/48 specifies the color mode.
            extended_mode = false

            if param == 5 then
                skip = 1 -- Indexed color: 38/48;5;N
            elseif param == 2 then
                skip = 3 -- Truecolor: 38/48;2;R;G;B
            end

        elseif param == 38 or param == 48 then
            -- Extended colors belong to the xterm256 and truecolor sources.
            extended_mode = true

        elseif param == 0 then
            foreground = nil
            background = nil

        elseif param == 39 then
            foreground = nil

        elseif param == 49 then
            background = nil

        elseif param >= 30 and param <= 37
            or param >= 90 and param <= 97
        then
            foreground = resolve_color(param)

        elseif param >= 40 and param <= 47
            or param >= 100 and param <= 107
        then
            background = resolve_color(param)
        end
    end

    if foreground == nil and background == nil then
        return nil
    end

    local mark = {}

    if foreground ~= nil then
        mark.fg = foreground
    end

    if background ~= nil then
        mark.bg = background
    end

    return mark
end

---@type witch-colors.Parser
return {
	patterns = sgr.patterns("[%d;]*"),

	resolve = function(match)
		local value = match.value
		local length = #value

		if length < 3 or str_byte(value, length) ~= TERMINATOR then
			return nil
		end

		local param_start = sgr.get_param_start(value)
		if param_start == nil then
			return nil
		end

		local mark = parse_sgr(value, param_start, length - 1)
		if mark == nil then
			return nil
		end

		mark.col_start = match.col_start
		mark.col_end = match.col_end

		return mark
	end,
}
