require "user.options"
require "user.keymaps"
require "user.plugins"

vim.g.tokyonight_style = "night"
vim.cmd "colorscheme tokyonight"
vim.cmd "highlight Normal guibg=000000"
vim.cmd "highlight NormalNC guibg=000000"

local configs = require'nvim-treesitter.configs'
configs.setup {
  ensure_installed = {'python', 'cpp', 'lua', 'rust', 'markdown'},
  --highlight = {
  --  enable = true,
  --}
}

local lspconfig = require'lspconfig'
local default_config = {
  on_attach = custom_on_attach,
}
-- setup language servers here
lspconfig.clangd.setup {}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = false,
    signs = true,
    update_in_insert = true,
  }
)

