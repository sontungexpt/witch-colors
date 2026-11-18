# witch-colors

Highlight color values directly in your Neovim editor.

`witch-colors` finds colors in your files — hex codes like `#FF5733`, CSS functions like `rgb()` and `hsl()`, named colors like `red`, Tailwind classes like `bg-blue-500`, and more — and paints them with real background or foreground color so you can see exactly what each color looks like without leaving your editor.

<p align="center">
  <img src="https://img.shields.io/github/license/sontungexpt/witch-colors?color=blue" alt="License">
  <img src="https://img.shields.io/badge/neovim-0.10+-green" alt="Neovim">
</p>

## What it does

Open a CSS, JavaScript, TypeScript, HTML, Vue, or Svelte file and colors are highlighted automatically:

- `#FF5733` → shown with an orange background
- `rgb(255, 87, 51)` → shown with an orange background
- `bg-blue-500` → shown with a blue background
- `var(--primary)` → resolved and shown with its actual color

You can choose how colors appear:
- **Background** — the color text gets a colored background (default)
- **Foreground** — the text itself is colored
- **Ornament** — a small `■` symbol is placed next to the color

## Installation

### lazy.nvim

```lua
{
    "sontungexpt/witch-colors",
    config = function()
        require("witch-colors").setup()
    end,
}
```

### packer.nvim

```lua
use {
    "sontungexpt/witch-colors",
    config = function()
        require("witch-colors").setup()
    end,
}
```

### vim-plug

```vim
Plug 'sontungexpt/witch-colors'
```

```lua
require("witch-colors").setup()
```

Requires Neovim 0.10 or newer.

## Quick start

Add this to your Neovim config (e.g. `init.lua`):

```lua
require("witch-colors").setup()
```

Colors in supported filetypes are now highlighted automatically as you type and scroll.

## Configuration

You can customize how the plugin looks and behaves by passing options to `setup()`:

```lua
require("witch-colors").setup({
    -- How colors are displayed: "bg", "fg", or "ornament"
    style = "bg",

    -- The symbol and position used when style = "ornament"
    ornament = {
        text = "■",
        side = "left", -- "left" or "right"
    },

    -- Filetypes and buffer types to ignore
    excluded = {
        filetypes = { "NvimTree" },
        buftypes = { "terminal" },
    },
})
```

### Common customizations

**Show colors as text color instead of background:**

```lua
require("witch-colors").setup({ style = "fg" })
```

**Show a small symbol next to each color:**

```lua
require("witch-colors").setup({
    style = "ornament",
    ornament = { text = "●", side = "right" },
})
```

**Ignore additional filetypes:**

```lua
require("witch-colors").setup({
    excluded = {
        filetypes = { "NvimTree", "neo-tree", "help" },
    },
})
```

**Update settings later:**

```lua
require("witch-colors").config.override({ style = "fg" })
```

## Supported color formats

The plugin highlights these automatically in CSS, SCSS, Sass, Less, HTML, Vue, Svelte, JavaScript, and TypeScript files:

| Format | Example |
|--------|---------|
| Hex | `#FF5733`, `#FF5733AA`, `0xFF5733` |
| Short hex | `#F53`, `#F53A` |
| RGB / RGBA | `rgb(255, 87, 51)`, `rgba(255 87 51 / 0.5)` |
| HSL / HSLA | `hsl(240 100% 50%)`, `hsla(240, 100%, 50%, 0.5)` |
| Bare HSL (CSS vars) | `--primary: 240 100% 50%;` |
| CSS named colors | `red`, `rebeccapurple`, `aqua` |
| Tailwind CSS | `bg-blue-500`, `text-red-600`, `border-slate-200` |

Optional formats (not enabled by default — turn them on in config):

| Format | Example |
|--------|---------|
| ANSI escape codes | `\033[31m`, `\27[1;34m` |
| Truecolor escape codes | `\033[38;2;255;0;0m` |
| xterm 256-color | `\033[38;5;196m` |

To enable optional formats:

```lua
require("witch-colors").setup({
    parsers = {
        ansi = { enabled = true },
        truecolor = { enabled = true },
        xterm256 = { enabled = true },
    },
})
```

## Commands

There are no commands to remember — highlighting starts automatically when you open a supported file.

If you need to manually refresh the highlights in the current window:

```lua
require("witch-colors").refresh()
```

## License

MIT License — Copyright (c) 2026 Breno Prata.
