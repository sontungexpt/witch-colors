
--- CSS HSL color source.
---
--- Supported:
---   - hsl() and hsla(), case-insensitive
---   - Hue: deg, grad, rad, turn, or unitless degrees
---   - Signed and decimal hue values
---   - Scientific notation
---   - Percentage saturation and lightness
---   - Numeric or percentage alpha
---   - Legacy comma-separated syntax
---   - Modern space-separated syntax with optional slash alpha
---   - CSS `none` components in modern syntax
---   - Whitespace around values and separators
---
--- Not supported:
---   - calc(), var(), relative color syntax
---   - CSS comments
---   - Nested functions

local str_match = string.match
local str_sub = string.sub
local str_lower = string.lower
local str_byte = string.byte
local tonumber = tonumber

local min, max = math.min, math.max
local HUGE = math.huge

local hsl_to_marked = require("witch-colors.util.converters").hsl_to_marked
local util = require("witch-colors.parsers.shared.util")

local HSL_PATTERNS = {
    "[hH][sS][lL]%b()",
    "[hH][sS][lL][aA]%b()",
}

-- ============================================================================
-- Type definitions
-- ============================================================================

---@alias HSLSeparator ","|"/"|" "

---@alias HSLTokens string[]
---@alias HSLSeparators HSLSeparator[]

---@class HSLComponents
---@field h number Hue in degrees, normalized to [0, 360).
---@field s number Saturation percentage, clamped to [0, 100].
---@field l number Lightness percentage, clamped to [0, 100].
---@field alpha number|nil Alpha in [0, 1]. Nil represents opaque.

-- ============================================================================
-- Numeric parsing
-- ============================================================================

--- Extract a CSS number from the beginning of a token.
---
--- Supported:
---   12
---   -12
---   +12
---   12.5
---   .5
---   12.
---   1e2
---   -1.5e-2
---
---@param token string
---@return number|nil value
---@return string|nil unit
local function parse_number(token)
    local number = str_match(token, "^[+-]?%d+%.?%d*[eE][+-]?%d+")

    if not number then
        number = str_match(token, "^[+-]?%.%d+[eE][+-]?%d+")
    end

    if not number then
        number = str_match(token, "^[+-]?%d+%.?%d*")
    end

    if not number then
        number = str_match(token, "^[+-]?%.%d+")
    end

    if not number then
        return nil, nil
    end

    local value = tonumber(number)

    if value == nil or value ~= value or value == HUGE or value == -HUGE then
        return nil, nil
    end

    return value, str_lower(str_sub(token, #number + 1))
end

--- Parse a hue component into degrees.
---@param token string
---@return number|nil hue
local function parse_hue(token)
    if str_lower(token) == "none" then
        return 0
    end

    local value, unit = parse_number(token)

    if value == nil or unit == nil then
        return nil
    end

    if unit == "" or unit == "deg" then
        return value
    elseif unit == "grad" then
        return value * 0.9
    elseif unit == "rad" then
        return value * (180 / math.pi)
    elseif unit == "turn" then
        return value * 360
    end

    return nil
end

--- Parse a percentage component.
---@param token string
---@return number|nil value
local function parse_percentage(token)
    if str_lower(token) == "none" then
        return 0
    end

    local value, unit = parse_number(token)

    if value == nil or unit ~= "%" then
        return nil
    end

    return min(100, max(0, value))
end

--- Parse an alpha component.
---@param token string
---@return number|nil alpha
local function parse_alpha(token)
    if str_lower(token) == "none" then
        return 1
    end

    local value, unit = parse_number(token)

    if value == nil or unit == nil then
        return nil
    end

    if unit == "%" then
        value = value / 100
    elseif unit ~= "" then
        return nil
    end

    return min(1, max(0, value))
end

-- ============================================================================
-- Tokenization
-- ============================================================================

--- Tokenize an HSL function body.
---
--- Separators are preserved to distinguish legacy and modern syntax.
---
--- Examples:
---   "120, 50%, 50%"       -> { "120", "50%", "50%" }, { ",", "," }
---   "120 50% 50%"         -> { "120", "50%", "50%" }, { " ", " " }
---   "120 50% 50% / 0.5"   -> { "120", "50%", "50%", "0.5" }, { " ", " ", "/" }
---
---@param body string
---@return HSLTokens|nil tokens
---@return HSLSeparators|nil separators
local function tokenize(body)
    local tokens = {}
    local separators = {}

    local len = #body
    local pos = 1

    while pos <= len do
        -- Skip leading whitespace.
        while pos <= len and util.is_space(str_byte(body, pos)) do
            pos = pos + 1
        end

        if pos > len then
            break
        end

        -- Read the next component.
        local start = pos

        while pos <= len do
            local byte = str_byte(body, pos)

            if util.is_space(byte) or byte == 44 or byte == 47 then
                break
            end

            pos = pos + 1
        end

        if start == pos then
            return nil, nil
        end

        tokens[#tokens + 1] = str_sub(body, start, pos - 1)

        if pos > len then
            break
        end

        -- Consume whitespace.
        local had_space = false

        while pos <= len and util.is_space(str_byte(body, pos)) do
            had_space = true
            pos = pos + 1
        end

        if pos > len then
            break
        end

        local byte = str_byte(body, pos)
        local separator

        if byte == 44 then
            separator = ","
            pos = pos + 1
        elseif byte == 47 then
            separator = "/"
            pos = pos + 1
        elseif had_space then
            separator = " "
        else
            return nil, nil
        end

        -- Skip whitespace after explicit separators.
        if separator ~= " " then
            while pos <= len and util.is_space(str_byte(body, pos)) do
                pos = pos + 1
            end
        end

        -- Reject trailing and repeated explicit separators.
        if pos > len then
            return nil, nil
        end

        local next_byte = str_byte(body, pos)

        if next_byte == 44 or next_byte == 47 then
            return nil, nil
        end

        separators[#separators + 1] = separator
    end

    if #tokens < 3 then
        return nil, nil
    end

    return tokens, separators
end

-- ============================================================================
-- HSL parsing
-- ============================================================================

--- Parse CSS HSL syntax.
---
---@param value string
---@return number|nil h Hue in degrees.
---@return number|nil s Saturation percentage.
---@return number|nil l Lightness percentage.
---@return number|nil alpha Alpha in [0, 1], or nil when opaque.
local function parse_hsl(value)
    -- CSS does not allow whitespace between the function name and "(".
    local name, body = str_match(value, "^%s*([%a]+)%(([^()]*)%)%s*$")

    if name == nil or body == nil then
        return nil, nil, nil, nil
    end

    name = str_lower(name)

    if name ~= "hsl" and name ~= "hsla" then
        return nil, nil, nil, nil
    end

    local tokens, separators = tokenize(body)

    if tokens == nil or separators == nil then
        return nil, nil, nil, nil
    end

    local count = #tokens
    local separator_count = #separators

    if (count ~= 3 and count ~= 4) or separator_count ~= count - 1 then
        return nil, nil, nil, nil
    end

    local has_alpha = count == 4

    -- Legacy comma-separated syntax.
    local legacy = separators[1] == ","

    if legacy then
        if separators[2] ~= "," then
            return nil, nil, nil, nil
        end

        if has_alpha and separators[3] ~= "," then
            return nil, nil, nil, nil
        end

        -- `none` is not supported in legacy syntax.
        for i = 1, count do
            if str_lower(tokens[i]) == "none" then
                return nil, nil, nil, nil
            end
        end
    else
        -- Modern space-separated syntax.
        if separators[1] ~= " " or separators[2] ~= " " then
            return nil, nil, nil, nil
        end

        if has_alpha then
            if separators[3] ~= "/" then
                return nil, nil, nil, nil
            end
        elseif separator_count ~= 2 then
            return nil, nil, nil, nil
        end
    end

    local h = parse_hue(tokens[1])
    local s = parse_percentage(tokens[2])
    local l = parse_percentage(tokens[3])

    if h == nil or s == nil or l == nil then
        return nil, nil, nil, nil
    end

    local alpha

    if has_alpha then
        alpha = parse_alpha(tokens[4])

        if alpha == nil then
            return nil, nil, nil, nil
        end
    end

    return h % 360, s, l, alpha
end

-- ============================================================================
-- Source
-- ============================================================================

---@type witch-colors.Parser
return {
    pattern = HSL_PATTERNS,

    resolve = function(_parser, match, _bufnr, _row)
        local h, s, l, alpha = parse_hsl(match.value)
        if h == nil or s == nil or l == nil then
            return nil
        end

        return {
            color = hsl_to_marked(h, s, l, alpha),
            col_start = match.col_start,
            col_end = match.col_end,
        }
    end,
}
