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

-- vim.keymap.setpings around code and lsp interactions
vim.keymap.set('', '<leader>cd', ':lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('', '<leader>cD', ':lua vim.lsp.buf.references()<CR>')
vim.keymap.set('', '<leader>ca', ':lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('', '<leader>ch', ':lua vim.lsp.buf.signature_help()<CR>')
vim.keymap.set('', '<leader>cf', ':lua vim.lsp.buf.format()<CR>')
vim.keymap.set('', '<leader>cr', ':lua vim.lsp.buf.rename()<CR>')

