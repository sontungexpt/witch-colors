--- Truecolor SGR source.
---
--- @deprecated Use `witch-colors.parsers.sgr` (unified SGR parser) instead.
---
--- Recognizes 24-bit RGB foreground and background color sequences.
---
--- Supported:
---   - Semicolon RGB: `38;2;R;G;B` and `48;2;R;G;B`.
---   - Colon RGB: `38:2::R:G:B` and `48:2::R:G:B`.
---   - Colon RGB with color-space identifier:
---     `38:2:0:R:G:B` and `48:2:0:R:G:B`.
---   - Empty or numeric color-space identifiers.
---   - Multiple foreground and background declarations in one sequence.
---   - Actual ESC bytes and common literal escape representations.
---
--- RGB channels must be integers in the range 0–255.
--- The color-space identifier is parsed but not used.
---
--- Indexed colors (`38;5;N` / `48;5;N`) belong to the xterm256 source.
--- Standard ANSI colors belong to the ANSI source.
--- Unrelated SGR attributes are ignored.
---
--- When a color is declared multiple times, the last valid value wins.

local str_byte = string.byte

local sgr = require("witch-colors.parsers.sgr.util")

local SEMICOLON = sgr.SEMICOLON
local COLON = sgr.COLON
local TERMINATOR = sgr.TERMINATOR
local DIGIT_ZERO = sgr.DIGIT_ZERO
local DIGIT_NINE = sgr.DIGIT_NINE

--- Read an unsigned decimal integer.
---
--- Consumes all consecutive digits, even when the value exceeds the limit.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @param limit integer
--- @return integer|nil result
--- @return integer next_index
local function read_uint(value, index, last, limit)
    local result = 0
    local valid = true
    local first = index

    while index <= last do
        local byte = str_byte(value, index)

        if byte < DIGIT_ZERO or byte > DIGIT_NINE then
            break
        end

        if valid then
            result = result * 10 + byte - DIGIT_ZERO

            if result > limit then
                valid = false
            end
        end

        index = index + 1
    end

    if index == first or not valid then
        return nil, index
    end

    return result, index
end

--- Read a semicolon-separated RGB channel.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil channel
--- @return integer next_index
local function read_semicolon_channel(value, index, last)
    if str_byte(value, index) ~= SEMICOLON then
        return nil, index
    end

    return read_uint(value, index + 1, last, 255)
end

--- Read a colon-separated RGB channel.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil channel
--- @return integer next_index
local function read_colon_channel(value, index, last)
    if str_byte(value, index) ~= COLON then
        return nil, index
    end

    return read_uint(value, index + 1, last, 255)
end

--- Skip the remaining fields of a colon-separated parameter.
---
--- Stops at the next top-level semicolon.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer next_index
local function skip_colon_parameter(value, index, last)
    while index <= last do
        if str_byte(value, index) == SEMICOLON then
            break
        end

        index = index + 1
    end

    return index
end

--- Skip an arbitrary decimal color-space identifier.
---
--- The identifier is intentionally not interpreted.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return boolean success
--- @return integer next_index
local function skip_color_space(value, index, last)
    local first = index

    while index <= last do
        local byte = str_byte(value, index)

        if byte < DIGIT_ZERO or byte > DIGIT_NINE then
            break
        end

        index = index + 1
    end

    if index == first or str_byte(value, index) ~= COLON then
        return false, index
    end

    return true, index + 1
end

--- Read a colon-separated truecolor group.
---
--- Supported forms:
---   38:2::R:G:B
---   48:2::R:G:B
---   38:2:0:R:G:B
---   48:2:0:R:G:B
---
--- The color-space identifier may be empty or numeric.
--- It is parsed but not used.
---
--- @param value string
--- @param index integer Position of the colon after 38 or 48.
--- @param last integer
--- @return integer|nil color
--- @return integer next_index
local function read_colon_truecolor(value, index, last)
    -- Read the color mode.
    local mode
    mode, index = read_uint(value, index + 1, last, 255)

    if mode ~= 2 or str_byte(value, index) ~= COLON then
        return nil, skip_colon_parameter(value, index, last)
    end

    -- Move past the mode separator.
    index = index + 1

    -- Read the optional color-space identifier.
    if str_byte(value, index) == COLON then
        -- Empty color-space identifier.
        index = index + 1
    else
        local success
        success, index = skip_color_space(value, index, last)

        if not success then
            return nil, skip_colon_parameter(value, index, last)
        end
    end

    -- Read the RGB channels.
    local r
    r, index = read_uint(value, index, last, 255)

    local g
    g, index = read_colon_channel(value, index, last)

    local b
    b, index = read_colon_channel(value, index, last)

    if r == nil or g == nil or b == nil then
        return nil, skip_colon_parameter(value, index, last)
    end

    -- The RGB group must end at a top-level separator or sequence end.
    local next_byte = str_byte(value, index)

    if index <= last and next_byte ~= SEMICOLON then
        return nil, skip_colon_parameter(value, index, last)
    end

    return r * 0x10000 + g * 0x100 + b, index
end

--- Read a semicolon-separated truecolor group.
---
--- Supported forms:
---   38;2;R;G;B
---   48;2;R;G;B
---
--- @param value string
--- @param index integer Position of the semicolon after 38 or 48.
--- @param last integer
--- @return integer|nil color
--- @return integer next_index
local function read_semicolon_truecolor(value, index, last)
    -- Read the color mode.
    local mode
    mode, index = read_uint(value, index + 1, last, 255)

    if mode ~= 2 then
        if mode == 5 then
            -- Indexed color: skip its palette index.
            local _
            _, index = read_semicolon_channel(value, index, last)
        end

        return nil, index
    end

    -- Read all three channels.
    -- Continue consuming the group even if a channel is invalid.
    local r
    r, index = read_semicolon_channel(value, index, last)

    local g
    g, index = read_semicolon_channel(value, index, last)

    local b
    b, index = read_semicolon_channel(value, index, last)

    if r == nil or g == nil or b == nil then
        return nil, index
    end

    return r * 0x10000 + g * 0x100 + b, index
end

--- Find truecolor foreground and background values.
---
--- Recognizes only 24-bit RGB color groups:
---   38;2;R;G;B
---   48;2;R;G;B
---   38:2::R:G:B
---   48:2::R:G:B
---   38:2:0:R:G:B
---   48:2:0:R:G:B
---
--- Indexed colors are intentionally ignored.
--- Other SGR attributes are skipped.
---
--- If an attribute occurs multiple times, the last valid RGB value wins.
---
--- @param value string
--- @param index integer
--- @param last integer
--- @return integer|nil fg
--- @return integer|nil bg
local function find_truecolor(value, index, last)
    local fg
    local bg

    while index <= last do
        local param
        param, index = read_uint(value, index, last, 255)

        if param == nil then
            -- Ignore an invalid parameter and continue at its boundary.
            index = skip_colon_parameter(value, index, last)
        elseif param == 38 or param == 48 then
            local color
            local separator = str_byte(value, index)

            if separator == COLON then
                color, index = read_colon_truecolor(value, index, last)
            elseif separator == SEMICOLON then
                color, index = read_semicolon_truecolor(value, index, last)
            end

            if color ~= nil then
                if param == 38 then
                    fg = color
                else
                    bg = color
                end
            end
        elseif str_byte(value, index) == COLON then
            -- Ignore unrelated colon-separated SGR parameters.
            index = skip_colon_parameter(value, index, last)
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



---@type witch-colors.Parser
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

		local fg, bg = find_truecolor(value, param_start, len - 1)
		if fg == nil and bg == nil then
			return nil
		end

		local mark = {
			col_start = match.col_start,
			col_end = match.col_end,
		}

		if fg ~= nil then
			mark.fg = fg
		end

		if bg ~= nil then
			mark.bg = bg
		end

		return mark
	end,
}
