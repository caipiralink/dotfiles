-- ═══════════════════════════════════════════════════════════════
--  Global Settings
-- ═══════════════════════════════════════════════════════════════
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true

_G.statuscolumn_both = function()
  local line = vim.v.lnum
  local curline = vim.fn.line(".")
  local relnum = math.abs(line - curline)
  return string.format("%3d %3d ", line, relnum)
end

vim.opt.statuscolumn = "%!v:lua.statuscolumn_both()"

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "NvimTree", "telescope", "TelescopePrompt", "help", "qf", "alpha", "toggleterm" },
  callback = function()
    vim.opt_local.statuscolumn = ""
  end,
})

vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.cursorline = true

-- ═══════════════════════════════════════════════════════════════
--  Bootstrap lazy.nvim
-- ═══════════════════════════════════════════════════════════════
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ═══════════════════════════════════════════════════════════════
--  Plugins
-- ═══════════════════════════════════════════════════════════════
require("lazy").setup({

  -- ── Mason (tool installer) ─────────────────────────────────
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "rust-analyzer",
          "gopls",
          "pyright",
          "typescript-language-server",
          "clangd",
          "bash-language-server",
          "rustfmt",
          "black",
          "ruff",
          "prettier",
        },
      })
    end,
  },

  -- ── Treesitter ─────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
        auto_install = true,
      })
    end,
  },

  -- ── Colorscheme ────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          telescope = { enabled = true },
          lsp_trouble = false,
          which_key = true,
          indent_blankline = { enabled = true, colored_indent_levels = true },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
          noice = true,
          notify = true,
        },
      })

      vim.cmd.colorscheme("catppuccin")

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.cmd([[
            hi Normal guibg=NONE ctermbg=NONE
            hi NonText guibg=NONE ctermbg=NONE
            hi EndOfBuffer guibg=NONE ctermbg=NONE
            hi LineNr guibg=NONE ctermbg=NONE
            hi SignColumn guibg=NONE ctermbg=NONE
            hi VertSplit guibg=NONE ctermbg=NONE
            hi NormalFloat guibg=NONE ctermbg=NONE
          ]])
        end,
      })
    end,
  },

  -- ── Completion ─────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })

      -- LSP config (native Neovim 0.11+ API)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config["rust-analyzer"] = { capabilities = capabilities }
      vim.lsp.config.gopls = { capabilities = capabilities }
      vim.lsp.config.pyright = { capabilities = capabilities }
      vim.lsp.config.ts_ls = { capabilities = capabilities }
      vim.lsp.config.clangd = { capabilities = capabilities }
      vim.lsp.config.bashls = { capabilities = capabilities }

      vim.lsp.enable({ "rust-analyzer", "gopls", "pyright", "ts_ls", "clangd", "bashls" })

      -- LSP keymaps
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format" })

      -- Autopairs + cmp integration
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ── Telescope ──────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "target/" },
        },
      })

      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
    end,
  },

  -- ── File Explorer ──────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "NvimTree", "toggleterm", "alpha" },
        callback = function(args)
          vim.bo[args.buf].buflisted = false
        end,
      })

      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
    end,
  },

  -- ── Git ────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        current_line_blame_opts = { delay = 100, virt_text_pos = "eol" },
      })

      vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle git blame" })
      vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
      vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset hunk" })
    end,
  },

  -- ── Statusline ─────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = "|",
          section_separators = "",
        },
      })
    end,
  },

  -- ── Which Key ──────────────────────────────────────────────
  { "folke/which-key.nvim", config = function() require("which-key").setup({}) end },

  -- ── Smooth Scrolling ───────────────────────────────────────
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
        mappings = {},
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = "sine",
      })

      local neoscroll = require("neoscroll")
      local keymap = {
        ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 250 }) end,
        ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 250 }) end,
        ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450 }) end,
        ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450 }) end,
        ["<C-y>"] = function() neoscroll.scroll(-0.10, { move_cursor = false, duration = 100 }) end,
        ["<C-e>"] = function() neoscroll.scroll(0.10, { move_cursor = false, duration = 100 }) end,
        ["zt"]    = function() neoscroll.zt({ half_win_duration = 250 }) end,
        ["zz"]    = function() neoscroll.zz({ half_win_duration = 250 }) end,
        ["zb"]    = function() neoscroll.zb({ half_win_duration = 250 }) end,
      }
      local modes = { "n", "v", "x" }
      for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
      end

      vim.keymap.set({ "n", "v" }, "j", function()
        if vim.v.count > 1 then
          neoscroll.scroll(vim.v.count, { move_cursor = true, duration = math.min(vim.v.count * 20, 250) })
        else
          vim.cmd("normal! j")
        end
      end)

      vim.keymap.set({ "n", "v" }, "k", function()
        if vim.v.count > 1 then
          neoscroll.scroll(-vim.v.count, { move_cursor = true, duration = math.min(vim.v.count * 20, 250) })
        else
          vim.cmd("normal! k")
        end
      end)

      vim.keymap.set("n", "G", function()
        if vim.v.count > 0 then
          local target_line = vim.v.count
          local current_line = vim.fn.line(".")
          local distance = math.abs(target_line - current_line)
          neoscroll.scroll(target_line - current_line, { move_cursor = true, duration = math.min(distance * 5, 400) })
        else
          neoscroll.scroll(vim.fn.line("$") - vim.fn.line("."), { move_cursor = true, duration = 400 })
        end
      end)

      vim.keymap.set("n", "gg", function()
        local current_line = vim.fn.line(".")
        neoscroll.scroll(-current_line + 1, { move_cursor = true, duration = math.min(current_line * 5, 400) })
      end)

      vim.keymap.set("n", "<ScrollWheelUp>", function() neoscroll.scroll(-3, { move_cursor = false, duration = 50 }) end)
      vim.keymap.set("n", "<ScrollWheelDown>", function() neoscroll.scroll(3, { move_cursor = false, duration = 50 }) end)
    end,
  },

  -- ── UI: Colorizer ─────────────────────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true, RRGGBB = true, names = true, RRGGBBAA = true, AARRGGBB = true,
          rgb_fn = true, hsl_fn = true, css = true, css_fn = true,
          mode = "background", tailwind = true,
        },
      })
    end,
  },

  -- ── UI: Rainbow Delimiters ─────────────────────────────────
  { "HiPhish/rainbow-delimiters.nvim", config = function() require("rainbow-delimiters.setup").setup() end },

  -- ── UI: Indent Blankline ───────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          highlight = {
            "RainbowDelimiterRed", "RainbowDelimiterYellow", "RainbowDelimiterBlue",
            "RainbowDelimiterOrange", "RainbowDelimiterGreen", "RainbowDelimiterViolet",
            "RainbowDelimiterCyan",
          },
        },
        scope = { enabled = true, show_start = true, show_end = true },
      })
    end,
  },

  -- ── UI: Notify ─────────────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        stages = "fade_in_slide_out",
        timeout = 3000,
        background_colour = "#000000",
        icons = { ERROR = "", WARN = "", INFO = "", DEBUG = "", TRACE = "✎" },
      })
      vim.notify = notify
    end,
  },

  -- ── UI: Dressing ───────────────────────────────────────────
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = {
          enabled = true, default_prompt = "Input:", insert_only = true, start_in_insert = true,
          border = "rounded", relative = "cursor", prefer_width = 40, width = nil,
          max_width = { 140, 0.9 }, min_width = { 20, 0.2 },
        },
        select = {
          enabled = true, backend = { "telescope", "builtin", "nui" },
          builtin = { border = "rounded", relative = "editor" },
        },
      })
    end,
  },

  -- ── UI: Barbar (buffer tabs) ───────────────────────────────
  {
    "romgrk/barbar.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("barbar").setup({
        animation = true, auto_hide = false, tabpages = true, closable = true, clickable = true,
        icons = {
          buffer_index = false, buffer_number = false, button = "",
          diagnostics = {
            [vim.diagnostic.severity.ERROR] = { enabled = true, icon = "" },
            [vim.diagnostic.severity.WARN] = { enabled = true, icon = "" },
          },
          gitsigns = {
            added = { enabled = true, icon = "+" },
            changed = { enabled = true, icon = "~" },
            deleted = { enabled = true, icon = "-" },
          },
          filetype = { enabled = true },
          separator = { left = "▎", right = "" },
          modified = { button = "●" },
          pinned = { button = "", filename = true },
          preset = "default",
          alternate = { filetype = { enabled = false } },
          current = { buffer_index = false },
          inactive = { button = "×" },
          visible = { modified = { buffer_number = false } },
        },
        sidebar_filetypes = { NvimTree = true },
        exclude_ft = { "NvimTree", "toggleterm", "alpha" },
      })

      vim.keymap.set("n", "<Tab>", "<cmd>BufferNext<cr>", { desc = "Next buffer" })
      vim.keymap.set("n", "<S-Tab>", "<cmd>BufferPrevious<cr>", { desc = "Previous buffer" })

      vim.keymap.set("n", "<leader>q", function()
        local listed_count = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.fn.buflisted(buf) == 1 then listed_count = listed_count + 1 end
        end
        if listed_count <= 1 then
          local current_buf = vim.api.nvim_get_current_buf()
          local nvimtree_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "NvimTree" then nvimtree_win = win; break end
          end
          if nvimtree_win then
            vim.api.nvim_set_current_win(nvimtree_win)
            vim.api.nvim_buf_delete(current_buf, { force = false })
          else
            vim.cmd("quit")
          end
        else
          vim.cmd("BufferClose")
        end
      end, { desc = "Close buffer" })
    end,
  },

  -- ── UI: Noice ──────────────────────────────────────────────
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true, command_palette = true, long_message_to_split = true,
          inc_rename = false, lsp_doc_border = true,
        },
        messages = {
          enabled = true, view = "notify", view_error = "notify", view_warn = "notify",
          view_history = "messages", view_search = "virtualtext",
        },
        cmdline = {
          enabled = true, view = "cmdline_popup",
          format = {
            cmdline = { icon = ">" }, search_down = { icon = "🔍⌄" }, search_up = { icon = "🔍⌃" },
            filter = { icon = "$" }, lua = { icon = "☾" }, help = { icon = "?" },
          },
        },
      })
    end,
  },

  -- ── Dashboard ──────────────────────────────────────────────
  {
    "goolord/alpha-nvim",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      dashboard.section.footer.val = "🚀 Happy Coding!"
      dashboard.section.footer.opts.hl = "Type"
      dashboard.section.header.opts.hl = "Include"
      dashboard.section.buttons.opts.hl = "Keyword"
      dashboard.opts.opts.noautocmd = true
      alpha.setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function() vim.opt_local.statuscolumn = "" end,
      })
    end,
  },

  -- ── Terminal ───────────────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then return 15
          elseif term.direction == "vertical" then return vim.o.columns * 0.4 end
        end,
        open_mapping = [[<C-\>]],
        hide_numbers = true, shade_terminals = true, shading_factor = 2,
        start_in_insert = true, insert_mappings = true, terminal_mappings = true,
        persist_size = true, persist_mode = true, direction = "float",
        close_on_exit = true, shell = vim.o.shell, auto_scroll = true,
        float_opts = {
          border = "curved", winblend = 0,
          highlights = { border = "Normal", background = "Normal" },
        },
      })

      vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Toggle floating terminal" })
      vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Toggle horizontal terminal" })
      vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Toggle vertical terminal" })
      vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=tab<cr>", { desc = "Toggle tab terminal" })
      vim.keymap.set("n", "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", { desc = "Toggle all terminals" })

      vim.keymap.set("n", "<leader>tn", function()
        vim.ui.input({ prompt = "Terminal number: " }, function(input)
          if input then vim.cmd(input .. "ToggleTerm") end
        end)
      end, { desc = "Toggle terminal by number" })

      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = function() vim.opt_local.statuscolumn = "" end,
      })
    end,
  },

  -- ── Autopairs ──────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = {
          lua = { "string", "source" },
          javascript = { "string", "template_string" },
        },
        disable_filetype = { "TelescopePrompt", "alpha" },
      })
    end,
  },

  -- ── Comment ────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        padding = true, sticky = true,
        toggler = { line = "gcc", block = "gbc" },
        opleader = { line = "gc", block = "gb" },
      })
    end,
  },

  -- ── Surround ───────────────────────────────────────────────
  { "kylechui/nvim-surround", config = function() require("nvim-surround").setup({}) end },

  -- ── Trouble (diagnostics) ──────────────────────────────────
  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup({
        position = "bottom", height = 10, icons = true, mode = "workspace_diagnostics",
        fold_open = "", fold_closed = "",
        action_keys = {
          close = "q", cancel = "<esc>", refresh = "r",
          jump = { "<cr>", "<tab>" }, open_split = { "<c-x>" },
          open_vsplit = { "<c-v>" }, open_tab = { "<c-t>" },
        },
      })

      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
      vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics" })
      vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List" })
      vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List" })
    end,
  },

  -- ── DAP (debugger) ─────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 }, { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 }, { id = "watches", size = 0.25 },
            },
            size = 40, position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 }, { id = "console", size = 0.5 },
            },
            size = 10, position = "bottom",
          },
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "Debug: Toggle UI" })
    end,
  },

  -- ── Session ────────────────────────────────────────────────
  {
    "folke/persistence.nvim",
    config = function()
      require("persistence").setup({
        dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
        options = { "buffers", "curdir", "tabpages", "winsize" },
      })

      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore Session" })
      vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore Last Session" })
      vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't Save Session" })
    end,
  },

  -- ── Project ────────────────────────────────────────────────
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "Cargo.toml", "package.json", "go.mod", "Makefile" },
        show_hidden = false,
        silent_chdir = true,
      })

      require("telescope").load_extension("projects")
      vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find Projects" })
    end,
  },

  -- ── Find & Replace ─────────────────────────────────────────
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("spectre").setup({
        replace_engine = { ["sed"] = { cmd = "sed", args = nil } },
      })

      vim.keymap.set("n", "<leader>sr", function() require("spectre").open() end, { desc = "Replace (Spectre)" })
      vim.keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Replace Word" })
      vim.keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end, { desc = "Replace Selection" })
      vim.keymap.set("n", "<leader>sf", function() require("spectre").open_file_search() end, { desc = "Replace in File" })
    end,
  },

  -- ── TODO Comments ──────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        signs = true,
        keywords = {
          FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        },
      })

      vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO" })
    end,
  },

  -- ── Git: LazyGit ───────────────────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
      vim.keymap.set("n", "<leader>gc", "<cmd>LazyGitConfig<cr>", { desc = "LazyGit Config" })
      vim.keymap.set("n", "<leader>gf", "<cmd>LazyGitFilter<cr>", { desc = "LazyGit Filter" })
    end,
  },

  -- ── Git: Diffview ──────────────────────────────────────────
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          default = { layout = "diff2_horizontal" },
          merge_tool = { layout = "diff3_horizontal" },
        },
      })

      vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
      vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File History" })
      vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current File History" })
      vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
    end,
  },

  -- ── Git: Conflict ──────────────────────────────────────────
  {
    "akinsho/git-conflict.nvim",
    config = function()
      require("git-conflict").setup({
        default_mappings = true,
        disable_diagnostics = true,
        highlights = { incoming = "DiffAdd", current = "DiffText" },
      })

      vim.keymap.set("n", "<leader>co", "<cmd>GitConflictChooseOurs<cr>", { desc = "Choose Ours" })
      vim.keymap.set("n", "<leader>ct", "<cmd>GitConflictChooseTheirs<cr>", { desc = "Choose Theirs" })
      vim.keymap.set("n", "<leader>cb", "<cmd>GitConflictChooseBoth<cr>", { desc = "Choose Both" })
      vim.keymap.set("n", "<leader>cn", "<cmd>GitConflictNextConflict<cr>", { desc = "Next Conflict" })
      vim.keymap.set("n", "<leader>cp", "<cmd>GitConflictPrevConflict<cr>", { desc = "Previous Conflict" })
      vim.keymap.set("n", "<leader>cl", "<cmd>GitConflictListQf<cr>", { desc = "List Conflicts" })
    end,
  },
})
