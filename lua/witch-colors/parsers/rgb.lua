--- CSS RGB color source.
---
--- Supported:
---   - rgb() and rgba() (case-insensitive)
---   - Legacy comma-separated syntax
---   - Modern space-separated syntax
---   - Percentage channels
---   - Mixed number and percentage channels in modern syntax
---   - Signed and decimal channel values
---   - Numeric and percentage alpha
---   - RGB channels clamped to [0, 255]
---   - Alpha clamped to [0, 1]
---   - Alpha preserved in ColorARGBMarked
---
--- Not supported:
---   - calc(), var(), relative color syntax, and none channels
---   - Scientific notation
---   - Trailing decimal points
---   - CSS comments inside the function

local str_sub = string.sub
local str_byte = string.byte
local str_lower = string.lower
local tonumber = tonumber

local huge = math.huge

local converters = require("witch-colors.util.converters")
local rgb_to_marked = converters.rgb_to_marked
local rgba_to_marked = converters.rgba_to_marked

-- Match the complete function name and its balanced parentheses.
local RGB_PATTERN = "[rR][gG][bB][aA]?%b()"

local util = require("witch-colors.parsers.shared.util")

local COMMA = 44
local DOT = 46
local PLUS = 43
local MINUS = 45
local SLASH = 47
local PERCENT = 37
local OPEN = 40
local CLOSE = 41

local ZERO = 48
local NINE = 57

-- ============================================================================
-- Private helpers
-- ============================================================================



---Read one CSS number, optionally followed by `%`.
---
---Accepted forms:
---   - 12
---   - -12
---   - +12.5
---   - .5
---   - -0.5
---
---Scientific notation and trailing decimal points are rejected.
---@param value string
---@param pos integer
---@return number|nil number
---@return boolean is_percentage
---@return integer next_pos
local function read_number(value, pos)
    local len = #value
    local start = pos
    local byte = str_byte(value, pos)

    if byte == PLUS or byte == MINUS then
        pos = pos + 1
    end

    local digits = 0

    while pos <= len do
        byte = str_byte(value, pos)

        if byte < ZERO or byte > NINE then
            break
        end

        digits = digits + 1
        pos = pos + 1
    end

    if str_byte(value, pos) == DOT then
        pos = pos + 1

        local fraction_start = pos

        while pos <= len do
            byte = str_byte(value, pos)

            if byte < ZERO or byte > NINE then
                break
            end

            pos = pos + 1
        end

        if pos == fraction_start then
            return nil, false, start
        end

        digits = digits + pos - fraction_start
    end

    if digits == 0 then
        return nil, false, start
    end

    local number = tonumber(str_sub(value, start, pos - 1))

    -- Reject invalid, NaN, and infinite values.
    if number == nil or number ~= number or number == huge or number == -huge then
        return nil, false, start
    end

    local percentage = str_byte(value, pos) == PERCENT

    if percentage then
        pos = pos + 1
    end

    return number, percentage, pos
end

---Read an RGB channel and convert percentages to the [0, 255] scale.
---
---Clamping and rounding are delegated to the converter.
---@param value string
---@param pos integer
---@return number|nil channel
---@return boolean|nil is_percentage
---@return integer next_pos
local function read_rgb_channel(value, pos)
    local number, percentage, next_pos = read_number(value, pos)

    if number == nil then
        return nil, nil, pos
    end

    if percentage then
        number = number * 255 / 100
    end

    return number, percentage, next_pos
end

---Read alpha and convert it to the [0, 255] scale.
---
---Both numeric and percentage alpha are normalized to the converter's
---expected channel range. Clamping and rounding happen in the converter.
---@param value string
---@param pos integer
---@return number|nil alpha
---@return integer next_pos
local function read_alpha(value, pos)
    local number, percentage, next_pos = read_number(value, pos)

    if number == nil then
        return nil, pos
    end

    if percentage then
        number = number * 255 / 100
    else
        number = number * 255
    end

    return number, next_pos
end

-- ============================================================================
-- Legacy comma-separated syntax
-- ============================================================================

---Parse legacy comma-separated RGB(A) arguments.
---
---All three RGB channels must use the same representation:
---either numbers or percentages.
---@param value string
---@param pos integer
---@param r number
---@param r_percentage boolean
---@return number|nil r
---@return number|nil g
---@return number|nil b
---@return number|nil a
local function parse_legacy(value, pos, r, r_percentage)
    pos = util.skip_space(value, pos)

    if str_byte(value, pos) ~= COMMA then
        return nil
    end

    pos = util.skip_space(value, pos + 1)

    local g, g_percentage, next_pos = read_rgb_channel(value, pos)

    if g == nil or g_percentage ~= r_percentage then
        return nil
    end

    pos = util.skip_space(value, next_pos)

    if str_byte(value, pos) ~= COMMA then
        return nil
    end

    pos = util.skip_space(value, pos + 1)

    local b, b_percentage
    b, b_percentage, next_pos = read_rgb_channel(value, pos)

    if b == nil or b_percentage ~= r_percentage then
        return nil
    end

    pos = util.skip_space(value, next_pos)

    local a

    if str_byte(value, pos) == COMMA then
        pos = util.skip_space(value, pos + 1)

        a, next_pos = read_alpha(value, pos)

        if a == nil then
            return nil
        end

        pos = util.skip_space(value, next_pos)
    end

    if pos <= #value then
        return nil
    end

    return r, g, b, a
end

-- ============================================================================
-- Modern space-separated syntax
-- ============================================================================

---Parse modern space-separated RGB(A) arguments.
---
---Modern syntax allows RGB channels to mix numbers and percentages.
---@param value string
---@param pos integer
---@param r number
---@return number|nil r
---@return number|nil g
---@return number|nil b
---@return number|nil a
local function parse_modern(value, pos, r)
    local g, _, next_pos = read_rgb_channel(value, pos)

    if g == nil then
        return nil
    end

    local had_space
    pos, had_space = util.skip_space(value, next_pos)

    if not had_space then
        return nil
    end

    local b
    b, _, next_pos = read_rgb_channel(value, pos)

    if b == nil then
        return nil
    end

    pos = util.skip_space(value, next_pos)

    local a

    if str_byte(value, pos) == SLASH then
        pos = util.skip_space(value, pos + 1)

        local alpha_next
        a, alpha_next = read_alpha(value, pos)

        if a == nil then
            return nil
        end

        pos = util.skip_space(value, alpha_next)
    end

    if pos <= #value then
        return nil
    end

    return r, g, b, a
end

-- ============================================================================
-- RGB(A) parser
-- ============================================================================

---Parse a complete RGB(A) function.
---
---The input must include the function name and both parentheses.
---@param value string
---@return number|nil r
---@return number|nil g
---@return number|nil b
---@return number|nil a
local function parse_rgb(value)
    local len = #value

    if len < 5 then
        return nil
    end

    local open_pos = 1

    while open_pos <= len and str_byte(value, open_pos) ~= OPEN do
        open_pos = open_pos + 1
    end

    if open_pos > len or str_byte(value, len) ~= CLOSE then
        return nil
    end

    local name_len = open_pos - 1

    if name_len ~= 3 and name_len ~= 4 then
        return nil
    end

    local name = str_lower(str_sub(value, 1, name_len))

    if name ~= "rgb" and name ~= "rgba" then
        return nil
    end

    local args = str_sub(value, open_pos + 1, len - 1)
    local pos = util.skip_space(args, 1)

    if pos > #args then
        return nil
    end

    local r, r_percentage, next_pos = read_rgb_channel(args, pos)

    if r == nil then
        return nil
    end

    local separator_pos, had_space = util.skip_space(args, next_pos)
    local separator = str_byte(args, separator_pos)

    if separator == COMMA then
        return parse_legacy(args, separator_pos, r, r_percentage)
    end

    if had_space then
        return parse_modern(args, separator_pos, r)
    end

    return nil
end

-- ============================================================================
-- Source
-- ============================================================================

---@type witch-colors.Parser
return {
    patterns = { RGB_PATTERN },

    resolve = function(match)
        local r, g, b, a = parse_rgb(match.value)

        if r == nil then
            return nil
        end

        local color

        if a == nil then
            color = rgb_to_marked(r, g, b)
        else
            color = rgba_to_marked(r, g, b, a)
        end

        return {
            color = color,
            col_start = match.col_start,
            col_end = match.col_end,
        }
    end,
}
