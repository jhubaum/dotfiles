M = {}

function M.clangd()
  if vim.lsp.get_active_clients({ bufnr = 0 })[1] then
  return
  end

  vim.lsp.start({
    name = "clangd",
    cmd = { "clangd" },
    root_dir = vim.fs.dirname(vim.fs.find({ "compile_commands.json", ".git" }, { upward = true })[1]),
  })
end

return M
