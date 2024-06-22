local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

local function open_git_diff(file_path)
  local prefix = "diff://"
  local bufnr = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match(prefix .. file_path) then
      bufnr = buf
      break
    end
  end
  if bufnr then
    vim.cmd("buf " .. bufnr)
    -- vim.cmd("only")
    return
  end

  local handle = io.popen("git diff " .. file_path)
  if handle == nil then
    return
  end
  local diff_output = handle:read("*a")
  handle:close()

  vim.cmd("new")
  vim.cmd("only")
  vim.cmd("keepalt file " .. prefix .. file_path)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(diff_output, "\n"))
  vim.cmd("setlocal buftype=nofile")
  vim.cmd("setlocal filetype=diff")
  vim.cmd("setlocal nomodifiable")
end

local mappings = function(prompt_bufnr, map)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local path = selection.value
    --print(vim.inspect(selection))
    open_git_diff(path)
  end)
  return true
end

local function git_diff(opts)
  opts = opts or {}
  opts.prompt_title = vim.F.if_nil(opts.prompt_title, "Diff picker")
  opts.attach_mappings = vim.F.if_nil(opts.attach_mappings, mappings)
  builtin.git_status({ prompt_title = "Diff picker", attach_mappings = mappings })
end

return require("telescope").register_extension({
  setup = function(ext_config, config)
    -- access extension config and user config
  end,
  exports = {
    git_diff = git_diff,
  },
})
