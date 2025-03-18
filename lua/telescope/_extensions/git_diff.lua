local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

local function open_git_diff(file_path)
  if not file_path or file_path == "" then
    return
  end
  
  -- Check if the file exists in the working directory
  local git_root = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
  local full_path = git_root .. "/" .. file_path

  -- Open the file in the current buffer
  vim.cmd("edit " .. vim.fn.fnameescape(full_path))
  vim.cmd("setlocal diff")  -- Mark this buffer for diff view
  
  -- Get the git diff output
  local handle = io.popen("git show HEAD:" .. vim.fn.shellescape(file_path))
  if handle == nil then
    return
  end
  local diff_output = handle:read("*a")
  handle:close()
  
  -- Open a new vertical split and populate it with the diff
  vim.cmd("vert new")
  vim.cmd("setlocal buftype=nofile filetype=diff nowrap")
  vim.cmd("setlocal modifiable")  -- Allow modifications before inserting text
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(diff_output, "\n"))
  vim.cmd("setlocal nomodifiable")  -- Lock the buffer again after inserting text
  vim.cmd("setlocal diff")  -- Mark this buffer for diff view
end

local function mappings(prompt_bufnr, map)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection then
      open_git_diff(selection.value)
    end
  end)
  return true
end

local function git_diff(opts)
  opts = opts or {}
  opts.prompt_title = "Git Diff"
  opts.attach_mappings = mappings
  builtin.git_status(opts)
end

return require("telescope").register_extension({
  setup = function(ext_config, config)
    -- Optional: Handle extension-specific configuration here
  end,
  exports = {
    git_diff = git_diff,
  },
})
