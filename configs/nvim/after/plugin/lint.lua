require("lint").linters_by_ft = {
    python = { "mypy" },
}

vim.api.nvim_create_autocmd({"BufWritePost", "BufEnter"}, {
    callback = function()
        require("lint").try_lint()
    end,
})
