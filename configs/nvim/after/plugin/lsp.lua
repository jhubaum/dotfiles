require("mason").setup {}
require("mason-lspconfig").setup {}
require("rust-tools").setup {}

vim.lsp.config.lua_ls = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}
vim.lsp.config.pylsp = {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        mccabe = { enabled = false }
      },
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
}

vim.lsp.config.ruff = {
  init_options = {
    settings = {
      args = {},
    }
  }
}

vim.lsp.config.ocamllsp = {
  cmd = { "ocamllsp" },
  filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
  root_markers = { "*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace" }
}

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
