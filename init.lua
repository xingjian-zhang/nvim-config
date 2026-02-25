-- Basic Settings
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.mouse = "a"            -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Indentation
vim.opt.tabstop = 4            -- Tab width
vim.opt.shiftwidth = 4         -- Indent width
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.smartindent = true     -- Smart indentation

-- Search
vim.opt.ignorecase = true      -- Ignore case when searching
vim.opt.smartcase = true       -- Unless uppercase is used
vim.opt.hlsearch = true        -- Highlight search results
vim.opt.incsearch = true       -- Show matches as you type

-- Appearance
vim.opt.termguicolors = true   -- Enable 24-bit colors
vim.opt.background = "dark"    -- Or "light" if you use a light theme
vim.opt.signcolumn = "yes"     -- Always show sign column
vim.opt.cursorline = true      -- Highlight current line
vim.opt.scrolloff = 8          -- Lines above/below cursor

-- Behavior
vim.opt.splitright = true      -- Vertical splits to the right
vim.opt.splitbelow = true      -- Horizontal splits below
vim.opt.wrap = false           -- Don't wrap lines
vim.opt.undofile = true        -- Persistent undo
vim.opt.autoread = true        -- Reload files changed outside vim

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Auto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Seamless navigation between Neovim and tmux panes
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left (Neovim/tmux)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down (Neovim/tmux)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up (Neovim/tmux)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (Neovim/tmux)" },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fa", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", desc = "Find all files (incl. hidden)" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find in files (grep)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          preview = {
            treesitter = false,  -- Disable treesitter in previews (fixes ft_to_lang error)
          },
        },
      })
    end,
  },
  -- LSP (nvim-lspconfig provides server configs for vim.lsp)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Enable LSP servers using native vim.lsp API (Neovim 0.11+)
      vim.lsp.enable("pyright")  -- Type checking
      vim.lsp.enable("ruff")     -- Linting + formatting
      -- vim.lsp.enable("texlab")   -- LaTeX (disabled: VimTeX handles compilation, LSP diagnostics are noisy)

      -- LSP keymaps (only active when LSP attaches to buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { buffer = args.buf, desc = "Format code" })
        end,
      })
    end,
  },
  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
        },
      })
    end,
  },
  -- Shows keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,  -- show popup after 300ms
    },
  },
  -- Break bad habits, learn better Vim motions
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },
  -- Treesitter (rich syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  -- Render markdown in-buffer (headers, code blocks, checkboxes, etc.)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      render_modes = { "n", "c" },  -- Render in normal and command mode only
      anti_conceal = { enabled = false },  -- Don't show raw markdown on cursor line
      heading = {
        position = "inline",  -- Put icon inline instead of in sign column
        width = "block",      -- Header background spans text only, not full width
      },
      code = {
        width = "block",      -- Code block background spans text only
        left_pad = 1,
        right_pad = 1,
      },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render" },
    },
  },
  -- VimTeX for LaTeX editing
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1      -- Forward search after compile
      vim.g.vimtex_view_skim_activate = 1  -- Bring Skim to foreground
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
      -- Disable automatic compilation (manual only)
      vim.g.vimtex_compiler_enabled = 1    -- Keep compiler available
      -- Don't start continuous compilation automatically
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.b.vimtex_compiler_continuous = 0
        end,
      })
    end,
  },
  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local opts = { buffer = bufnr }

        -- Navigation between hunks
        vim.keymap.set("n", "]c", gs.next_hunk, { buffer = bufnr, desc = "Next git hunk" })
        vim.keymap.set("n", "[c", gs.prev_hunk, { buffer = bufnr, desc = "Previous git hunk" })

        -- Actions
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
        vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Blame line" })
        vim.keymap.set("n", "<leader>gB", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle line blame" })
      end,
    },
  },
  -- Oceanic Next colorscheme (supports both dark and light)
  {
    "mhartington/oceanic-next",
    priority = 1000,
  },
  -- Auto-detect system dark/light mode
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.opt.background = "dark"
        vim.cmd.colorscheme("OceanicNext")
      end,
      set_light_mode = function()
        vim.opt.background = "light"
        vim.cmd.colorscheme("OceanicNextLight")
      end,
    },
  },
})

-- Diagnostic virtual text (muted colors so it's less distracting)
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",  -- Or "■", "▎", "x"
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,  -- Don't update while typing
})

-- Muted but tinted virtual text colors (not pure gray)
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#804040", italic = true })  -- Muted red
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#806030", italic = true })   -- Muted yellow/orange
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#406080", italic = true })   -- Muted blue
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#408060", italic = true })   -- Muted green

-- Keymaps
local keymap = vim.keymap.set

-- Clear search highlight with Escape
keymap("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

-- Move lines up/down in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
keymap("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Stay centered when scrolling
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Better indent in visual mode (stay in visual)
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Quick save
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })

-- Quick quit
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- File explorer (built-in netrw)
keymap("n", "<leader>e", ":Explore<CR>", { desc = "File explorer" })

-- Diagnostics
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- LaTeX-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- Write server name for Skim inverse search (last opened tex file wins)
    local server_file = "/tmp/vimtexserver.txt"
    local f = io.open(server_file, "w")
    if f then
      f:write(vim.v.servername)
      f:close()
    end

    vim.opt_local.wrap = true           -- Soft wrap for prose
    vim.opt_local.linebreak = true      -- Wrap at word boundaries
    vim.opt_local.spell = true          -- Enable spell checking
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.textwidth = 0         -- No hard wrap
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2

    -- Navigate wrapped lines naturally
    vim.keymap.set("n", "j", "gj", { buffer = true })
    vim.keymap.set("n", "k", "gk", { buffer = true })

    -- VimTeX keymaps (local leader = space for tex files)
    vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<cr>", { buffer = true, desc = "Compile LaTeX" })
    vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<cr>", { buffer = true, desc = "View PDF" })
    vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<cr>", { buffer = true, desc = "Toggle TOC" })
    vim.keymap.set("n", "<leader>lc", "<cmd>VimtexClean<cr>", { buffer = true, desc = "Clean aux files" })
    vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<cr>", { buffer = true, desc = "Show errors" })
    vim.keymap.set("n", "<leader>ls", "<cmd>VimtexStop<cr>", { buffer = true, desc = "Stop compilation" })
  end,
})

-- Markdown-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true           -- Soft wrap for prose
    vim.opt_local.linebreak = true      -- Wrap at word boundaries
    vim.opt_local.breakindent = true    -- Preserve indentation on wrapped lines
    vim.opt_local.spell = true          -- Enable spell checking
    vim.opt_local.spelllang = "en_us"

    -- Navigate wrapped lines naturally
    vim.keymap.set("n", "j", "gj", { buffer = true })
    vim.keymap.set("n", "k", "gk", { buffer = true })
  end,
})
