local type, pairs                = type, pairs
local vim                        = vim
local b, bo                      = vim.b, vim.bo
local islist                     = vim.islist
local list_contains              = vim.list_contains


local M = {}

-- ============================================================================
-- Filetype groups
-- ============================================================================

local CSS_FILETYPES = {
    css = true,
    scss = true,
    sass = true,
    less = true,
    html = true,
    vue = true,
    svelte = true,
}

local SCRIPT_FILETYPES = {
    javascript = true,
    javascriptreact = true,
    typescript = true,
    typescriptreact = true,
}

local css_supported = function(bufnr)
    return CSS_FILETYPES[bo[bufnr].filetype] == true
end

local css_script_supported = function(bufnr)
    local filetype = bo[bufnr].filetype
    return CSS_FILETYPES[filetype] or SCRIPT_FILETYPES[filetype] or false
end

-- ============================================================================
-- Configuration
-- ============================================================================

--- @type witch-colors.Config
local config = {
    style = "bg",

    ornament = {
        text = "■",
        side = "left",
    },

    excluded = {
        filetypes = { "NvimTree" },
        buftypes = {},
        buffer = nil,
    },

    parsers = {
        hex = {
            enabled = true,
            priority = 1,
            patterns = {
                -- 0xRRGGBB
                "%f[%w]0[xX]%x%x%x%x%x%x%f[^%w_-]",

                -- #RRGGBB, #RRGGBBAA
                "%f[#]#%x%x%x%x%x%x%x?%x?%f[^%w_-]",
            },
            resolve = function(match)
                local value = match.value
                local HASH = 35

                local color = value:byte(1) == HASH
                    and value
                    or tonumber(value:sub(3), 16)

                return {
                    color = color,
                    col_start = match.col_start,
                    col_end = match.col_end,
                }
            end,
        },

        short_hex = {
            enabled = true,
            priority = 2,
            patterns = {
                -- #RGB, #RGBA
                "%f[#]#%x%x%x%x?%f[^%w_-]",
            },
        },

        rgb =  {
            path = "witch-colors.parsers.rgb",
            priority = 3,
            enabled = css_script_supported,
        },

        hsl = {
            path = "witch-colors.parsers.hsl",
            priority = 4,
            enabled = css_script_supported,
        },
        hsl_bare = {
            path = "witch-colors.parsers.hsl-bare",
            priority = 5,
            enabled = css_supported,
        },

        css_named = {
            path = "witch-colors.parsers.css-named",
            enabled = css_supported,
            priority = 6,
        },

        ansi = {
            path = "witch-colors.parsers.ansi",
            enabled = false,
            priority = 7,
        },
        truecolor = {
            path = "witch-colors.parsers.truecolor",
            enabled = false,
            priority = 8,
        },
        xterm256 = {
            path = "witch-colors.parsers.xterm256",
            enabled = false,
            priority = 9,
        },
        tailwind = {
            path = "witch-colors.parsers.tailwind",
            enabled = css_script_supported,
            priority = 10,
        },
    },
}

-- ============================================================================
-- Configuration merging
-- ============================================================================

--- Deep-merge `user` into `base`.
---
--- - If `base` is `nil`, `user` is used as-is.
--- - If types differ, `user` replaces `base`.
--- - If both are scalars, `user` replaces `base`.
--- - If both are arrays, `user` completely replaces `base`.
--- - If both are maps, they are merged recursively.
---
--- @param base any The base value.
--- @param user any The value to merge into `base`.
--- @return any merged
local function merge(base, user)
    if base == nil then
        return user
    end

    local base_type = type(base)
    if base_type ~= type(user) then
        return user
    elseif base_type ~= "table" then
        return user
    end

    --- @cast base table
    --- @cast user table

    -- Replace arrays entirely.
    if islist(base) or islist(user) then
        return user
    end

    -- Recursively merge maps.
    for k, v in pairs(user) do
        base[k] = merge(base[k], v)
    end

    return base
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Check whether a buffer is excluded from color processing.
---
--- A buffer is excluded when:
--- - It is invalid.
--- - Its buffer type is listed in user configuration.
--- - Its filetype is listed in user configuration.
--- - The custom buffer exclusion predicate returns true.
---
--- @param bufnr integer Buffer handle.
--- @return boolean
M.is_excluded = function(bufnr)
    local ex = config.excluded
    if ex.buftypes and list_contains(ex.buftypes, bo[bufnr].buftype) then
        return true
    end

    if ex.filetypes and list_contains(ex.filetypes, bo[bufnr].filetype) then
        return true
    end

    if ex.buffer and ex.buffer(bufnr) then
        return true
    end

    return false
end

--- Read-only view of the active configuration.
---
--- Supports field access and iteration through `pairs`.
--- Direct assignment is rejected; use `override(opts)` to apply overrides.
---
--- @type witch-colors.Config
M.current = setmetatable({}, {
    __index = config,

    __newindex = function()
        error("witch-colors config is read-only; call override(opts)")
    end,

    __pairs = function()
        return pairs(config)
    end,

    __metatable = false,
})

--- Apply user configuration overrides.
---
--- Overrides are recursively merged into the existing configuration.
--- Lists replace their previous values, while maps are merged.
--- Invalid type changes preserve the existing configuration value.
---
--- Passing `nil` returns the current read-only configuration without
--- modifying it.
---
--- @param override witch-colors.Config|nil User configuration overrides.
--- @return witch-colors.Config Current read-only configuration.
M.override = function(override)
    if override == nil then
        return M.current
    end

    for k, v in pairs(override) do
        config[k] = merge(config[k], v)
    end

    return M.current
end

return M
