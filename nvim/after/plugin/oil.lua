require("oil").setup {
    columns = { "icon" },
    keymaps = {
        ["<C-h>"] = false
    },
    view_options = {
        show_hidden = true
    }
}

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
