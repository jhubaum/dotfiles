local silent = { silent = true }

--Remap space as leader key
vim.keymap.set('', '<Space>', '<Nop>', silent)

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Better paste
vim.keymap.set('v', 'p', '"_dp')
vim.keymap.set('v', 'P', '"_dP')
vim.keymap.set('v', '<leader>d', '"_d')
vim.keymap.set('n', '<leader>d', '"_d')

vim.keymap.set('n', '<C-d>', '<C-d>zz', silent)
vim.keymap.set('n', '<C-u>', '<C-u>zz', silent)
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<leader>y', '\"+y')
vim.keymap.set('v', '<leader>y', '\"+y')
vim.keymap.set('n', '<leader>p', '"+p', silent)
vim.keymap.set('v', '<leader>p', '"+p', silent)
vim.keymap.set('n', '<leader>P', '"+P', silent)
vim.keymap.set('v', '<leader>P', '"+P', silent)


-- disable arrow keys for navigation
vim.keymap.set('', '<up>', '<nop>', silent)
vim.keymap.set('', '<down>', '<nop>', silent)
vim.keymap.set('', '<left>', '<nop>', silent)
vim.keymap.set('', '<right>', '<nop>', silent)


-- vim.keymap.setpings for opening files relative to current buffer
vim.keymap.set('', ',e', ':e <C-R>=expand("%:p:h") . "/" <CR>', silent)

-- vim.keymap.setpings around buffers
vim.keymap.set('', '<leader>bq', ':bp|bd#<CR>', silent) -- Close buffer im current window without closing the window itself

vim.keymap.set('', '<C-w>h', ':wincmd h<CR>', silent)
vim.keymap.set('', '<C-w>j', ':wincmd j<CR>', silent)
vim.keymap.set('', '<C-w>k', ':wincmd k<CR>', silent)
vim.keymap.set('', '<C-w>l', ':wincmd l<CR>', silent)

vim.keymap.set('', '<C-w>H', ':vsplit<CR>', silent)
vim.keymap.set('', '<C-w>J', ':split<CR>:wincmd j<CR>', silent)
vim.keymap.set('', '<C-w>K', ':split<CR>', silent)
vim.keymap.set('', '<C-w>L', ':vsplit<CR>:wincmd l<CR>', silent)


