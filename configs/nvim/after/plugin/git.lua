-- Git forge link generation
-- <leader>gl - Generate a link to the current line(s) on GitHub/GitLab, print and copy via yk

-- The two things forges disagree on: the blob path segment and the multi-line anchor
local GITHUB = { blob = "/blob/", range = "-L" }  -- .../owner/repo/blob/<sha>/<path>#L5-L12
local GITLAB = { blob = "/-/blob/", range = "-" } -- .../group/project/-/blob/<sha>/<path>#L5-12

-- Run git in the directory of the current file, so links are correct even when
-- the buffer lives outside nvim's cwd. Returns nil on failure.
local function git(dir, args)
  local out = vim.fn.system("git -C " .. vim.fn.shellescape(dir) .. " " .. args .. " 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return (out:gsub("%s+$", ""))
end

-- Split a remote URL into web host and project path
-- SSH:   git@host:group/project.git
-- ssh:// ssh://git@host:2222/group/project.git
-- HTTPS: https://host/group/project.git
local function parse_remote(remote_url)
  local host, path = remote_url:match("^git@([^:]+):(.+)$")
  if not host then
    local rest = remote_url:match("^%a[%w+.-]*://(.+)$")
    if rest then
      rest = rest:gsub("^[^/@]*@", "") -- drop user[:pass]@
      host, path = rest:match("^([^/]+)/(.+)$")
      if host then
        host = host:gsub(":%d+$", "") -- drop port, it isn't part of the web URL
      end
    end
  end
  if not host then
    return nil
  end
  return host, (path:gsub("%.git$", ""))
end

local function get_git_url(start_line, end_line)
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    print("Error: Current buffer is not a file on disk")
    return nil
  end
  local dir = vim.fn.expand("%:p:h")

  local remote_url = git(dir, "remote get-url origin")
  if not remote_url or remote_url == "" then
    print("Error: Not in a git repository or no origin remote found")
    return nil
  end

  local host, project = parse_remote(remote_url)
  if not host then
    print("Error: Could not parse remote URL: " .. remote_url)
    return nil
  end

  -- Link the commit rather than the branch, so the link keeps pointing at these lines
  local sha = git(dir, "rev-parse HEAD")
  if not sha or sha == "" then
    print("Error: Could not determine current commit")
    return nil
  end

  -- --show-prefix instead of slicing off --show-toplevel: it doesn't care whether
  -- the file was opened through a symlinked path
  local prefix = git(dir, "rev-parse --show-prefix")
  if not prefix then
    print("Error: Could not determine path within repository")
    return nil
  end
  local relative_path = prefix .. vim.fn.expand("%:t")

  local forge = host:match("github") and GITHUB or GITLAB
  local url = "https://" .. host .. "/" .. project
    .. forge.blob .. sha .. "/" .. relative_path
    .. "#L" .. start_line
  if end_line ~= start_line then
    url = url .. forge.range .. end_line
  end

  return url
end

local function copy_git_link(is_visual)
  local start_line, end_line

  if is_visual then
    -- Get visual selection positions directly (without exiting visual mode)
    start_line = vim.fn.line("v")  -- start of visual selection
    end_line = vim.fn.line(".")    -- cursor position
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
  else
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  local url = get_git_url(start_line, end_line)
  if url then
    vim.fn.setreg('+', url)
    print("Copied " .. url .. " to clipboard")
  end

  -- Exit visual mode and jump to start of selection (like y does)
  if is_visual then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    vim.api.nvim_win_set_cursor(0, {start_line, 0})
  end
end

-- Keybindings
vim.keymap.set('n', '<leader>gl', function() copy_git_link(false) end, { desc = "Copy git link for current line" })
vim.keymap.set('v', '<leader>gl', function() copy_git_link(true) end, { desc = "Copy git link for selection" })
