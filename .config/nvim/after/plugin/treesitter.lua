local configs = require 'nvim-treesitter.configs'
configs.setup {
  ensure_installed = { 'python', 'cpp', 'lua', 'rust', 'markdown', 'ocaml' },
  --highlight = {
  --  enable = true,
  --}
}

