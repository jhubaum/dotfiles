local builtin = require("telescope.builtin")

vim.keymap.set('n', '<leader>pd', builtin.find_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
vim.keymap.set('', '<leader>bb', builtin.buffers, {})
