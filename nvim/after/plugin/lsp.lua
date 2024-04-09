require("mason").setup {}

local lspconfig = require 'lspconfig'
local masonlsp = require("mason-lspconfig")
masonlsp.setup()
masonlsp.setup_handlers {
  function (server_name) -- Default handler
    lspconfig[server_name].setup {}
  end,
  ["lua_ls"] = function ()
    lspconfig["lua_ls"].setup {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    }
  end,
  ["rust_analyzer"] = function ()
    require("rust-tools").setup {}
  end,
  ["pylsp"] = function ()
    lspconfig["pylsp"].setup({
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = { enabled = false },
          },
        },
        python = {
          analysis = {
            -- Ignore all files for analysis to exclusively use Ruff for linting
            ignore = { '*' },
          },
        },
      },
    })
  end,
  ["ruff_lsp"] = function ()
    lspconfig["ruff_lsp"].setup {
      init_options = {
        settings = {
          args = {},
        }
      }
    }
  end,
}

-- setup language servers here
-- TODO: add a check that mason does not already have a handler for the server
lspconfig.clangd.setup {}
lspconfig.ocamllsp.setup({
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    root_dir = lspconfig.util.root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace"),
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = false,
    signs = true,
    update_in_insert = true,
  }
)

-- Completion Plugin Setup
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})

-- vim.keymap.setpings around code and lsp interactions
vim.keymap.set('', '<leader>cd', ':lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('', '<leader>cD', ':lua vim.lsp.buf.references()<CR>')
vim.keymap.set('', '<leader>cl', ':lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('', '<leader>cf', ':lua vim.lsp.buf.format()<CR>')
vim.keymap.set('', '<leader>cr', ':lua vim.lsp.buf.rename()<CR>')

