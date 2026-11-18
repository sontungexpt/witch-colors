-- ============================================================================
-- Unified SGR color source
--
-- Color targets:
--   38 = foreground
--   48 = background
--
-- Supported ANSI colors:
--   30-37, 40-47
--   90-97, 100-107 (aixterm extension)
--
-- Indexed color:
--   38;5;N
--   48;5;N
--   38:5:N
--   48:5:N
--   38;5:N
--   48;5:N
--
-- RGB truecolor:
--   38;2;R;G;B
--   48;2;R;G;B
--   38:2::R:G:B
--   48:2::R:G:B
--   38:2:CSID:R:G:B
--   48:2:CSID:R:G:B
--   38;2:CSID:R:G:B
--   48;2:CSID:R:G:B
--
-- Legacy compatibility:
--   38:2:R:G:B
--   48:2:R:G:B
--
-- ISO/IEC 8613-6 RGB optional fields:
--   PE6: reserved / unused
--   PE7: tolerance
--   PE8: tolerance color space (0 = CIELUV, 1 = CIELAB)
--
-- Other ISO color modes (0, 1, 3, 4) are recognized as parameter groups
-- but are not converted to RGB.
--
-- SGR resets:
--   0  = foreground + background
--   39 = foreground
--   49 = background
--
-- Invalid extended colors do not overwrite previously resolved colors.
-- The last valid declaration wins.
--
-- ANSI colors use a fixed default xterm palette. Terminal customizations
-- cannot be inferred from the SGR sequence itself.
-- ============================================================================

local str_byte = string.byte
local str_char = string.char
local floor = math.floor

-- ============================================================================
-- Configuration
-- ============================================================================

-- Accept the non-standard but commonly encountered colon RGB shorthand:
--   38:2:R:G:B
--
-- Set false for strict ISO/IEC 8613-6 colon syntax.
local ALLOW_LEGACY_COLON_RGB = true

-- ============================================================================
-- Constants
-- ============================================================================

local SEMICOLON = 59 -- ';'
local COLON = 58 -- ':'
local TERMINATOR = 109 -- 'm'

local DIGIT_ZERO = 48
local DIGIT_NINE = 57

local ESC = "\27"
local CSI_8 = str_char(0x9B)

-- Literal representations of escape introducers.
local ESC_033 = "\\033"
local ESC_27 = "\\27"
local ESC_X1B = "\\x1[bB]"
local ESC_E = "\\e"
local ESC_U001B = "\\u001[bB]"

-- Literal representations of 8-bit CSI.
local CSI_X9B = "\\x9[bB]"
local CSI_U009B = "\\u009[bB]"

-- ============================================================================
-- SGR patterns
-- ============================================================================

--- Build Lua patterns for SGR sequences.
---
--- @param param_charset string Parameter character class.
--- @return string[]
local function sgr_patterns(param_charset)
	local suffix = "%[" .. param_charset .. "m"
	local c1_suffix = param_charset .. "m"

	return {
		-- Actual escape introducers.
		ESC .. suffix,
		CSI_8 .. c1_suffix,

		-- Literal escape representations.
		ESC_033 .. suffix,
		ESC_27 .. suffix,
		ESC_X1B .. suffix,
		ESC_E .. suffix,
		ESC_U001B .. suffix,

		-- Literal 8-bit CSI representations.
		CSI_X9B .. c1_suffix,
		CSI_U009B .. c1_suffix,
	}
end

-- ============================================================================
-- CSI introducer
-- ============================================================================

--- Find the beginning of SGR parameters.
---
--- Supported:
---   ESC [
---   0x9B
---   \27[
---   \033[
---   \x1b[ / \x1B[
---   \e[
---   \u001b[ / \u001B[
---   \x9b[ / \x9B[
---   \u009b[ / \u009B[
---
--- @param value string
--- @return integer|nil
local function get_param_start(value)
	local b1 = str_byte(value, 1)

	-- Actual 8-bit CSI.
	if b1 == 0x9B then
		return 2
	end

	-- Actual 7-bit CSI.
	if b1 == 27 and str_byte(value, 2) == 91 then
		return 3
	end

	if b1 ~= 92 then -- '\'
		return nil
	end

	local b2 = str_byte(value, 2)

	-- Literal "\27["
	if b2 == 50
		and str_byte(value, 3) == 55
		and str_byte(value, 4) == 91
	then
		return 5
	end

	-- Literal "\033["
	if b2 == 48
		and str_byte(value, 3) == 51
		and str_byte(value, 4) == 51
		and str_byte(value, 5) == 91
	then
		return 6
	end

	-- Literal "\x1b[" / "\x1B[" / "\x9b[" / "\x9B["
	if b2 == 120 then
		local value_byte = str_byte(value, 3)
		local hex_byte = str_byte(value, 4)

		if (value_byte == 49 or value_byte == 57)
			and (hex_byte == 98 or hex_byte == 66)
			and str_byte(value, 5) == 91
		then
			return 6
		end

		return nil
	end

	-- Literal "\e["
	if b2 == 101 and str_byte(value, 3) == 91 then
		return 4
	end

	-- Literal "\u001b[" / "\u001B[" / "\u009b[" / "\u009B["
	if b2 == 117 then
		local b3 = str_byte(value, 3)
		local b4 = str_byte(value, 4)
		local b5 = str_byte(value, 5)
		local b6 = str_byte(value, 6)
		local b7 = str_byte(value, 7)

		if b3 == 48
			and b4 == 48
			and (b5 == 49 or b5 == 57)
			and (b6 == 98 or b6 == 66)
			and b7 == 91
		then
			return 8
		end
	end

	return nil
end

-- ============================================================================
-- ANSI / xterm palettes
-- ============================================================================

--- Default xterm 16-color palette.
---
--- The actual terminal palette is implementation-defined and configurable.
--- These values are used as a fallback.
---
--- @type integer[]
local ANSI_COLORS = {
	0x000000, 0xCD0000, 0x00CD00, 0xCDCD00,
	0x0000EE, 0xCD00CD, 0x00CDCD, 0xE5E5E5,
	0x7F7F7F, 0xFF0000, 0x00FF00, 0xFFFF00,
	0x5C5CFF, 0xFF00FF, 0x00FFFF, 0xFFFFFF,
}

--- The six channel levels of the xterm 6x6x6 color cube.
---
--- @type integer[]
local CUBE_LEVELS = { 0, 95, 135, 175, 215, 255 }

--- Convert an xterm 256-color index into packed RGB.
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

		return CUBE_LEVELS[r + 1] * 0x10000
			+ CUBE_LEVELS[g + 1] * 0x100
			+ CUBE_LEVELS[b + 1]
	end

	local gray = 8 + (index - 232) * 10

	return gray * 0x010101
end

-- ============================================================================
-- Numeric readers
-- ============================================================================

--- Read an unsigned decimal integer.
---
--- Consumes every consecutive digit, even when the value exceeds `limit`.
--- Empty fields and out-of-range values return nil.
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

--- Consume consecutive decimal digits without converting the value.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return boolean has_digits
--- @return integer next_index
local function skip_digits(value, index, last)
	local first = index

	while index <= last do
		local b = str_byte(value, index)

		if b < DIGIT_ZERO or b > DIGIT_NINE then
			break
		end

		index = index + 1
	end

	return index > first, index
end

--- Consume an optional numeric field.
---
--- Empty fields are valid. When `limit` is nil, the numeric value is
--- intentionally not converted or range-checked.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @param limit integer|nil
--- @return boolean valid
--- @return integer next_index
local function consume_optional_integer(value, index, last, limit)
	local b = str_byte(value, index)

	-- Empty parameter element.
	if index > last or b == COLON or b == SEMICOLON then
		return true, index
	end

	if limit ~= nil then
		local n
		n, index = read_uint(value, index, last, limit)
		return n ~= nil, index
	end

	local has_digits
	has_digits, index = skip_digits(value, index, last)

	return has_digits, index
end

--- Advance to the next top-level semicolon.
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

-- ============================================================================
-- RGB helpers
-- ============================================================================

--- Pack three 8-bit channels into a 24-bit RGB integer.
---
--- @param r integer|nil
--- @param g integer|nil
--- @param b integer|nil
--- @return integer|nil
local function pack_rgb(r, g, b)
	if r ~= nil and g ~= nil and b ~= nil then
		return r * 0x10000 + g * 0x100 + b
	end

	return nil
end

-- ============================================================================
-- ISO colon-separated color fields
-- ============================================================================
--
-- `index` points at the colon immediately after the color mode.
--
-- Mode 5:
--   N
--
-- Mode 2:
--   CSID:R:G:B[:PE6[:PE7[:PE8]]]
--
-- Legacy compatibility:
--   R:G:B
--
-- The first field of mode 2 is the color-space identifier.
-- It may be empty or numeric and is not used for RGB conversion.
-- ============================================================================

--- Read colon-separated fields following an extended color mode.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @param mode integer
--- @return integer|nil color
--- @return integer next_index
local function read_colon_fields(value, index, last, mode)
	local field_count = 0
	local valid = true

	local f1, f2, f3, f4
	local palette_index

	while index <= last and str_byte(value, index) == COLON do
		index = index + 1
		field_count = field_count + 1

		if mode == 5 then
			if field_count == 1 then
				palette_index, index = read_uint(value, index, last, 255)

				if palette_index == nil then
					valid = false
				end
			else
				valid = false

				local _, next_index = skip_digits(value, index, last)
				index = next_index
			end

		elseif mode == 2 then
			if field_count == 1 then
				-- CSID: empty or numeric.
				-- It is not restricted to the RGB channel range.
				local start = index
				local has_digits

				has_digits, index = skip_digits(value, index, last)

				if has_digits then
					-- Also attempt to interpret it as a channel for
					-- the optional legacy R:G:B shorthand.
					f1 = read_uint(value, start, last, 255)
				end

				if not has_digits
					and index <= last
					and str_byte(value, index) ~= COLON
					and str_byte(value, index) ~= SEMICOLON
				then
					valid = false
				end

			elseif field_count == 2 then
				f2, index = read_uint(value, index, last, 255)

				if f2 == nil then
					valid = false
				end

			elseif field_count == 3 then
				f3, index = read_uint(value, index, last, 255)

				if f3 == nil then
					valid = false
				end

			elseif field_count == 4 then
				f4, index = read_uint(value, index, last, 255)

				if f4 == nil then
					valid = false
				end

			elseif field_count == 5 then
				-- PE6: reserved / unused.
				local ok
				ok, index = consume_optional_integer(value, index, last)

				if not ok then
					valid = false
				end

			elseif field_count == 6 then
				-- PE7: tolerance.
				local ok
				ok, index = consume_optional_integer(value, index, last)

				if not ok then
					valid = false
				end

			elseif field_count == 7 then
				-- PE8: tolerance color space.
				-- 0 = CIELUV, 1 = CIELAB.
				local ok
				ok, index = consume_optional_integer(value, index, last, 1)

				if not ok then
					valid = false
				end

			else
				-- Unsupported extra fields.
				valid = false

				local _, next_index = skip_digits(value, index, last)
				index = next_index
			end

		else
			-- Other ISO color modes are consumed as a complete group,
			-- but cannot be represented by this RGB-only result.
			local _, next_index = skip_digits(value, index, last)
			index = next_index
		end
	end

	-- Leave the next top-level SGR parameter untouched.
	index = skip_to_semicolon(value, index, last)

	if mode == 5 then
		if valid and field_count == 1 then
			return xterm256_to_rgb(palette_index), index
		end

		return nil, index
	end

	if mode == 2 and valid then
		-- Standard form:
		-- CSID:R:G:B, optionally followed by PE6, PE7 and PE8.
		if field_count >= 4 and field_count <= 7 then
			return pack_rgb(f2, f3, f4), index
		end

		-- Non-standard compatibility form:
		-- R:G:B (no CSID field).
		if ALLOW_LEGACY_COLON_RGB and field_count == 3 then
			return pack_rgb(f1, f2, f3), index
		end
	end

	return nil, index
end

-- ============================================================================
-- Colon-separated extended colors
-- ============================================================================

--- Read an extended color using colon subparameters.
---
--- `index` points at the colon after 38/48.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil color
--- @return integer next_index
local function read_colon_color(value, index, last)
	local mode

	mode, index = read_uint(value, index + 1, last, 255)

	if mode == nil then
		return nil, skip_to_semicolon(value, index, last)
	end

	-- The color subparameters must remain colon-separated.
	if str_byte(value, index) == COLON then
		return read_colon_fields(value, index, last, mode)
	end

	-- Modes 0 and 1 do not require additional parameters.
	-- Other modes without their required fields are invalid.
	return nil, index
end

-- ============================================================================
-- Semicolon-separated extended colors
-- ============================================================================
--
-- Legacy xterm syntax:
--
--   38;5;N
--   48;5;N
--
--   38;2;R;G;B
--   48;2;R;G;B
--
-- Also accepts the xterm-compatible hybrid form:
--
--   38;5:N
--   48;5:N
--
--   38;2:CSID:R:G:B
--   48;2:CSID:R:G:B
--
-- Once colon subparameters begin, subsequent fields must use colons.
-- ============================================================================

--- Read a semicolon-separated extended color.
---
--- `index` points at the semicolon after 38/48.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil color
--- @return integer next_index
local function read_semicolon_color(value, index, last)
	local mode

	mode, index = read_uint(value, index + 1, last, 255)

	if mode == nil then
		return nil, index
	end

	local separator = str_byte(value, index)

	-- xterm hybrid syntax:
	-- 38;2:CSID:R:G:B
	-- 38;5:N
	if separator == COLON then
		return read_colon_fields(value, index, last, mode)
	end

	if separator ~= SEMICOLON then
		return nil, index
	end

	-- Number of required fields in legacy semicolon syntax.
	local field_count

	if mode == 5 then
		field_count = 1
	elseif mode == 2 then
		field_count = 3
	else
		-- Unsupported semicolon color mode.
		return nil, index
	end

	local values = {}

	for i = 1, field_count do
		if str_byte(value, index) ~= SEMICOLON then
			return nil, index
		end

		index = index + 1
		values[i], index = read_uint(value, index, last, 255)
	end

	if mode == 5 then
		local palette_index = values[1]

		if palette_index ~= nil then
			return xterm256_to_rgb(palette_index), index
		end

		return nil, index
	end

	return pack_rgb(values[1], values[2], values[3]), index
end

-- ============================================================================
-- ANSI colors
-- ============================================================================

--- Map an ANSI/aixterm parameter to its target and RGB value.
---
--- @param param integer
--- @return "fg"|"bg"|nil kind
--- @return integer|nil color
local function ansi_color(param)
	if param >= 30 and param <= 37 then
		return "fg", ANSI_COLORS[param - 30 + 1]

	elseif param >= 90 and param <= 97 then
		return "fg", ANSI_COLORS[param - 90 + 8 + 1]

	elseif param >= 40 and param <= 47 then
		return "bg", ANSI_COLORS[param - 40 + 1]

	elseif param >= 100 and param <= 107 then
		return "bg", ANSI_COLORS[param - 100 + 8 + 1]
	end

	return nil, nil
end

-- ============================================================================
-- Main SGR parameter parser
-- ============================================================================

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

	-- An empty SGR parameter list is equivalent to SGR 0.
	local pending_empty = index > last

	while index <= last or pending_empty do
		local param

		if index > last then
			param = 0
			pending_empty = false

		elseif str_byte(value, index) == SEMICOLON then
			-- Empty top-level parameter is equivalent to 0.
			param = 0

		else
			param, index = read_uint(value, index, last, 255)
		end

		if param == 38 or param == 48 then
			local separator = str_byte(value, index)
			local color

			if separator == COLON then
				color, index = read_colon_color(value, index, last)

			elseif separator == SEMICOLON then
				color, index = read_semicolon_color(value, index, last)
			end

			-- Only valid colors replace the existing value.
			if color ~= nil then
				if param == 38 then
					fg = color
				else
					bg = color
				end
			end

		else
			-- Do not interpret colon subparameters as independent
			-- top-level SGR attributes (e.g. 4:3).
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

			-- Ignore other parameters and their colon subparameters.
			index = skip_to_semicolon(value, index, last)
		end

		-- Advance to the next top-level SGR parameter.
		if str_byte(value, index) == SEMICOLON then
			index = index + 1

			-- A trailing empty parameter is also a reset.
			if index > last then
				pending_empty = true
			end
		else
			break
		end
	end

	return fg, bg
end

-- ============================================================================
-- Parser source
-- ============================================================================

return {
	patterns = sgr_patterns("[%d;:]*"),

	resolve = function(match)
		local value = match.value
		local len = #value

		if len < 2 or str_byte(value, len) ~= TERMINATOR then
			return nil
		end

		local param_start = get_param_start(value)

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
