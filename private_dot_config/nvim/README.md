# Neovim

Single-file config (`init.lua`) with [lazy.nvim](https://github.com/folke/lazy.nvim). Catppuccin Mocha, transparent background.

## LSP

Uses Neovim 0.11+ native API (`vim.lsp.enable`). Servers auto-installed via Mason:

rust-analyzer, gopls, pyright, ts_ls, clangd, bashls

Formatters: rustfmt, black, ruff, prettier

## Plugins

**Editor** — treesitter, nvim-cmp, LuaSnip, autopairs, Comment.nvim, nvim-surround, spectre, todo-comments

**Navigation** — telescope, nvim-tree, project.nvim

**Git** — gitsigns, lazygit, diffview, git-conflict

**UI** — catppuccin, lualine, barbar, noice, nvim-notify, dressing, indent-blankline, rainbow-delimiters, nvim-colorizer, neoscroll, alpha-nvim

**Tools** — toggleterm, nvim-dap + dap-ui, persistence.nvim, which-key

## Key Bindings

Leader: `<Space>`

| Key | Action |
|---|---|
| `<leader>e` | File explorer |
| `<leader>ff/fg/fb` | Find files / grep / buffers |
| `<leader>fp` | Projects |
| `gd` / `gr` / `K` | Definition / references / hover |
| `<leader>rn` / `<leader>ca` | Rename / code action |
| `<leader>gg` | LazyGit |
| `<leader>gb` | Toggle line blame |
| `<leader>gd` | Diffview |
| `<leader>xx` | Diagnostics (Trouble) |
| `<leader>db` | Toggle breakpoint |
| `<leader>sr` | Find & replace (Spectre) |
| `<C-\>` | Toggle terminal |
| `<Tab>` / `<S-Tab>` | Next / prev buffer |
| `<leader>q` | Close buffer |
