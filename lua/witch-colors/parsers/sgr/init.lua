--- Unified SGR color source.
---
--- Recognizes foreground/background colors in SGR sequences:
---   - ANSI 16 colors: 30-37, 40-47, 90-97, 100-107.
---   - xterm 256 colors: `38;5;N`, `48;5;N`, `38:5:N`, `48:5:N`.
---   - Truecolor: `38;2;R;G;B`, `38:2::R:G:B`, `38:2:CSID:R:G:B`,
---     and the non-standard `38:2:R:G:B` (same for 48).
---
--- Channels and indices must be integers in 0-255.
--- Empty channels are treated as invalid (the whole group is ignored).
--- The color-space identifier is parsed but not used.
--- Reset parameters (0, 39, 49) clear previously declared colors.
--- Other SGR attributes are ignored. The last valid value wins.
---
--- ANSI colors use the default xterm palette, not the user's terminal theme.

local str_byte = string.byte
local floor = math.floor

local sgr = require("witch-colors.parsers.sgr.util")

local SEMICOLON = sgr.SEMICOLON
local COLON = sgr.COLON
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
---   0-15:    Standard ANSI colors.
---   16-231:  6x6x6 RGB color cube.
---   232-255: Grayscale ramp.
---
--- @param index integer
--- @return integer
local function xterm256_to_rgb(index)
	if index < 16 then
		return ANSI_COLORS[index + 1]
	end

	if index < 232 then
		local n = index - 16
		local r = floor(n / 36)
		local g = floor(n / 6) % 6
		local b = n % 6

		return CUBE_LEVELS[r + 1] * 0x10000 + CUBE_LEVELS[g + 1] * 0x100 + CUBE_LEVELS[b + 1]
	end

	return (8 + (index - 232) * 10) * 0x010101
end

--- Read an unsigned decimal integer in [0, limit].
---
--- Consumes all consecutive digits. Returns nil if empty or above limit.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @param limit integer
--- @return integer|nil result
--- @return integer next_index
local function read_uint(value, index, last, limit)
	local n = 0
	local first = index
	local valid = true

	while index <= last do
		local b = str_byte(value, index)
		if b < DIGIT_ZERO or b > DIGIT_NINE then
			break
		end

		if valid then
			n = n * 10 + b - DIGIT_ZERO
			if n > limit then
				valid = false
			end
		end

		index = index + 1
	end

	if index == first or not valid then
		return nil, index
	end

	return n, index
end

--- Advance to the next top-level semicolon (or past `last`).
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer
local function skip_to_semicolon(value, index, last)
	while index <= last and str_byte(value, index) ~= SEMICOLON do
		index = index + 1
	end
	return index
end

--- @param r integer|nil
--- @param g integer|nil
--- @param b integer|nil
--- @return integer|nil
local function pack_rgb(r, g, b)
	if r and g and b then
		return r * 0x10000 + g * 0x100 + b
	end
	return nil
end

--- Read an extended color group using `;` separators.
--- `index` points at the semicolon after 38/48.
---
---   38;5;N      -> indexed
---   38;2;R;G;B  -> truecolor
---
--- Reads exactly the number of fields the mode requires, so following
--- SGR parameters are never consumed.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil color
--- @return integer next_index
local function read_semicolon_color(value, index, last)
	local mode
	mode, index = read_uint(value, index + 1, last, 255)

	if mode == 5 then
		local n
		if str_byte(value, index) == SEMICOLON then
			n, index = read_uint(value, index + 1, last, 255)
		end
		if n == nil then
			return nil, index
		end
		return xterm256_to_rgb(n), index
	end

	if mode == 2 then
		local r, g, b

		if str_byte(value, index) == SEMICOLON then
			r, index = read_uint(value, index + 1, last, 255)
		end
		if str_byte(value, index) == SEMICOLON then
			g, index = read_uint(value, index + 1, last, 255)
		end
		if str_byte(value, index) == SEMICOLON then
			b, index = read_uint(value, index + 1, last, 255)
		end

		return pack_rgb(r, g, b), index
	end

	return nil, index
end

--- Read an extended color group using `:` separators.
--- `index` points at the colon after 38/48.
---
---   38:5:N              -> indexed
---   38:2::R:G:B         -> truecolor, empty color-space id
---   38:2:CSID:R:G:B     -> truecolor, numeric color-space id
---   38:2:R:G:B          -> truecolor, no color-space id (non-standard)
---
--- Consumes every field up to the next top-level semicolon.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil color
--- @return integer next_index
local function read_colon_color(value, index, last)
	local mode
	mode, index = read_uint(value, index + 1, last, 255)

	-- Collect remaining fields (false = empty or invalid).
	local f1, f2, f3, f4
	local n = 0

	while index <= last and str_byte(value, index) == COLON do
		local v
		v, index = read_uint(value, index + 1, last, 255)
		n = n + 1

		if v == nil then
			v = false
		end

		if n == 1 then
			f1 = v
		elseif n == 2 then
			f2 = v
		elseif n == 3 then
			f3 = v
		elseif n == 4 then
			f4 = v
		end
	end

	index = skip_to_semicolon(value, index, last)

	if mode == 5 and n >= 1 and f1 then
		return xterm256_to_rgb(f1), index
	end

	if mode == 2 then
		if n == 3 then
			return pack_rgb(f1 or nil, f2 or nil, f3 or nil), index
		elseif n >= 4 then
			return pack_rgb(f2 or nil, f3 or nil, f4 or nil), index
		end
	end

	return nil, index
end

--- Map a plain ANSI color parameter to its target and RGB value.
---
--- @param param integer
--- @return "fg"|"bg"|nil kind
--- @return integer|nil color
local function ansi_color(param)
	if param >= 30 and param <= 37 then
		return "fg", ANSI_COLORS[param - 30 + 1]
	elseif param >= 90 and param <= 97 then
		return "fg", ANSI_COLORS[param - 90 + 9]
	elseif param >= 40 and param <= 47 then
		return "bg", ANSI_COLORS[param - 40 + 1]
	elseif param >= 100 and param <= 107 then
		return "bg", ANSI_COLORS[param - 100 + 9]
	end
	return nil, nil
end

--- Find foreground and background colors in an SGR parameter string.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil fg
--- @return integer|nil bg
local function find_colors(value, index, last)
	local fg
	local bg

	while index <= last do
		local param
		param, index = read_uint(value, index, last, 255)

		if param == 38 or param == 48 then
			local sep = str_byte(value, index)
			local color

			if sep == COLON then
				color, index = read_colon_color(value, index, last)
			elseif sep == SEMICOLON then
				color, index = read_semicolon_color(value, index, last)
			end

			if color ~= nil then
				if param == 38 then
					fg = color
				else
					bg = color
				end
			end
		else
			-- Plain parameter: ignore when it carries colon sub-parameters.
			if param ~= nil and str_byte(value, index) ~= COLON then
				if param == 0 then
					fg, bg = nil, nil
				elseif param == 39 then
					fg = nil
				elseif param == 49 then
					bg = nil
				else
					local kind, color = ansi_color(param)
					if kind == "fg" then
						fg = color
					elseif kind == "bg" then
						bg = color
					end
				end
			end

			-- Skip colon sub-parameters (e.g. 4:3) or invalid parameters.
			index = skip_to_semicolon(value, index, last)
		end

		-- Advance to the next top-level parameter.
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
	patterns = sgr.patterns("[%d;:]+"),

	resolve = function(match)
		local value = match.value
		local len = #value

		if len < 4 or str_byte(value, len) ~= TERMINATOR then
			return nil
		end

		local param_start = sgr.get_param_start(value)
		if not param_start then
			return nil
		end

		local fg, bg = find_colors(value, param_start, len - 1)
		if fg == nil and bg == nil then
			return nil
		end

		return {
			col_start = match.col_start,
			col_end = match.col_end,
			fg = fg,
			bg = bg,
		}
	end,
}
