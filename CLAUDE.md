# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is Jimmy's personal Neovim configuration. Jimmy is learning Neovim, coming from VSCode. The config is intentionally minimal and beginner-friendly.

## Config Structure

- `init.lua` - Single-file configuration containing all settings, plugins, and keymaps
- `tips.txt` - Curated tips and keybindings for learning (displayed randomly in shell startup)
- Plugin data stored in `~/.local/share/nvim/lazy/` (not in this repo)

## Key Design Decisions

- **Terminal colors**: Uses `termguicolors = false` to inherit terminal theme
- **Leader key**: Space
- **Plugin manager**: lazy.nvim (bootstraps automatically on first run)
- **Single file**: Everything in `init.lua` for simplicity, no `lua/` directory structure

## Installed Plugins

- toggleterm.nvim - Terminal toggle (`Ctrl+\`)
- telescope.nvim - Fuzzy finder (`Space+f*`)
- nvim-lspconfig - LSP (Python/pyright configured)
- nvim-cmp - Autocomplete
- which-key.nvim - Keybinding hints (300ms delay)

## Custom Keybindings

| Keys | Action |
|------|--------|
| `Space ff/fg/fb/fr` | Find files/grep/buffers/recent |
| `Space w/q/e` | Save/quit/explorer |
| `Space rn/ca` | LSP rename/code actions |
| `Ctrl+h/j/k/l` | Window navigation (works in terminal) |
| `Ctrl+\` | Toggle terminal |
| `gd/gr/K` | Go to definition/references/hover |

## When Modifying This Config

1. Keep changes in `init.lua` - don't create separate files unless necessary
2. After adding plugins or keybindings, update `tips.txt` with new entries
3. Maintain beginner-friendly comments
4. Test that terminal colors still match after plugin changes
