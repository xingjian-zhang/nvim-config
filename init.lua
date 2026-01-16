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
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find in files (grep)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    },
  },
  -- LSP (nvim-lspconfig provides server configs for vim.lsp)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Enable pyright using native vim.lsp API (Neovim 0.11+)
      vim.lsp.enable("pyright")

      -- LSP keymaps (only active when LSP attaches to buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
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
  -- Atom One Dark colorscheme
  {
    "navarasu/onedark.nvim",
    priority = 1000,  -- Load before other plugins
    config = function()
      require("onedark").setup({
        style = "darker",  -- Options: dark, darker, cool, deep, warm, warmer
      })
      require("onedark").load()
    end,
  },
})

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
