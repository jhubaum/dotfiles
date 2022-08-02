local keymap = vim.keymap.set
local opts = { silent = true }

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Better paste
keymap("v", "p", '"_dP', opts)

-- disable arrow keys for navigation
keymap("", "<up>", "<nop>", opts)
keymap("", "<down>", "<nop>", opts)
keymap("", "<left>", "<nop>", opts)
keymap("", "<right>", "<nop>", opts)

-- keymappings around buffers
keymap("", "<leader>bb", ':lua require"telescope.builtin".buffers()<CR>', opts)

-- keymappings around code and lsp interactions
keymap("", "<leader>cd", ':lua vim.lsp.buf.definition()<CR>')
keymap("", "<leader>cr", ':lua vim.lsp.buf.references()<CR>')

-- keymappings for project and file navigation
keymap('', '<leader>pf', ':lua require"telescope.builtin".find_files()<CR>')

-- Skip these options for now, since I don't like the key bindings
--[[
-- Lsp
key_mapper('n', 'gw', ':lua vim.lsp.buf.document_symbol()<CR>')
key_mapper('n', 'gW', ':lua vim.lsp.buf.workspace_symbol()<CR>')
key_mapper('n', 'gt', ':lua vim.lsp.buf.type_definition()<CR>')
key_mapper('n', 'K', ':lua vim.lsp.buf.hover()<CR>')
key_mapper('n', '<c-k>', ':lua vim.lsp.buf.signature_help()<CR>')
key_mapper('n', '<leader>af', ':lua vim.lsp.buf.code_action()<CR>')
key_mapper('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>')

-- Fuzzy Search
key_mapper('n', '<leader>fs', ':lua require"telescope.builtin".live_grep()<CR>')
key_mapper('n', '<leader>fh', ':lua require"telescope.builtin".help_tags()<CR>')
]]
