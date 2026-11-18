--- Shared utilities for SGR (Select Graphic Rendition) escape sequence parsers.
---
--- @class witch-colors.parsers.sgr.util
local M = {}

local str_byte = string.byte

-- Common SGR byte values.
M.SEMICOLON = 59 -- ';'
M.COLON = 58 -- ':'
M.TERMINATOR = 109 -- 'm'
M.DIGIT_ZERO = 48 -- '0'
M.DIGIT_NINE = 57 -- '9'

-- Escape introducer prefixes (actual byte and common literal representations).
local ESC = "\27"
local ESC_033 = "\\033"
local ESC_27 = "\\27"
local ESC_X1B = "\\x1[bB]"
local ESC_E = "\\e"
local ESC_U001B = "\\u001[bB]"

M.ESC = ESC
M.ESC_033 = ESC_033
M.ESC_27 = ESC_27
M.ESC_X1B = ESC_X1B
M.ESC_E = ESC_E
M.ESC_U001B = ESC_U001B

--- Build Lua patterns for SGR sequences using all supported escape introducers.
---
--- @param param_charset string Character class for SGR parameters, e.g. "[%d;]*"
--- @return string[]
function M.patterns(param_charset)
	local suffix = "%[" .. param_charset .. "m"

	return {
		ESC .. suffix,
		ESC_033 .. suffix,
		ESC_27 .. suffix,
		ESC_X1B .. suffix,
		ESC_E .. suffix,
		ESC_U001B .. suffix,
	}
end

--- Find the beginning of the SGR parameters.
---
--- Supports:
---   - `ESC[`    (actual escape byte)
---   - `\27[`    (literal)
---   - `\033[`   (literal)
---   - `\x1b[` / `\x1B[` (literal)
---   - `\e[`     (literal)
---   - `\u001b[` / `\u001B[` (literal)
---
--- @param value string
--- @return integer|nil position after the introducer, or nil when not found
function M.get_param_start(value)
	local b1 = str_byte(value, 1)

	-- Actual ESC character: ESC[
	if b1 == 27 and str_byte(value, 2) == 91 then -- '['
		return 3
	end

	if b1 ~= 92 then -- '\'
		return nil
	end

	local b2 = str_byte(value, 2)

	-- Literal "\27["
	if b2 == 50 and str_byte(value, 3) == 55 and str_byte(value, 4) == 91 then -- '2','7','['
		return 5
	end

	-- Literal "\033["
	if b2 == 48
		and str_byte(value, 3) == 51
		and str_byte(value, 4) == 51
		and str_byte(value, 5) == 91
	then -- '0','3','3','['
		return 6
	end

	-- Literal "\x1b[" or "\x1B["
	if b2 == 120 then -- 'x'
		local b4 = str_byte(value, 4)
		if str_byte(value, 3) == 49 -- '1'
			and (b4 == 98 or b4 == 66) -- 'b' or 'B'
			and str_byte(value, 5) == 91
		then
			return 6
		end
		return nil
	end

	-- Literal "\e["
	if b2 == 101 and str_byte(value, 3) == 91 then -- 'e','['
		return 4
	end

	-- Literal "\u001b[" or "\u001B["
	if b2 == 117 -- 'u'
		and str_byte(value, 3) == 48 -- '0'
		and str_byte(value, 4) == 48 -- '0'
		and str_byte(value, 5) == 49 -- '1'
	then
		local b6 = str_byte(value, 6)
		if (b6 == 98 or b6 == 66) and str_byte(value, 7) == 91 then -- 'b'/'B','['
			return 8
		end
	end
end

return M

