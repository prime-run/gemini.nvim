---@class CustomModule
local M = {}

M.term_bufnr = nil

--- Creates and sets up a new terminal window.
---@param opts table The options table.
---@return number The buffer number of the new terminal.
local function _create_terminal(opts)
  -- 1. Get width
  local width_percentage = tonumber(opts.width) or 25
  local width = math.floor(vim.o.columns * (width_percentage / 100))

  -- 2. Get CWD
  local cwd = vim.fn.getcwd()

  -- 3. Get command
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

  -- 4. Create split and set CWD
  vim.cmd("rightbelow vsplit")
  vim.cmd("vertical resize " .. width)
  vim.cmd("lcd " .. vim.fn.fnameescape(cwd))

  -- 5. Open terminal
  local term_cmd = "terminal"
  if cmd_to_run ~= "" then
    term_cmd = term_cmd .. " " .. cmd_to_run
  end
  vim.api.nvim_command(term_cmd)

  -- 6. Configure terminal buffer
  local term_bufnr = vim.api.nvim_get_current_buf()
  vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", {
    noremap = true,
    silent = true,
    buffer = term_bufnr,
    desc = "Exit terminal mode",
  })
  vim.cmd("startinsert")

  return term_bufnr
end

--- Opens a terminal window, managing a single instance.
---@param opts table|nil Options table for the terminal.
function M.open(opts)
  opts = opts or {}
  local original_win = vim.api.nvim_get_current_win()

  local function handle_focus()
    if opts.focus_back then
      vim.api.nvim_set_current_win(original_win)
    end
  end

  -- If terminal exists and is valid
  if M.term_bufnr and vim.api.nvim_buf_is_valid(M.term_bufnr) then
    local winid = vim.fn.bufwinid(M.term_bufnr)

    -- If a new command is being sent, prompt the user
    if opts.cmd then
      vim.ui.select({ "Discard", "Override", "Create New" }, {
        prompt = "A Gemini terminal is running. What to do?",
      }, function(choice)
        if not choice or choice == "Discard" then
          return
        elseif choice == "Override" then
          if winid ~= -1 then
            vim.api.nvim_win_close(winid, true)
          end
          vim.api.nvim_buf_delete(M.term_bufnr, { force = true })
          M.term_bufnr = _create_terminal(opts)
          handle_focus()
        elseif choice == "Create New" then
          _create_terminal(opts) -- Don't save to M.term_bufnr
          handle_focus()
        end
      end)
    else
      -- No new command, just focus the existing terminal
      if winid ~= -1 then
        vim.api.nvim_set_current_win(winid)
      else
        -- Window was closed, reopen it
        vim.cmd("rightbelow vsplit")
        vim.api.nvim_set_current_buf(M.term_bufnr)
        vim.cmd("startinsert")
      end
      handle_focus()
    end
  else
    -- No existing terminal, create a new one
    M.term_bufnr = _create_terminal(opts)
    handle_focus()
  end
end

return M

