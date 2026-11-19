-- ============================================================================
-- Unified SGR color parser
--
-- Targets:
--   38 = foreground (fg)
--   48 = background (bg)
--   58 = underline color (sp)
--
-- ANSI:
--   30-37, 40-47
--   90-97, 100-107 (aixterm extension)
--
-- Indexed:
--   38;5;N / 48;5;N
--   38:5:N / 48:5:N
--
-- Truecolor:
--   38;2;R;G;B / 48;2;R;G;B
--   38:2::R:G:B / 48:2::R:G:B
--   38:2:CSID:R:G:B / 48:2:CSID:R:G:B
--
-- Compatibility forms:
--   38:2:R:G:B (legacy shorthand)
--   38;5:N
--   38;2:CSID:R:G:B
--
-- Optional ISO modes:
--   3 = CMY
--   4 = CMYK
--
-- Color modes:
--   0 = implementation-defined; ignored
--   1 = transparent; represented as "NONE"
--   2 = RGB
--   3 = CMY
--   4 = CMYK
--   5 = indexed
--
-- Resets:
--   0  = fg + bg + sp
--   39 = fg
--   49 = bg
--   59 = sp
--
-- Other SGR attributes are ignored.
-- This source returns only witch-colors.DecorationWithColor.
-- ============================================================================

local byte = string.byte
local char = string.char
local floor = math.floor

-- ============================================================================
-- Internal configuration
-- ============================================================================

-- Non-standard colon RGB shorthand: 38:2:R:G:B.
local ALLOW_LEGACY_COLON_RGB = true

-- Mixed xterm/ISO separators: 38;2:CSID:R:G:B.
local ALLOW_MIXED_SEPARATORS = true

-- Raw 0x9B can be a UTF-8 continuation byte.
-- Keep disabled for UTF-8 buffers.
local ACCEPT_RAW_C1_BYTE = false

-- CMY/CMYK conversion assumes 8-bit components and an ordinary CMY/CMYK
-- interpretation. It does not apply profile-specific CSID scaling/offsets.
local CONVERT_CMY_CMYK = false

-- ============================================================================
-- Constants
-- ============================================================================

local SEMICOLON = 59
local COLON = 58
local TERMINATOR = 109

local DIGIT_ZERO = 48
local DIGIT_NINE = 57

local ESC = char(0x1B)
local CSI_UTF8 = char(0xC2, 0x9B)

-- ============================================================================
-- Introducers and patterns
-- ============================================================================

-- Keep all supported introducers in one registry.
-- The same registry generates patterns and parameter offsets.

local INTRODUCERS = {
	ESC .. "[",
	CSI_UTF8,

	"\\033[",
	"\\027[",
	"\\27[",

	"\\x1b[",
	"\\x1B[",

	"\\e[",
	"\\E[",

	"\\u001b[",
	"\\u001B[",

	"\\u{1b}[",
	"\\u{1B}[",

	"\\x{1b}[",
	"\\x{1B}[",

	"^[[",

	-- Literal 8-bit CSI representations.
	-- C1 CSI does not require a following '['.
	"\\x9b",
	"\\x9B",

	"\\u009b",
	"\\u009B",

	"\\u{9b}",
	"\\u{9B}",

	"\\x{9b}",
	"\\x{9B}",
}

if ACCEPT_RAW_C1_BYTE then
	INTRODUCERS[#INTRODUCERS + 1] = char(0x9B)
end

--- Escape a literal string for use inside a Lua pattern.
---
--- Executed only during module initialization.
---
--- @param value string
--- @return string
local function escape_pattern(value)
	return (value:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

local patterns = {}

-- Pattern -> parameter start offset.
--
-- resolve() receives match.pattern through witch-colors.PatternMatch.
-- This avoids scanning all introducers again for every match.
local PARAM_START_BY_PATTERN = {}

for i = 1, #INTRODUCERS do
	local introducer = INTRODUCERS[i]
	local pattern = escape_pattern(introducer) .. "[0-9;:]*m"

	patterns[i] = pattern
	PARAM_START_BY_PATTERN[pattern] = #introducer + 1
end

-- ============================================================================
-- Palette
-- ============================================================================

-- Default xterm 16-color palette.
--
-- These are fallback RGB values, not the user's actual terminal palette.
-- Keep this private: custom palette mutation is not part of witch-colors.Parser.

local ANSI_COLORS = {
	0x000000, 0xCD0000, 0x00CD00, 0xCDCD00,
	0x0000EE, 0xCD00CD, 0x00CDCD, 0xE5E5E5,
	0x7F7F7F, 0xFF0000, 0x00FF00, 0xFFFF00,
	0x5C5CFF, 0xFF00FF, 0x00FFFF, 0xFFFFFF,
}

local CUBE_LEVELS = {
	0, 95, 135, 175, 215, 255,
}

--- Convert an xterm 256-color index to packed RGB.
---
--- @param index integer
--- @return integer
local function palette_to_rgb(index)
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
--- Consumes all consecutive digits, including out-of-range values.
--- Empty fields and values above limit return nil.
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
		local b = byte(value, index)

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

--- Skip consecutive decimal digits without converting them.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return boolean has_digits
--- @return integer next_index
local function skip_digits(value, index, last)
	local first = index

	while index <= last do
		local b = byte(value, index)

		if b < DIGIT_ZERO or b > DIGIT_NINE then
			break
		end

		index = index + 1
	end

	return index > first, index
end

--- Consume an optional integer.
---
--- Empty fields are valid.
--- When present, the value must not exceed limit.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @param limit integer|nil Optional upper bound; nil accepts any unsigned integer.
--- @return boolean valid
--- @return integer next_index
local function read_optional_uint(value, index, last, limit)
	local b = byte(value, index)

	-- An omitted optional PE is the default value.
	if index > last or b == COLON or b == SEMICOLON then
		return true, index
	end

	if limit ~= nil then
		local n
		n, index = read_uint(value, index, last, limit)
		return n ~= nil, index
	end

	-- PE6 is reserved and PE7 is an integer tolerance. Their values are
	-- not needed here, but a present field must still contain decimal digits.
	local has_digits
	has_digits, index = skip_digits(value, index, last)
	return has_digits, index
end

--- Skip to the next top-level semicolon.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer
local function skip_to_semicolon(value, index, last)
	while index <= last and byte(value, index) ~= SEMICOLON do
		index = index + 1
	end

	return index
end

-- ============================================================================
-- RGB conversion
-- ============================================================================

--- Pack 8-bit RGB channels into 0xRRGGBB.
---
--- @param r integer
--- @param g integer
--- @param b integer
--- @return integer
local function pack_rgb(r, g, b)
	return r * 0x10000 + g * 0x100 + b
end

--- Round a positive numeric value to the nearest integer.
---
--- @param value number
--- @return integer
local function round(value)
	return floor(value + 0.5)
end

--- Convert direct color modes.
---
--- Mode 2 = RGB.
--- Mode 3 = CMY.
--- Mode 4 = CMYK.
---
--- CMY/CMYK conversions assume 8-bit components.
--- CSID-specific profile scaling is not applied.
---
--- @param mode integer
--- @param a integer
--- @param b integer
--- @param c integer
--- @param d integer|nil
--- @return integer|nil
local function direct_color(mode, a, b, c, d)
	if a == nil or b == nil or c == nil then
		return nil
	end

	if mode == 2 then
		return pack_rgb(a, b, c)
	end

	if mode == 3 then
		return pack_rgb(
			255 - a,
			255 - b,
			255 - c
		)
	end

	if mode == 4 and d ~= nil then
		local k = 1 - d / 255

		return pack_rgb(
			round(255 * (1 - a / 255) * k),
			round(255 * (1 - b / 255) * k),
			round(255 * (1 - c / 255) * k)
		)
	end

	return nil
end

-- ============================================================================
-- Colon-separated extended colors
-- ============================================================================

-- The first field is CSID.
--
-- RGB:
--   CSID:R:G:B[:PE6[:PE7[:PE8]]]
--
-- CMY:
--   CSID:C:M:Y[:PE6[:PE7[:PE8]]]
--
-- CMYK:
--   CSID:C:M:Y:K[:PE7[:PE8]]
--
-- CSID is accepted as empty or numeric.
-- PE6 and PE7 are consumed but not used.
-- PE8, when supplied, must be empty, 0 or 1.

--- Read an ISO colon-separated extended-color group.
---
--- `index` points at the colon after the mode.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @param mode integer
--- @return integer|string|nil color
--- @return integer next_index
local function read_colon_fields(value, index, last, mode)
	local field_count = 0
	local valid = true

	local csid_rgb
	local palette_index

	local a, b, c, d

	local required_fields

	if mode == 2 or mode == 3 then
		required_fields = 4
	elseif mode == 4 then
		required_fields = 5
	end

	while index <= last and byte(value, index) == COLON do
		index = index + 1
		field_count = field_count + 1

		if mode == 5 then
			-- Indexed color: exactly one palette field.
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

		elseif required_fields ~= nil then
			if field_count == 1 then
				-- CSID: numeric or empty.
				-- It is not restricted to the RGB channel range.
				local start = index
				local has_digits

				has_digits, index = skip_digits(value, index, last)

				-- Retained only for legacy RGB shorthand.
				if has_digits and mode == 2 then
					csid_rgb = read_uint(value, start, last, 255)
				end

			elseif field_count >= 2 and field_count <= required_fields then
				local channel
				channel, index = read_uint(value, index, last, 255)

				if channel == nil then
					valid = false
				end

				if field_count == 2 then
					a = channel
				elseif field_count == 3 then
					b = channel
				elseif field_count == 4 then
					c = channel
				elseif field_count == 5 then
					d = channel
				end

			elseif (mode == 4 and field_count == 6)
				or (mode ~= 4 and (field_count == 5 or field_count == 6)) then
				-- PE6 is reserved for RGB/CMY; PE7 is tolerance.
				-- For CMYK, field 5 is K, so field 6 is PE7.
				local ok

				ok, index = read_optional_uint(value, index, last, nil)

				if not ok then
					valid = false
				end

			elseif field_count == 7 then
				-- PE8: tolerance color space.
				-- 0 = CIELUV, 1 = CIELAB.
				local ok

				ok, index = read_optional_uint(value, index, last, 1)

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
			-- Modes not converted by this source are still consumed as a
			-- complete colon group so their subparameters cannot leak into
			-- the main SGR parameter parser.
			local _, next_index = skip_digits(value, index, last)
			index = next_index
		end
	end

	-- Preserve the next top-level SGR parameter.
	index = skip_to_semicolon(value, index, last)

	-- Indexed color.
	if mode == 5 then
		if valid and field_count == 1 then
			return palette_to_rgb(palette_index), index
		end

		return nil, index
	end

	-- Implementation-defined color: no RGB conversion.
	if mode == 0 then
		return nil, index
	end

	-- Transparent color.
	-- witch-colors.Decoration supports the explicit "NONE" value.
	if mode == 1 then
		if field_count == 0 then
			return "NONE", index
		end

		return nil, index
	end

	if not valid then
		return nil, index
	end

	-- RGB.
	if mode == 2 then
		-- Standard ISO representation:
		-- CSID:R:G:B[:PE6[:PE7[:PE8]]]
		if field_count >= 4 and field_count <= 7 then
			return pack_rgb(a, b, c), index
		end

		-- Legacy shorthand:
		-- R:G:B
		if ALLOW_LEGACY_COLON_RGB and field_count == 3 then
			if csid_rgb ~= nil and a ~= nil and b ~= nil then
				return pack_rgb(csid_rgb, a, b), index
			end
		end

		return nil, index
	end

	-- CMY.
	if mode == 3 then
		if CONVERT_CMY_CMYK and field_count >= 4 and field_count <= 7 then
			return direct_color(mode, a, b, c), index
		end

		return nil, index
	end

	-- CMYK.
	if mode == 4 then
		if CONVERT_CMY_CMYK and field_count >= 5 and field_count <= 7 then
			return direct_color(mode, a, b, c, d), index
		end

		return nil, index
	end

	-- Unsupported ISO color mode.
	return nil, index
end

-- ============================================================================
-- Extended color reader
-- ============================================================================

-- Shared by foreground, background and underline color.
--
-- `index` points just after parameter 38, 48 or 58.

--- Read an extended color group.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|string|nil color
--- @return integer next_index
local function read_extended_color(value, index, last)
	local separator = byte(value, index)

	if separator ~= COLON and separator ~= SEMICOLON then
		return nil, index
	end

	local mode
	mode, index = read_uint(value, index + 1, last, 255)

	if mode == nil then
		return nil, skip_to_semicolon(value, index, last)
	end

	local next_separator = byte(value, index)

	-- ISO colon syntax or the optional mixed-separator compatibility form.
	if next_separator == COLON then
		if separator == SEMICOLON and not ALLOW_MIXED_SEPARATORS then
			return nil, skip_to_semicolon(value, index, last)
		end

		return read_colon_fields(value, index, last, mode)
	end

	-- ISO modes 0 and 1 do not require additional parameter elements.
	-- These modes are only accepted with the colon introducer.
	if separator == COLON then
		if mode == 0 and (next_separator == SEMICOLON or index > last) then
			return nil, index
		elseif mode == 1 and (next_separator == SEMICOLON or index > last) then
			return "NONE", index
		end

		return nil, skip_to_semicolon(value, index, last)
	end

	-- xterm semicolon syntax.
	if next_separator ~= SEMICOLON then
		return nil, index
	end

	local arity

	if mode == 5 then
		arity = 1
	elseif mode == 2 then
		arity = 3
	else
		-- Unknown semicolon mode.
		-- Do not guess its field count.
		return nil, index
	end

	local a, b, c
	local valid = true

	for i = 1, arity do
		if byte(value, index) ~= SEMICOLON then
			return nil, index
		end

		index = index + 1

		local channel
		channel, index = read_uint(value, index, last, 255)

		if channel == nil then
			valid = false
		end

		if i == 1 then
			a = channel
		elseif i == 2 then
			b = channel
		elseif i == 3 then
			c = channel
		end
	end

	-- A colon after the final field is not part of the semicolon form.
	if index <= last and byte(value, index) ~= SEMICOLON then
		return nil, skip_to_semicolon(value, index, last)
	end

	if not valid then
		return nil, index
	end

	if mode == 5 then
		return palette_to_rgb(a), index
	end

	return pack_rgb(a, b, c), index
end

-- ============================================================================
-- ANSI colors
-- ============================================================================

--- Resolve an ANSI/aixterm parameter.
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
-- Main SGR scanner
-- ============================================================================

--- Resolve foreground, background and underline colors.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|string|nil fg
--- @return integer|string|nil bg
--- @return integer|string|nil sp
local function find_colors(value, index, last)
	local fg, bg, sp

	-- An empty SGR parameter list is equivalent to 0.
	local pending_empty = index > last

	while index <= last or pending_empty do
		local param

		if index > last then
			param = 0
			pending_empty = false

		elseif byte(value, index) == SEMICOLON then
			-- Empty top-level parameter.
			param = 0

		else
			param, index = read_uint(value, index, last, 255)
		end

		if param == 38 or param == 48 or param == 58 then
			local color
			color, index = read_extended_color(value, index, last)

			if color ~= nil then
				if param == 38 then
					fg = color
				elseif param == 48 then
					bg = color
				else
					sp = color
				end
			end

		elseif param ~= nil and byte(value, index) ~= COLON then
			if param == 0 then
				fg, bg, sp = nil, nil, nil

			elseif param == 39 then
				fg = nil

			elseif param == 49 then
				bg = nil

			elseif param == 59 then
				sp = nil

			else
				local kind, color = ansi_color(param)

				if kind == "fg" then
					fg = color
				elseif kind == "bg" then
					bg = color
				end
			end
		end

		-- Ignore other SGR parameters and their colon subparameters.
		index = skip_to_semicolon(value, index, last)

		if byte(value, index) == SEMICOLON then
			index = index + 1

			-- A trailing empty parameter is also equivalent to 0.
			if index > last then
				pending_empty = true
			end
		else
			break
		end
	end

	return fg, bg, sp
end

-- ============================================================================
-- Parser source
-- ============================================================================

---@type witch-colors.Parser
return {
	patterns = patterns,

	---@param match witch-colors.PatternMatch
	---@param _row integer
	---@return witch-colors.DecorationWithColor|nil
	resolve = function(match, _row)
		local value = match.value
		local len = #value

		if len < 2 or byte(value, len) ~= TERMINATOR then
			return nil
		end

		-- O(1) lookup using the pattern supplied by PatternMatch.
		local param_start = PARAM_START_BY_PATTERN[match.pattern]

		if not param_start then
			return nil
		end

		local fg, bg, sp = find_colors(value, param_start, len - 1)

		if fg == nil and bg == nil and sp == nil then
			return nil
		end

		return {
			col_start = match.col_start,
			col_end = match.col_end,
			fg = fg,
			bg = bg,
			sp = sp,
		}
	end,
}
