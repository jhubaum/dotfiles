local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don"t error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

return packer.startup(function(use)
  use "wbthomason/packer.nvim" -- Have packer manage itself

  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  -- Lsp
  use "neovim/nvim-lspconfig"
  use "anott03/nvim-lspinstall"

  use 'mfussenegger/nvim-lint'

  -- Rust
  use 'simrat39/rust-tools.nvim'

  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }

  -- Fuzzy finder
  use "nvim-lua/popup.nvim"
  use "nvim-lua/plenary.nvim"
  use "jremmen/vim-ripgrep"

  use {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { {"nvim-lua/plenary.nvim"} }
  }

   use({
    "hrsh7th/nvim-cmp",
    requires = {
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      -- TODO: Start using at some point?
      --{ "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
      --"saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require "user.completion"
    end,
  })

  use({
    "epwalsh/obsidian.nvim",
    tag = "*",  -- recommended, use latest release instead of latest commit
    requires = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("obsidian").setup({
        ui = {
          -- TODO: Look more into https://github.com/epwalsh/obsidian.nvim for config options
          enable = false
        },
        workspaces = {
          {
            name = "personal",
            path = "~/notes"
          }
        }
      })
    end,
  })

  -- git
  use 'tpope/vim-fugitive'

  use {
    "nvim-treesitter/nvim-treesitter",
    run = function() require("nvim-treesitter.install").update({ with_sync = true }) end,
  }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  use "sheerun/vim-polyglot"

  use "folke/tokyonight.nvim"
  use 'mbbill/undotree'
end)
