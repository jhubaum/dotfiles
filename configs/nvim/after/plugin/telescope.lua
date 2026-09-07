local builtin = require("telescope.builtin")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local conf = require("telescope.config").values

-- Like builtin.live_grep, but a ` -- ` in the prompt separates the search
-- pattern from ripgrep globs restricting which files are searched:
--
--   TEST_ -- config.py      TEST_ in every config.py
--   TEST_ -- *.py           TEST_ in all python files
--   TEST_ -- *.py !test_*   ... but not in test_* files
--   TEST_ -- src/**/*.rs    a glob containing a / is anchored at the cwd
--
-- Globs behave like find: without a slash they match the file name at any
-- depth. Without a ` -- ` this is plain live_grep.
local function live_grep_glob(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_job(function(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    local pieces = vim.split(prompt, "%s%-%-%s")
    local pattern = pieces[1]
    if pattern == "" then
      return nil
    end

    local args = vim.list_extend({}, conf.vimgrep_arguments)
    for i = 2, #pieces do
      for _, glob in ipairs(vim.split(pieces[i], "%s+", { trimempty = true })) do
        table.insert(args, "--glob=" .. glob)
      end
    end
    table.insert(args, "--")
    table.insert(args, pattern)

    return args
  end, opts.entry_maker or make_entry.gen_from_vimgrep(opts), nil, opts.cwd)

  pickers
    .new(opts, {
      prompt_title = "Live Grep (pattern -- glob)",
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),
      attach_mappings = function(_, map)
        map("i", "<c-space>", actions.to_fuzzy_refine)
        return true
      end,
      push_cursor_on_edit = true,
    })
    :find()
end

vim.keymap.set('n', '<leader>pf', function() builtin.find_files({ follow = true }) end, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
vim.keymap.set('n', '<leader>pS', live_grep_glob, {})
vim.keymap.set('n', '<leader>p/', builtin.grep_string, {})
vim.keymap.set('v', '<leader>p/', builtin.grep_string, {})
vim.keymap.set('', '<leader>bb', builtin.buffers, {})
vim.keymap.set('n', '<leader>e', function() builtin.find_files({ cwd = vim.fn.expand('%:p:h'), follow = true}) end, {})
