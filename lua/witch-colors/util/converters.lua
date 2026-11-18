---@version JIT

local type, tonumber = type, tonumber
local str_find, str_byte, str_sub = string.find, string.byte, string.sub
local floor = math.floor

local bit = bit or require("bit")
local bit_band = bit.band
local bit_rshift = bit.rshift
local bit_tohex = bit.tohex

local M = {}

local RGB_MAX = 0xFFFFFF
local ALPHA_MARKER = 0x100000000
local ALPHA_COLOR_MAX = 0xFFFFFFFF
local ALPHA_FULL = 0xFF
local BYTE_MASK = 0xFF
local HASH = 35 -- '#'

-- bit.tohex: n > 0 -> lowercase, n < 0 -> UPPERCASE
local HEX6 = -6 -- #RRGGBB
local HEX8 = -8 -- #RRGGBBAA

-- Positional multipliers (arithmetic packing avoids signed int32 from BitOp)
local B8 = 0x100
local B16 = 0x10000
local B24 = 0x1000000

-- ============================================================================
-- Private helpers
-- ============================================================================

---Clamp to `[0, 255]` and round half-up. `NaN` becomes `0`.
---@param value number
---@return integer
local function clamp_byte(value)
    if not (value > 0) then return 0 end
    if value >= 255 then return 255 end

    return floor(value + 0.5)
end

---Pack byte channels. Opaque -> `0xRRGGBB`, otherwise `0x1_AARRGGBB`.
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return witch-colors.ColorARGBMarked
local function pack_marked(r, g, b, a)
    if a == ALPHA_FULL then
        return r * B16 + g * B8 + b
    end

    return ALPHA_MARKER + a * B24 + r * B16 + g * B8 + b
end

---Format byte channels as `#RRGGBB` (letter case follows `HEX6`).
---@param r integer
---@param g integer
---@param b integer
---@return string
local function format_hex6(r, g, b)
    return "#" .. bit_tohex(r * B16 + g * B8 + b, HEX6)
end

---Format byte channels as `#RRGGBBAA` (letter case follows `HEX8`).
---Alpha is always written, even when `FF`.
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return string
local function format_hex8(r, g, b, a)
    return "#" .. bit_tohex(r * B24 + g * B16 + b * B8 + a, HEX8)
end

---Convert one hue sector to a `[0, 1]` channel value.
---@param p number
---@param q number
---@param t number
---@return number
local function hue_to_channel(p, q, t)
    if t < 0 then
        t = t + 1
    elseif t > 1 then
        t = t - 1
    end

    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end

    return p
end

---Convert HSL(A) to byte channels without allocating a table.
---@param h number       Hue in degrees (wrapped with `% 360`).
---@param s number       Saturation in `[0, 100]`.
---@param l number       Lightness in `[0, 100]`.
---@param alpha? number  Opacity in `[0, 1]`, default `1`.
---@return integer r
---@return integer g
---@return integer b
---@return integer a
local function hsl_to_bytes(h, s, l, alpha)
    h = (h % 360) / 360
    s = s / 100
    l = l / 100

    local r, g, b

    if s == 0 then
        r, g, b = l, l, l
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q

        r = hue_to_channel(p, q, h + 1 / 3)
        g = hue_to_channel(p, q, h)
        b = hue_to_channel(p, q, h - 1 / 3)
    end

    return
        clamp_byte(r * 255),
        clamp_byte(g * 255),
        clamp_byte(b * 255),
        alpha == nil and ALPHA_FULL or clamp_byte(alpha * 255)
end

---Validate `#RRGGBB` / `#RRGGBBAA` (`#` optional) without allocating.
---@param hex any
---@return integer|nil digits  `6` or `8` (excluding `#`); `nil` if invalid.
---@return integer|nil init    `1`, or `2` when `hex` starts with `#`.
local function scan_hex(hex)
    if type(hex) ~= "string" then
        return nil, nil
    end

    local len = #hex
    local init = 1

    if str_byte(hex, 1) == HASH then
        init = 2
        len = len - 1
    end

    if (len ~= 6 and len ~= 8) or str_find(hex, "[^%x]", init) then
        return nil, nil
    end

    return len, init
end

---Parse `#RRGGBB` / `#RRGGBBAA` (`#` optional) into a plain integer.
---@param hex any
---@return integer|nil value   `0xRRGGBB` (6 digits) or `0xRRGGBBAA` (8 digits).
---@return integer|nil digits  `6` or `8`.
local function parse_hex(hex)
    local digits, init = scan_hex(hex)

    if not digits then
        return nil, nil
    end

    return tonumber(init == 2 and str_sub(hex, 2) or hex, 16), digits
end

---Split a parsed hex integer into byte channels. Alpha is `255` for 6 digits.
---@param value integer
---@param digits integer  `6` or `8`.
---@return integer r
---@return integer g
---@return integer b
---@return integer a
local function unpack_hex(value, digits)
    if digits == 6 then
        return bit_band(bit_rshift(value, 16), BYTE_MASK),
            bit_band(bit_rshift(value, 8), BYTE_MASK),
            bit_band(value, BYTE_MASK),
            ALPHA_FULL
    end

    return bit_band(bit_rshift(value, 24), BYTE_MASK),
        bit_band(bit_rshift(value, 16), BYTE_MASK),
        bit_band(bit_rshift(value, 8), BYTE_MASK),
        bit_band(value, BYTE_MASK)
end

---Split a `ColorARGBMarked` into byte channels.
---@param color any
---@return integer|nil r  `nil` if `color` is invalid.
---@return integer|nil g
---@return integer|nil b
---@return integer|nil a
local function unpack_marked(color)
    if type(color) ~= "number" or color < 0 or color % 1 ~= 0 then
        return nil
    end

    if color <= RGB_MAX then
        return bit_band(bit_rshift(color, 16), BYTE_MASK),
            bit_band(bit_rshift(color, 8), BYTE_MASK),
            bit_band(color, BYTE_MASK),
            ALPHA_FULL
    end

    if color < ALPHA_MARKER or color > ALPHA_MARKER + ALPHA_COLOR_MAX then
        return nil
    end

    local packed = color - ALPHA_MARKER

    return bit_band(bit_rshift(packed, 16), BYTE_MASK),
        bit_band(bit_rshift(packed, 8), BYTE_MASK),
        bit_band(packed, BYTE_MASK),
        bit_band(bit_rshift(packed, 24), BYTE_MASK)
end

---Fill `out` with the channels, or create a new tuple when `out` is nil.
---@param out? witch-colors.RGBA
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return witch-colors.RGBA
local function fill_rgba(out, r, g, b, a)
    if out then
        out[1], out[2], out[3], out[4] = r, g, b, a
        return out
    end

    return { r, g, b, a }
end

-- ============================================================================
-- RGB channels [0, 255]
-- ============================================================================

---Convert RGB channels to a plain `0xRRGGBB` integer.
---
---```lua
---M.rgb_to_marked(255, 128, 0) --> 0xFF8000
---```
---@param r number  Red in `[0, 255]` (clamped, rounded half-up).
---@param g number  Green in `[0, 255]`.
---@param b number  Blue in `[0, 255]`.
---@return witch-colors.ColorARGBMarked color  Always plain RGB (opaque).
---@nodiscard
---@see witch-colors.convert.rgba_to_marked
function M.rgb_to_marked(r, g, b)
    return clamp_byte(r) * B16 + clamp_byte(g) * B8 + clamp_byte(b)
end

---Convert RGB channels to `#RRGGBB` (letter case follows `HEX6`).
---
---```lua
---M.rgb_to_hex(255, 128, 0) --> "#FF8000"
---```
---@param r number  Red in `[0, 255]`.
---@param g number  Green in `[0, 255]`.
---@param b number  Blue in `[0, 255]`.
---@return string hex  `#RRGGBB`.
---@nodiscard
---@see witch-colors.convert.rgba_to_hex
function M.rgb_to_hex(r, g, b)
    return format_hex6(clamp_byte(r), clamp_byte(g), clamp_byte(b))
end

-- ============================================================================
-- RGBA channels [0, 255]
-- ============================================================================

---Convert RGBA channels to `ColorARGBMarked`.
---
---Opaque colors (`a == 255`) become plain `0xRRGGBB`, others `0x1_AARRGGBB`.
---
---```lua
---M.rgba_to_marked(255, 128, 0, 255) --> 0xFF8000
---M.rgba_to_marked(255, 128, 0, 128) --> 0x180FF8000
---```
---@param r number  Red in `[0, 255]`.
---@param g number  Green in `[0, 255]`.
---@param b number  Blue in `[0, 255]`.
---@param a number  Alpha in `[0, 255]`.
---@return witch-colors.ColorARGBMarked color
---@nodiscard
---@see witch-colors.convert.rgb_to_marked
function M.rgba_to_marked(r, g, b, a)
    return pack_marked(clamp_byte(r), clamp_byte(g), clamp_byte(b), clamp_byte(a))
end

---Convert RGBA channels to `#RRGGBBAA` (letter case follows `HEX8`).
---
---Alpha is always written, even when it is `255`.
---
---```lua
---M.rgba_to_hex(255, 128, 0, 128) --> "#FF800080"
---M.rgba_to_hex(255, 128, 0, 255) --> "#FF8000FF"
---```
---@param r number  Red in `[0, 255]`.
---@param g number  Green in `[0, 255]`.
---@param b number  Blue in `[0, 255]`.
---@param a number  Alpha in `[0, 255]`.
---@return string hex  `#RRGGBBAA`.
---@nodiscard
---@see witch-colors.convert.rgb_to_hex
function M.rgba_to_hex(r, g, b, a)
    return format_hex8(clamp_byte(r), clamp_byte(g), clamp_byte(b), clamp_byte(a))
end

-- ============================================================================
-- RGB(A) float channels [0, 1]   ("f" = float; alpha optional)
-- ============================================================================

---Convert float RGB(A) channels to `ColorARGBMarked`.
---
---```lua
---M.rgbaf_to_marked(1, 0.5, 0)      --> 0xFF8000
---M.rgbaf_to_marked(1, 0.5, 0, 0.5) --> 0x180FF8000
---```
---@param r number|nil  Red in `[0, 1]`, default `0`.
---@param g number|nil  Green in `[0, 1]`, default `0`.
---@param b number|nil  Blue in `[0, 1]`, default `0`.
---@param a? number     Alpha in `[0, 1]`, default `1`.
---@return witch-colors.ColorARGBMarked color
---@nodiscard
function M.rgbaf_to_marked(r, g, b, a)
    return pack_marked(
        clamp_byte((r or 0) * 255),
        clamp_byte((g or 0) * 255),
        clamp_byte((b or 0) * 255),
        a == nil and ALPHA_FULL or clamp_byte(a * 255)
    )
end

---Convert float RGB(A) channels to hex.
---
---Returns `#RRGGBB` when `a` is nil, otherwise `#RRGGBBAA`.
---
---```lua
---M.rgbaf_to_hex(1, 0.5, 0)      --> "#FF8000"
---M.rgbaf_to_hex(1, 0.5, 0, 1)   --> "#FF8000FF"
---```
---@param r number|nil  Red in `[0, 1]`, default `0`.
---@param g number|nil  Green in `[0, 1]`, default `0`.
---@param b number|nil  Blue in `[0, 1]`, default `0`.
---@param a? number     Alpha in `[0, 1]`; omit for a 6-digit result.
---@return string hex
---@nodiscard
function M.rgbaf_to_hex(r, g, b, a)
    local rb = clamp_byte((r or 0) * 255)
    local gb = clamp_byte((g or 0) * 255)
    local bb = clamp_byte((b or 0) * 255)

    if a == nil then
        return format_hex6(rb, gb, bb)
    end

    return format_hex8(rb, gb, bb, clamp_byte(a * 255))
end

-- ============================================================================
-- HSL(A)
-- ============================================================================

---Convert HSL(A) to `ColorARGBMarked`.
---
---```lua
---M.hsl_to_marked(30, 100, 50)      --> 0xFF8000
---M.hsl_to_marked(30, 100, 50, 0.5) --> 0x180FF8000
---```
---@param h number       Hue in degrees (wrapped with `% 360`).
---@param s number       Saturation in `[0, 100]`.
---@param l number       Lightness in `[0, 100]`.
---@param alpha? number  Opacity in `[0, 1]`, default `1`.
---@return witch-colors.ColorARGBMarked color
---@nodiscard
---@see witch-colors.convert.hsl_to_hex
---@see witch-colors.convert.hsl_to_rgba
function M.hsl_to_marked(h, s, l, alpha)
    return pack_marked(hsl_to_bytes(h, s, l, alpha))
end

---Convert HSL(A) to hex.
---
---Returns `#RRGGBB` when `alpha` is nil, otherwise `#RRGGBBAA`.
---
---```lua
---M.hsl_to_hex(30, 100, 50)      --> "#FF8000"
---M.hsl_to_hex(30, 100, 50, 0.5) --> "#FF800080"
---```
---@param h number       Hue in degrees (wrapped with `% 360`).
---@param s number       Saturation in `[0, 100]`.
---@param l number       Lightness in `[0, 100]`.
---@param alpha? number  Opacity in `[0, 1]`; omit for a 6-digit result.
---@return string hex
---@nodiscard
---@see witch-colors.convert.hsl_to_marked
function M.hsl_to_hex(h, s, l, alpha)
    local r, g, b, a = hsl_to_bytes(h, s, l, alpha)

    if alpha == nil then
        return format_hex6(r, g, b)
    end

    return format_hex8(r, g, b, a)
end

---Convert HSL(A) to an RGBA tuple.
---
---Pass `out` in hot loops to avoid allocating a new table per call.
---@param h number       Hue in degrees (wrapped with `% 360`).
---@param s number       Saturation in `[0, 100]`.
---@param l number       Lightness in `[0, 100]`.
---@param alpha? number  Opacity in `[0, 1]`, default `1`.
---@param out? witch-colors.RGBA  Table to reuse.
---@return witch-colors.RGBA rgba  `out` when given, otherwise a new table.
---@see witch-colors.convert.hsl_to_marked
function M.hsl_to_rgba(h, s, l, alpha, out)
    local r, g, b, a = hsl_to_bytes(h, s, l, alpha)

    return fill_rgba(out, r, g, b, a)
end

-- ============================================================================
-- Hex string
-- ============================================================================

---Convert `#RRGGBB` / `#RRGGBBAA` (`#` optional, any letter case) to an RGBA tuple.
---
---Alpha is `255` for 6-digit hex. Short forms (`#RGB`, `#RGBA`) are not accepted.
---
---```lua
---M.hex_to_rgba("#FF8000")   --> { 255, 128, 0, 255 }
---M.hex_to_rgba("ff800080")  --> { 255, 128, 0, 128 }
---M.hex_to_rgba("#F80")      --> nil
---```
---@param hex string
---@param out? witch-colors.RGBA  Table to reuse.
---@return witch-colors.RGBA|nil rgba  `nil` if `hex` is invalid.
function M.hex_to_rgba(hex, out)
    local value, digits = parse_hex(hex)

    if not value then
        return nil
    end

    return fill_rgba(out, unpack_hex(value, digits))
end

-- ============================================================================
-- ColorARGBMarked
-- ============================================================================

---Convert `ColorARGBMarked` to an RGBA tuple.
---
---Plain `0xRRGGBB` gives alpha `255`; marker form `0x1_AARRGGBB` gives the
---stored alpha (including `0`).
---
---```lua
---M.marked_to_rgba(0xFF8000)    --> { 255, 128, 0, 255 }
---M.marked_to_rgba(0x180FF8000) --> { 255, 128, 0, 128 }
---M.marked_to_rgba(-1)          --> nil
---```
---@param color witch-colors.ColorARGBMarked
---@param out? witch-colors.RGBA  Table to reuse.
---@return witch-colors.RGBA|nil rgba  `nil` if `color` is not a valid encoding.
function M.marked_to_rgba(color, out)
    local r, g, b, a = unpack_marked(color)

    if not r then
        return nil
    end

    return fill_rgba(out, r, g, b, a)
end

return M
