vim.keymap.set('i', '<C-J>', 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<C-H>", 'copilot#Previous()', { silent = true, expr = true })
vim.keymap.set("i", "<C-L>", 'copilot#Next()', { silent = true, expr = true })
vim.g.copilot_no_tab_map = true
