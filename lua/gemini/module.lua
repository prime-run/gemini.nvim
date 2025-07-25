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

  -- 2. Get CWD from neovim's current working directory
  local cwd = vim.fn.getcwd()

  -- 3. Get command to run
  local cmd_to_run = ""
  if opts.cmd then
    if type(opts.cmd) == "table" then
      local parts = {}
      for _, part in ipairs(opts.cmd) do
        table.insert(parts, vim.fn.shellescape(part))
      end
      cmd_to_run = table.concat(parts, " ")
    elseif type(opts.cmd) == "string" and opts.cmd ~= "" then
      cmd_to_run = opts.cmd
    end
  end

  -- 4. Open a new vertical split on the right with the specified width
  vim.cmd("rightbelow vsplit")
  vim.cmd("vertical resize " .. width)

  -- 5. Set the working directory for the new window.
  vim.cmd("lcd " .. vim.fn.fnameescape(cwd))

  -- 6. Open the terminal in the new split.
  local term_cmd = "terminal"
  if cmd_to_run ~= "" then
    term_cmd = term_cmd .. " " .. cmd_to_run
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

