-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'python', 'cpp', 'lua', 'rust', 'markdown', 'ocaml' },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  }
end, 0)
