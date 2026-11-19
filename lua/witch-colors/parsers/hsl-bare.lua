--- CSS bare HSL color source.
---
--- Recognizes HSL values without an hsl() wrapper, primarily in
--- CSS custom property declarations.
---
--- Supported:
---   - Signed and decimal hue values.
---   - Hue units: deg, grad, rad, turn, or unitless degrees.
---   - Case-insensitive hue units.
---   - Percentage saturation and lightness.
---   - Optional slash-separated alpha.
---   - Numeric alpha in [0, 1].
---   - Percentage alpha in [0%, 100%].
---   - Out-of-range channels are clamped.
---   - Optional trailing semicolon.
---
--- Examples:
---   --primary: 240 100% 50%;
---   --secondary: 0 84.2% 60.2%;
---   --accent: -120 50% 40%;
---   --transparent: 240 100% 50% / 0.5;
---   --overlay: 240 100% 50% / 50%;
---   --opaque: 240 100% 50% / 1;
---
--- Not supported:
---   - calc(), var(), and none channels.
---   - Comma-separated syntax.
---   - CSS comments inside the value.
---   - Scientific notation.

local str_byte = string.byte
local str_sub = string.sub
local tonumber = tonumber

local min = math.min
local max = math.max
local pi = math.pi

local converters = require("witch-colors.util.converters")
local hsl_to_marked = converters.hsl_to_marked

local util = require("witch-colors.parsers.shared.util")

local PLUS = 43
local MINUS = 45
local DOT = 46
local PERCENT = 37
local SLASH = 47
local SEMICOLON = 59

local HSL_BARE_PATTERN = "%-%-[%w_-]+%s*:%s*[^;}]+"

-- ============================================================================
-- Private helpers
-- ============================================================================

local skip_space = util.skip_space
local is_space = util.is_space

---Trim trailing CSS whitespace.
---@param value string
---@param pos integer
---@return integer
local function trim_end(value, pos)
	while pos > 0 and is_space(str_byte(value, pos)) do
		pos = pos - 1
	end

	return pos
end

---Convert an ASCII uppercase byte to lowercase.
---@param byte integer|nil
---@return integer|nil
local function lower_ascii(byte)
	if byte and byte >= 65 and byte <= 90 then return byte + 32 end

	return byte
end

---Check an ASCII string at a given position, case-insensitively.
---@param value string
---@param pos integer
---@param expected string
---@return boolean
local function match_ascii_ci(value, pos, expected)
	for i = 1, #expected do
		local byte = str_byte(value, pos + i - 1)

		if byte == nil or lower_ascii(byte) ~= str_byte(expected, i) then return false end
	end

	return true
end

---Read a signed decimal number.
---@param value string
---@param pos integer
---@return number|nil number
---@return integer next_pos
local function read_number(value, pos)
	local len = #value
	local start = pos
	local byte = str_byte(value, pos)

	if byte == PLUS or byte == MINUS then pos = pos + 1 end

	local digits = 0

	while pos <= len do
		byte = str_byte(value, pos)

		if byte < 48 or byte > 57 then break end

		digits = digits + 1
		pos = pos + 1
	end

	if str_byte(value, pos) == DOT then
		pos = pos + 1

		local fraction_start = pos

		while pos <= len do
			byte = str_byte(value, pos)

			if byte < 48 or byte > 57 then break end

			pos = pos + 1
		end

		if pos == fraction_start then return nil, start end

		digits = digits + pos - fraction_start
	end

	if digits == 0 then return nil, start end

	local number = tonumber(str_sub(value, start, pos - 1))

	if number == nil then return nil, start end

	return number, pos
end

---Read hue and convert it to degrees.
---@param value string
---@param pos integer
---@return number|nil hue
---@return integer next_pos
local function read_hue(value, pos)
	local hue, next_pos = read_number(value, pos)

	if hue == nil then return nil, pos end

	local byte = lower_ascii(str_byte(value, next_pos))

	if byte == 100 then -- d
		if not match_ascii_ci(value, next_pos, "deg") then return nil, pos end

		next_pos = next_pos + 3
	elseif byte == 103 then -- g
		if not match_ascii_ci(value, next_pos, "grad") then return nil, pos end

		hue = hue * 0.9
		next_pos = next_pos + 4
	elseif byte == 114 then -- r
		if not match_ascii_ci(value, next_pos, "rad") then return nil, pos end

		hue = hue * (180 / pi)
		next_pos = next_pos + 3
	elseif byte == 116 then -- t
		if not match_ascii_ci(value, next_pos, "turn") then return nil, pos end

		hue = hue * 360
		next_pos = next_pos + 4
	end

	return hue % 360, next_pos
end

---Read a percentage channel.
---@param value string
---@param pos integer
---@return number|nil channel [0, 100]
---@return integer next_pos
local function read_percentage(value, pos)
	local number, next_pos = read_number(value, pos)

	if number == nil or str_byte(value, next_pos) ~= PERCENT then return nil, pos end

	return min(100, max(0, number)), next_pos + 1
end

---Read alpha in [0, 1].
---@param value string
---@param pos integer
---@return number|nil alpha
---@return integer next_pos
local function read_alpha(value, pos)
	local number, next_pos = read_number(value, pos)

	if number == nil then return nil, pos end

	if str_byte(value, next_pos) == PERCENT then
		number = number / 100
		next_pos = next_pos + 1
	end

	return min(1, max(0, number)), next_pos
end

-- ============================================================================
-- Parser
-- ============================================================================

---Parse bare HSL(A) channels.
---@param value string
---@return number|nil h
---@return number|nil s
---@return number|nil l
---@return number|nil a
local function parse_hsl_bare(value)
	local len = #value
	local pos = skip_space(value, 1)

	local h, next_pos = read_hue(value, pos)

	if h == nil then return nil end

	pos = skip_space(value, next_pos)

	if pos == next_pos then return nil end

	local s
	s, next_pos = read_percentage(value, pos)

	if s == nil then return nil end

	pos = skip_space(value, next_pos)

	if pos == next_pos then return nil end

	local l
	l, next_pos = read_percentage(value, pos)

	if l == nil then return nil end

	pos = skip_space(value, next_pos)

	local a

	if str_byte(value, pos) == SLASH then
		pos = skip_space(value, pos + 1)

		a, next_pos = read_alpha(value, pos)

		if a == nil then return nil end

		pos = skip_space(value, next_pos)
	end

	if str_byte(value, pos) == SEMICOLON then pos = skip_space(value, pos + 1) end

	if pos <= len then return nil end

	return h, s, l, a
end

-- ============================================================================
-- Source
-- ============================================================================

---@type witch-colors.Parser
return {
	pattern = {
		HSL_BARE_PATTERN,
	},

	resolve = function(_parser, match, _bufnr, _row)
		local value_start = match.value:find(":", 1, true)

		if value_start == nil then return nil end

		-- Skip the colon and whitespace before the HSL value.
		value_start = skip_space(match.value, value_start + 1)

		-- Exclude trailing whitespace from the highlight range.
		local value_end = trim_end(match.value, #match.value)

		if value_start > value_end then return nil end

		local value = str_sub(match.value, value_start, value_end)
		local h, s, l, a = parse_hsl_bare(value)

		if h == nil then return nil end

		-- Convert the match's 0-based column to the value's start column.
		local col_start = match.col_start + value_start - 1

		return {
			color = hsl_to_marked(h, s, l, a),
			col_start = col_start,
			col_end = col_start + #value,
		}
	end,
}
