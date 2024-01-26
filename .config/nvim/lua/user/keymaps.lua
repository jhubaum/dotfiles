local keymap = vim.keymap.set
local silent = { silent = true }

--Remap space as leader key
keymap('', '<Space>', '<Nop>', silent)
vim.g.mapleader = ' '

-- Better paste
keymap('v', 'p', '"_dP', silent)
keymap('v', '<C-d>', '<C-d>zz', silent)
keymap('v', '<C-u>', '<C-u>zz', silent)

-- disable arrow keys for navigation
keymap('', '<up>', '<nop>', silent)
keymap('', '<down>', '<nop>', silent)
keymap('', '<left>', '<nop>', silent)
keymap('', '<right>', '<nop>', silent)


-- keymappings for opening files relative to current buffer
keymap('', ',e', ':e <C-R>=expand("%:p:h") . "/" <CR>', silent)

-- keymappings around buffers
keymap('', '<leader>bb', ':lua require"telescope.builtin".buffers()<CR>', silent)
keymap('', '<leader>bq', ':bp|bd#<CR>', silent) -- Close buffer im current window without closing the window itself

keymap('', '<leader>wh', ':wincmd h<CR>', silent)
keymap('', '<leader>wj', ':wincmd j<CR>', silent)
keymap('', '<leader>wk', ':wincmd k<CR>', silent)
keymap('', '<leader>wl', ':wincmd l<CR>', silent)

keymap('', '<leader>wH', ':vsplit<CR>', silent)
keymap('', '<leader>wJ', ':split<CR>:wincmd j<CR>', silent)
keymap('', '<leader>wK', ':split<CR>', silent)
keymap('', '<leader>wL', ':vsplit<CR>:wincmd l<CR>', silent)

-- keymappings around code and lsp interactions
keymap('', '<leader>cd', ':lua vim.lsp.buf.definition()<CR>')
keymap('', '<leader>cD', ':lua vim.lsp.buf.references()<CR>')
keymap('', '<leader>cl', ':lua vim.lsp.buf.code_action()<CR>')
keymap('', '<leader>cf', ':lua vim.lsp.buf.format()<CR>')
keymap('', '<leader>cr', ':lua vim.lsp.buf.rename()<CR>')
keymap('', '<leader>cn', ':lua vim.diagnostic.goto_next()<CR>')
keymap('', '<leader>cN', ':lua vim.diagnostic.goto_prev()<CR>')

-- keymappings aroung git
keymap('', '<leader>gd', ':DiffviewOpen HEAD -- %<CR>')
keymap('', '<leader>gq', ':DiffviewClose<CR>')

-- keymappings for project and file navigation
keymap('', '<leader>pf', ':lua require"telescope.builtin".find_files()<CR>')
keymap('', '<leader>ps', ':lua require"telescope.builtin".live_grep()<CR>')

keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false })
keymap("i", "<C-H>", 'copilot#Previous()', { silent = true, expr = true })
keymap("i", "<C-L>", 'copilot#Next()', { silent = true, expr = true })
vim.g.copilot_no_tab_map = true
