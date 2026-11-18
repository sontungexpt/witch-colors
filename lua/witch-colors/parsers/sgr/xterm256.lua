--- xterm 256-color SGR source.
---
--- Recognizes indexed foreground and background color declarations.
---
--- Supported:
---   - Foreground indexed colors: `38;5;N`, where N is in [0, 255].
---   - Background indexed colors: `48;5;N`, where N is in [0, 255].
---   - Standard ANSI colors (indices 0–15).
---   - 6x6x6 RGB color cube (indices 16–231).
---   - Grayscale colors (indices 232–255).
---   - Multiple foreground and background declarations in one sequence.
---   - Actual ESC bytes and common literal escape representations.
---
--- Truecolor declarations (`38;2;R;G;B` and `48;2;R;G;B`)
--- are skipped and handled by the dedicated truecolor source.
---
--- Unrelated SGR attributes are ignored.

local str_byte = string.byte
local floor = math.floor

local sgr = require("witch-colors.parsers.sgr.util")

local SEMICOLON = sgr.SEMICOLON
local TERMINATOR = sgr.TERMINATOR
local DIGIT_ZERO = sgr.DIGIT_ZERO
local DIGIT_NINE = sgr.DIGIT_NINE

-- Standard 16 ANSI colors, stored as 24-bit RGB integers.
local ANSI_COLORS = {
    0x000000, 0x800000, 0x008000, 0x808000,
    0x000080, 0x800080, 0x008080, 0xC0C0C0,
    0x808080, 0xFF0000, 0x00FF00, 0xFFFF00,
    0x0000FF, 0xFF00FF, 0x00FFFF, 0xFFFFFF,
}

-- The six possible channel values in the xterm color cube.
local CUBE_LEVELS = { 0, 95, 135, 175, 215, 255 }

--- Convert an xterm 256-color index to a 24-bit RGB integer.
---
--- Index ranges:
---   0–15:   Standard ANSI colors.
---   16–231: 6x6x6 RGB color cube.
---   232–255: Grayscale colors.
---
--- @param index integer
--- @return witch-colors.ColorRGB
local function xterm256_to_rgb(index)
    if index < 16 then
        return ANSI_COLORS[index + 1]
    end

    if index < 232 then
        local n = index - 16

        local r = floor(n / 36)
        local g = floor(n / 6) % 6
        local b = n % 6

        return CUBE_LEVELS[r + 1] * 0x10000
            + CUBE_LEVELS[g + 1] * 0x100
            + CUBE_LEVELS[b + 1]
    end

    local gray = 8 + (index - 232) * 10

    return gray * 0x010101
end

--- Read an unsigned decimal parameter.
---
--- Values above 255 are saturated to 256. This preserves the ability
--- to consume unrelated large SGR parameters without integer overflow.
---
--- Empty parameters are interpreted as zero.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer result
--- @return integer next_index
local function read_uint(value, index, last)
    local result = 0
    local has_digit = false

    while index <= last do
        local byte = str_byte(value, index)

        if byte < DIGIT_ZERO or byte > DIGIT_NINE then
            break
        end

        has_digit = true

        if result <= 255 then
            result = result * 10 + byte - DIGIT_ZERO

            if result > 255 then
                result = 256
            end
        end

        index = index + 1
    end

    return has_digit and result or 0, index
end

--- Read a semicolon-separated parameter.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil result
--- @return integer next_index
local function read_parameter(value, index, last)
    if str_byte(value, index) ~= SEMICOLON then
        return nil, index
    end

    return read_uint(value, index + 1, last)
end

--- Skip a truecolor group.
---
--- Truecolor groups:
---   38;2;R;G;B
---   48;2;R;G;B
---
--- @param value string
--- @param index integer Position after the color mode.
--- @param last integer
--- @return boolean success
--- @return integer next_index
local function skip_truecolor(value, index, last)
    for _ = 1, 3 do
        local component

        component, index = read_parameter(value, index, last)

        if component == nil then
            return false, index
        end
    end

    return true, index
end

--- Find indexed foreground and background colors in an SGR sequence.
---
--- Recognizes:
---   38;5;N = Foreground xterm color.
---   48;5;N = Background xterm color.
---
--- Truecolor groups are skipped without resolving their components.
--- Other SGR attributes are ignored.
---
--- When a color is declared multiple times, the last valid index wins.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil fg
--- @return integer|nil bg
local function find_indexed_colors(value, index, last)
    local fg
    local bg

    while index <= last do
        local param
        param, index = read_uint(value, index, last)

        if param == 38 or param == 48 then
            local is_foreground = param == 38

            -- Read the extended color mode.
            local mode
            mode, index = read_parameter(value, index, last)

            if mode == nil then
                break
            end

            if mode == 5 then
                -- Indexed-color mode: read the palette index.
                local palette_index
                palette_index, index = read_parameter(value, index, last)

                if palette_index == nil then
                    break
                end

                if palette_index <= 255 then
                    if is_foreground then
                        fg = palette_index
                    else
                        bg = palette_index
                    end
                end

            elseif mode == 2 then
                -- Truecolor belongs to the dedicated truecolor source.
                local success
                success, index = skip_truecolor(value, index, last)

                if not success then
                    break
                end
            end
        end

        -- Continue with the next SGR parameter.
        if str_byte(value, index) == SEMICOLON then
            index = index + 1
        else
            break
        end
    end

    return fg, bg
end



--- @type witch-colors.Parser
return {
	patterns = sgr.patterns("[%d;]+"),

	resolve = function(match)
		local value = match.value
		local len = #value

		if len < 4 or str_byte(value, len) ~= TERMINATOR then
			return nil
		end

		local param_start = sgr.get_param_start(value)
		if param_start == nil then
			return nil
		end

		local fg_index, bg_index = find_indexed_colors(value, param_start, len - 1)
		if fg_index == nil and bg_index == nil then
			return nil
		end

		local mark = {
			col_start = match.col_start,
			col_end = match.col_end,
		}

		if fg_index ~= nil then
			mark.fg = xterm256_to_rgb(fg_index)
		end

		if bg_index ~= nil then
			mark.bg = xterm256_to_rgb(bg_index)
		end

		return mark
	end,
}
