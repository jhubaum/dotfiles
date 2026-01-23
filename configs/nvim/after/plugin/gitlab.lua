-- GitLab link generation
-- <leader>gl - Generate GitLab link for current line(s), print and copy via yk

local function get_gitlab_url(start_line, end_line)
  -- Get git remote URL from origin
  local remote_url = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("%s+$", "")
  if vim.v.shell_error ~= 0 then
    print("Error: Not in a git repository or no origin remote found")
    return nil
  end

  -- Convert remote URL to GitLab web URL
  -- SSH format: git@gitlab.example.com:group/project.git
  -- HTTPS format: https://gitlab.example.com/group/project.git
  local base_url
  if remote_url:match("^git@") then
    -- SSH: git@gitlab.example.com:group/project.git -> https://gitlab.example.com/group/project
    local host, path = remote_url:match("^git@([^:]+):(.+)$")
    base_url = "https://" .. host .. "/" .. path:gsub("%.git$", "")
  else
    -- HTTPS: just strip .git suffix
    base_url = remote_url:gsub("%.git$", "")
  end

  -- Get current branch
  local branch = vim.fn.system("git branch --show-current"):gsub("%s+$", "")
  if branch == "" then
    print("Error: Could not determine current branch (detached HEAD?)")
    return nil
  end

  -- Get file path relative to git root
  local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+$", "")
  local file_path = vim.fn.expand("%:p")
  local relative_path = file_path:sub(#git_root + 2)

  -- Construct URL
  local url = base_url .. "/-/blob/" .. branch .. "/" .. relative_path .. "#L" .. start_line
  if end_line ~= start_line then
    url = url .. "-" .. end_line
  end

  return url
end

local function copy_gitlab_link(is_visual)
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

  local url = get_gitlab_url(start_line, end_line)
  if url then
    vim.fn.setreg('+', url)
    print("Copied " .. url .. " to clipboard")
  end
end

-- Keybindings
vim.keymap.set('n', '<leader>gl', function() copy_gitlab_link(false) end, { desc = "Copy GitLab link for current line" })
vim.keymap.set('v', '<leader>gl', function() copy_gitlab_link(true) end, { desc = "Copy GitLab link for selection" })
