---@class CustomModule
local M = {}

---@param opts table|nil Options table for the terminal.
---@field width number|string The percentage of the screen width the terminal should take (e.g., 25).
---@field cmd string|table The command to execute upon opening.
function M.open(opts)
  opts = opts or {}

  -- 1. Get width
  local width_percentage = tonumber(opts.width) or 25
  local width = math.floor(vim.o.columns * (width_percentage / 100))

  -- 2. Get CWD from current buffer's relative path
  local file_path = vim.api.nvim_buf_get_name(0)
  local cwd
  if file_path and file_path ~= "" then
    -- Get the directory of the current file, relative to the main CWD
    cwd = vim.fn.fnamemodify(file_path, ":h")
  end

  -- Fallback to current working directory if buffer has no file or path is not a directory
  if not cwd or cwd == "" or vim.fn.isdirectory(cwd) == 0 then
    cwd = vim.fn.getcwd()
  end

  -- 3. Get command to run
  local cmd_to_run = ""
  if opts.cmd and opts.cmd ~= "" then
    if type(opts.cmd) == "table" then
      cmd_to_run = table.concat(opts.cmd, " ")
    elseif type(opts.cmd) == "string" then
      cmd_to_run = opts.cmd
    end
  end

  -- 4. Open a new vertical split on the right with the specified width
  vim.cmd("rightbelow vsplit")
  vim.cmd("vertical resize " .. width)

  -- 5. Set the working directory for the new window.
  vim.cmd("lcd " .. vim.fn.fnameescape(cwd))

  -- 6. Open the terminal in the new split.
  local term_cmd
  if cmd_to_run ~= "" then
    local shell = vim.o.shell
    local escaped_cmd = vim.fn.string(cmd_to_run):gsub('"', '"')
    term_cmd = string.format('terminal %s -c "%s; exec %s"', shell, escaped_cmd, shell)
  else
    term_cmd = "terminal"
  end
  vim.api.nvim_command(term_cmd)

  -- 7. Set a buffer-local keymap to exit terminal mode
  local term_bufnr = vim.api.nvim_get_current_buf()
  vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", {
    noremap = true,
    silent = true,
    buffer = term_bufnr,
    desc = "Exit terminal mode",
  })

  vim.cmd("startinsert")
end

return M

