vim.filetype.add({
  pattern = {
    -- Match uv shebangs
    ['^#!.*/env%s+-S%s+uv%s+run%s+%-%-script'] = 'python',
  },
})
