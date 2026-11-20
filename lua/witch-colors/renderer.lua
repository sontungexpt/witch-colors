local type, tostring, tonumber = type, tostring, tonumber
local str_sub, str_byte = string.sub, string.byte
local concat = table.concat

local bit = bit or require("bit")
local band, rshift = bit.band, bit.rshift
local bor, lshift = bit.bor, bit.lshift

local vim = vim
local api = vim.api

local nvim_set_hl = api.nvim_set_hl
local nvim_get_color_by_name = api.nvim_get_color_by_name
local nvim_buf_set_extmark = api.nvim_buf_set_extmark
local nvim_buf_get_extmarks = api.nvim_buf_get_extmarks
local nvim_buf_del_extmark = api.nvim_buf_del_extmark
local nvim_buf_clear_namespace = api.nvim_buf_clear_namespace


-- ============================================================================
-- Constants
-- ============================================================================

local HASH = str_byte("#")

-- Color encoding
local RGB_MAX = 0xFFFFFF
local CHANNEL_MAX = 0xFF
local CHANNEL_MASK = 0xFF
local RGB_MASK = 0xFFFFFF

local RED_SHIFT = 16
local GREEN_SHIFT = 8
local ALPHA_SHIFT = 24

local ALPHA_MARKER = 0x100000000
local ALPHA_COLOR_MAX = 0xFFFFFFFF

local ALPHA_FULL = 0xFF
local ALPHA_ZERO = 0x00

-- Hexadecimal expansion
local HEX_EXPAND_SHIFT = 4

-- Color calculations
local BLEND_ROUND = 0.5

-- WCAG / sRGB
local WCAG_THRESHOLD = 0.179
local SRGB_THRESHOLD = 0.04045
local SRGB_LINEAR = 12.92
local SRGB_OFFSET = 0.055
local SRGB_SCALE = 1.055
local SRGB_EXPONENT = 2.4

local BLACK = 0x000000
local WHITE = 0xFFFFFF

local HL_GROUP_PREFIX = "witch-colors_"
local NAMESPACE_ID = api.nvim_create_namespace("witch-colors")
local NORMAL_HL_GROUP_OPTS = { id = api.nvim_get_hl_id_by_name("Normal") }

local M = {}

-- ============================================================================
-- Caches
-- ============================================================================

--- Parsed color cache: `argb_marked_cache[input] = packed_color|false`.
--- @type table<string, witch-colors.ColorARGBMarked|false>
local argb_marked_cache = {}

--- Resolved color cache: `rgb_cache[packed_color] = rgb|false`.
--- Stores composited RGB; `false` represents an invalid color.
--- Cleared when the Normal background changes.
--- @type table<witch-colors.ColorARGBMarked, witch-colors.ColorRGB|false>
local rgb_cache = {}

--- Highlight group cache: `hl_group_cache[attribute_key] = name`.
--- @type table<string, string>
local hl_group_cache = {}

--- Resolved background color of the Normal highlight group.
--- @type witch-colors.ColorRGB|nil
local normal_bg = nil

api.nvim_create_autocmd("ColorScheme", {
    group = api.nvim_create_augroup("__witch-colors-drawer__", { clear = true }),
    callback = function()
        hl_group_cache = {}
        rgb_cache = {}
        normal_bg = nil
    end,
})

-- ============================================================================
-- Color utilities
-- ============================================================================

--- Refresh the Normal background and invalidate backdrop-dependent colors.
local function update_normal_bg()
    local new_bg = api.nvim_get_hl(0, NORMAL_HL_GROUP_OPTS).bg
        or (vim.o.background == "dark" and BLACK or WHITE)

    if new_bg ~= normal_bg then
        rgb_cache = {}
        normal_bg = new_bg
    end
end

--- Select black or white text for maximum readability against an RGB background.
--- Uses WCAG relative luminance.
--- @param rgb_bg integer Background color in 0xRRGGBB format.
--- @return integer Black or white.
local function readable_foreground(rgb_bg)
    local red = band(rshift(rgb_bg, RED_SHIFT), CHANNEL_MASK) / CHANNEL_MAX
    local green = band(rshift(rgb_bg, GREEN_SHIFT), CHANNEL_MASK) / CHANNEL_MAX
    local blue = band(rgb_bg, CHANNEL_MASK) / CHANNEL_MAX

    local luminance =
        0.2126 * (red <= SRGB_THRESHOLD
            and red / SRGB_LINEAR
            or ((red + SRGB_OFFSET) / SRGB_SCALE) ^ SRGB_EXPONENT)
        + 0.7152 * (green <= SRGB_THRESHOLD
            and green / SRGB_LINEAR
            or ((green + SRGB_OFFSET) / SRGB_SCALE) ^ SRGB_EXPONENT)
        + 0.0722 * (blue <= SRGB_THRESHOLD
            and blue / SRGB_LINEAR
            or ((blue + SRGB_OFFSET) / SRGB_SCALE) ^ SRGB_EXPONENT)

    return luminance > WCAG_THRESHOLD and BLACK or WHITE
end

--- Expand a 4-bit hexadecimal channel into an 8-bit channel.
--- @param nibble integer
--- @return integer
local function expand_nibble(nibble)
    return bor(lshift(nibble, HEX_EXPAND_SHIFT), nibble)
end

--- Parse supported color notation into its packed integer representation.
---
--- Supported:
---   * Named colors and #RRGGBB handled by Neovim.
---   * #RGB
---   * #RGBA
---   * #RRGGBBAA
---
--- Encoding:
---   * 0x000000–0xFFFFFF: opaque RGB.
---   * 0x1_AARRGGBB: marker-prefixed ARGB.
---
--- @param value string
--- @return integer|nil
local function parse_color(value)
    local color = nvim_get_color_by_name(value)
    if color >= 0 then return color end

    if str_byte(value, 1) ~= HASH then return nil end

    local len = #value

    if len == 4 then
        local r = tonumber(str_sub(value, 2, 2), 16)
        local g = tonumber(str_sub(value, 3, 3), 16)
        local b = tonumber(str_sub(value, 4, 4), 16)

        if not (r and g and b) then return nil end

        return bor(
            lshift(expand_nibble(r), RED_SHIFT),
            lshift(expand_nibble(g), GREEN_SHIFT),
            expand_nibble(b)
        )
    end

    if len == 5 then
        local r = tonumber(str_sub(value, 2, 2), 16)
        local g = tonumber(str_sub(value, 3, 3), 16)
        local b = tonumber(str_sub(value, 4, 4), 16)
        local a = tonumber(str_sub(value, 5, 5), 16)

        if not (r and g and b and a) then return nil end

        local rgb = bor(
            lshift(expand_nibble(r), RED_SHIFT),
            lshift(expand_nibble(g), GREEN_SHIFT),
            expand_nibble(b)
        )

        local alpha = expand_nibble(a)
        if alpha == ALPHA_FULL then return rgb end

        return ALPHA_MARKER + alpha * 0x1000000 + rgb
    end

    if len == 9 then
        local rgb = tonumber(str_sub(value, 2, 7), 16)
        local alpha = tonumber(str_sub(value, 8, 9), 16)

        if not (rgb and alpha) then return nil end
        if alpha == ALPHA_FULL then return rgb end

        return ALPHA_MARKER + alpha * 0x1000000 + rgb
    end

    return nil
end

--- Normalize a color string or packed integer.
--- String inputs are parsed and cached.
--- Invalid strings are cached as false.
--- @param color witch-colors.Color
--- @return integer|nil
local function normalize_color(color)
    if type(color) == "number" then
        if color % 1 ~= 0 then return nil end
        return color
    end

    if type(color) ~= "string" then return nil end

    local cached = argb_marked_cache[color]
    if cached == false then return nil end
    if cached ~= nil then return cached end

    local parsed = parse_color(color)
    argb_marked_cache[color] = parsed or false

    return parsed
end

--- Extract alpha and RGB from a packed color.
--- @param color integer
--- @return integer|nil alpha
--- @return integer|nil rgb
local function unpack_color(color)
    if color < 0 then return nil, nil end

    if color <= RGB_MAX then
        return ALPHA_FULL, color
    end

    if color >= ALPHA_MARKER
        and color <= ALPHA_MARKER + ALPHA_COLOR_MAX
    then
        local packed = color - ALPHA_MARKER

        return band(rshift(packed, ALPHA_SHIFT), CHANNEL_MASK),
            band(packed, RGB_MASK)
    end

    return nil, nil
end

--- Composite an RGB color over another RGB color.
--- @param fg integer Foreground RGB.
--- @param bg integer Background RGB.
--- @param alpha number Opacity in [0, 1].
--- @return integer
local function blend(fg, bg, alpha)
    local fr = band(rshift(fg, RED_SHIFT), CHANNEL_MASK)
    local fg_g = band(rshift(fg, GREEN_SHIFT), CHANNEL_MASK)
    local fb = band(fg, CHANNEL_MASK)

    local br = band(rshift(bg, RED_SHIFT), CHANNEL_MASK)
    local bg_g = band(rshift(bg, GREEN_SHIFT), CHANNEL_MASK)
    local bb = band(bg, CHANNEL_MASK)

    local inv = 1 - alpha

    local r = band(fr * alpha + br * inv + BLEND_ROUND, CHANNEL_MASK)
    local g = band(fg_g * alpha + bg_g * inv + BLEND_ROUND, CHANNEL_MASK)
    local b = band(fb * alpha + bb * inv + BLEND_ROUND, CHANNEL_MASK)

    return bor(lshift(r, RED_SHIFT), lshift(g, GREEN_SHIFT), b)
end

--- Resolve a packed color into its final RGB value.
--- Translucent colors are composited against the Normal background.
--- Results, including invalid colors, are cached.
--- @param color witch-colors.ColorARGBMarked
--- @return witch-colors.ColorRGB|nil
local function resolve_color(color)
    local cached = rgb_cache[color]
    if cached == false then return nil end
    if cached ~= nil then return cached end

    local alpha, rgb = unpack_color(color)
    if not alpha then
        rgb_cache[color] = false
        return nil
    end

    --- @cast alpha integer
    --- @cast rgb integer
    --- @cast normal_bg integer

    local resolved

    if alpha == ALPHA_ZERO then
        resolved = normal_bg
    elseif alpha < ALPHA_FULL then
        resolved = blend(rgb, normal_bg, alpha / ALPHA_FULL)
    else
        resolved = rgb
    end

    rgb_cache[color] = resolved
    return resolved
end

-- ============================================================================
-- Highlight resolution
-- ============================================================================

--- Maps supported Neovim highlight attributes to their bit positions.
--- @type table<string, integer>
local HL_ATTR_BITS = {
    --- Color range
    fg = 0,
    bg = 1,
    sp = 2,

    --- string|number range
    blend = 3,

    --- Boolean range
    bold = 4,
    italic = 5,
    underline = 6,
    undercurl = 7,
    underdouble = 8,
    underdotted = 9,
    underdashed = 10,
    strikethrough = 11,
    overline = 12,
    reverse = 13,
    standout = 14,
    nocombine = 15,
    dim = 16,
    blink = 17,
    altfont = 18,
}

local HL_MAX_COLOR_BIT = 2
local HL_MAX_NON_BOOL_BIT = 3

local HL_FG_MASK = lshift(1, 0)

--- Compares values by type, then by native ordering.
--- @param a number|string
--- @param b number|string
--- @return boolean
local function number_string_less(a, b)
    local ta, tb = type(a), type(b)
    return ta == tb and a < b or ta < tb
end

--- Resolve and validate normalized Neovim highlight attributes.
---
--- The core must translate semantic fields such as `color` into `fg` or
--- `bg` before passing marks to the drawer.
---
--- Color attributes and blend are stored with their actual values.
--- Enabled boolean attributes are stored as true and represented in the mask.
--- Disabled boolean attributes are omitted.
---
--- The cache key consists of:
---   1. The attribute mask.
---   2. The values of fg, bg, sp, and blend, when present.
---
--- @param mark witch-colors.RowDecoration
--- @return vim.api.keyset.highlight|nil attrs
--- @return string|nil cache_key
local function resolve_highlight(mark)
    local attrs = {}
    local mask = 0

    ---@type (string|number)[]
    local key_values = {}
    local key_count = 0

    for key, value in pairs(mark) do
        local attr_bit = HL_ATTR_BITS[key]

        if attr_bit ~= nil then
            if attr_bit <= HL_MAX_COLOR_BIT then
                if value ~= "NONE" then
                    local color = normalize_color(value)
                    if color == nil then return nil end

                    value = resolve_color(color)
                    if value == nil then return nil end
                end

                attrs[key] = value
                mask = bor(mask, lshift(1, attr_bit))

                --- Add value to serialization
                key_count = key_count + 1
                key_values[key_count] = value
            elseif attr_bit <= HL_MAX_NON_BOOL_BIT then
                --- All string and number values are passed directly to nvim_set_hl
                --- If user provides invalid values, nvim_set_hl will raise an error

                attrs[key] = value
                mask = bor(mask, lshift(1, attr_bit))

                --- Add value to serialization
                key_count = key_count + 1
                key_values[key_count] = value
            elseif value then
                --- All true boolean values are passed as `true` to nvim_set_hl
                attrs[key] = true
                mask = bor(mask, lshift(1, attr_bit))
            end
        end
    end

    if mask == 0 then return nil end

    local bg = attrs.bg
    if bg ~= nil and bg ~= "NONE" and attrs.fg == nil then
        local fg = readable_foreground(bg)
        mask = bor(mask, HL_FG_MASK)
        attrs.fg = fg

        --- Add value to serialization
        key_count = key_count + 1
        key_values[key_count] = fg
    end

    if key_count > 1 then
        table.sort(key_values, number_string_less)
    end

    --- Add the mask to the end of the key values
    key_count = key_count + 1
    key_values[key_count] = mask

    --- No need to convert value to string here because we only support string and number for key_values

    return attrs, concat(key_values, "_")
end

--- Get or define a highlight group for the complete mark.
--- @param mark witch-colors.RowDecoration
--- @return string|nil
local function define_hl_group(mark)
    local attrs, key = resolve_highlight(mark)
    if not attrs then return nil end
    --- @cast key string

    local cached = hl_group_cache[key]
    if cached then return cached end

    local group = HL_GROUP_PREFIX .. key

    nvim_set_hl(0, group, attrs)
    hl_group_cache[key] = group

    return group
end

-- ============================================================================
-- Rendering
-- ============================================================================

--- Draw a jewelry symbol as inline virtual text.
--- @param bufnr integer
--- @param mark witch-colors.RowDecoration
local function draw_ornament(bufnr, mark)
    local hl_group = define_hl_group(mark)

    local side = mark.ornament_side or "left"
    local text = mark.ornament or ""
    local row = mark.row

    local anchor_col = side == "left" and mark.col_start or mark.col_end

    local existing = nvim_buf_get_extmarks(
        bufnr,
        NAMESPACE_ID,
        { row, anchor_col },
        { row, anchor_col },
        { details = true }
    )

    local existing_count = #existing

    for i = 1, existing_count do
        local details = existing[i][4]
        local virt_text = details and details.virt_text
        local first_chunk = virt_text and virt_text[1]
        local pos = details and details.virt_text_pos

        if first_chunk
            and first_chunk[1] == text
            and first_chunk[2] == hl_group
            and pos == "inline"
        then
            return
        end
    end

    for i = 1, existing_count do
        nvim_buf_del_extmark(bufnr, NAMESPACE_ID, existing[i][1])
    end

    nvim_buf_set_extmark(bufnr, NAMESPACE_ID, row, anchor_col, {
        virt_text_pos = "inline",
        virt_text = { { text, hl_group } },
        hl_mode = "combine",
        strict = false,
    })
end

--- Apply a highlight to the mark's byte range.
--- @param bufnr integer
--- @param mark witch-colors.RowDecoration
local function highlight_span(bufnr, mark)
    local hl_group = define_hl_group(mark)
    if not hl_group then return end

    nvim_buf_set_extmark(bufnr, NAMESPACE_ID, mark.row, mark.col_start, {
        end_col = mark.col_end,
        hl_group = hl_group,
        strict = false,
    })
end

--- Render a single normalized mark.
--- @param bufnr integer
--- @param mark witch-colors.RowDecoration
local function render_decoration(bufnr, mark)
    if mark.ornament and mark.ornament ~= "" then
        draw_ornament(bufnr, mark)
    else
        highlight_span(bufnr, mark)
    end
end

--- Clear extmarks created by this module in the specified buffer range.
--- @param bufnr integer
--- @param start_row? integer
--- @param end_row? integer
function M.clear(bufnr, start_row, end_row)
    nvim_buf_clear_namespace(
        bufnr,
        NAMESPACE_ID,
        start_row or 0,
        end_row or -1
    )
end

--- Render a single mark.
--- @param bufnr integer
--- @param mark witch-colors.RowDecoration
function M.render(bufnr, mark)
    update_normal_bg()
    render_decoration(bufnr, mark)
end

--- Render multiple marks, refreshing Normal only once.
--- @param bufnr integer
--- @param marks witch-colors.RowDecoration[]
function M.render_many(bufnr, marks)
    update_normal_bg()

    for i = 1, #marks do
        render_decoration(bufnr, marks[i])
    end
end

return M
