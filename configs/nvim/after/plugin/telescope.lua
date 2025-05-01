local builtin = require("telescope.builtin")

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
vim.keymap.set('', '<leader>bb', builtin.buffers, {})
vim.keymap.set('n', '<leader>e', function() builtin.find_files({ cwd = vim.fn.expand('%:p:h') }) end, {})
