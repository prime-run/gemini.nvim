local config = require("gemini.core.config")

---@class CustomModule
local M = {}

---@class TerminalState
---@field bufnr number The buffer number of the terminal.
---@field winid number The window ID of the terminal.
---@field opts table The options used to create the terminal.
---@type table<number, TerminalState>
M.terms = {}

---@type number|nil
M.last_active_bufnr = nil

-- Shows an existing terminal buffer in a new window
local function _show_terminal(bufnr, opts)
  local term_opts = opts.terminal or {}
  local width = term_opts.width or 30
  local position = term_opts.position or "right"

  -- Create split
  if position == "left" then
    vim.cmd("topleft vsplit")
    vim.cmd("vertical resize " .. width)
  elseif position == "right" then
    vim.cmd("rightbelow vsplit")
    vim.cmd("vertical resize " .. width)
  elseif position == "top" then
    vim.cmd("topleft split")
    vim.cmd("resize " .. width)
  else -- bottom
    vim.cmd("botright split")
    vim.cmd("resize " .. width)
  end

  local winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winid, bufnr)

  -- Update state
  if M.terms[bufnr] then
    M.terms[bufnr].winid = winid
  end
  M.last_active_bufnr = bufnr

  vim.cmd("startinsert")
end

-- Creates a new terminal process and window
local function _create_terminal(opts)
  -- Create split and window first
  local term_opts = opts.terminal or {}
  local width = term_opts.width or 30
  local position = term_opts.position or "right"

  if position == "left" then
    vim.cmd("topleft vsplit")
  elseif position == "right" then
    vim.cmd("rightbelow vsplit")
  elseif position == "top" then
    vim.cmd("topleft split")
  else -- bottom
    vim.cmd("botright split")
  end
  local winid = vim.api.nvim_get_current_win()

  -- Set CWD
  local cwd = vim.fn.getcwd()
  vim.cmd("lcd " .. vim.fn.fnameescape(cwd))

  -- Get command
  local cmd_to_run = ""
  if opts.cmd then
    if type(opts.cmd) == "table" then
      cmd_to_run = table.concat(vim.tbl_map(vim.fn.shellescape, opts.cmd), " ")
    elseif type(opts.cmd) == "string" and opts.cmd ~= "" then
      cmd_to_run = opts.cmd
    end
  end

  -- This command creates a new buffer and runs the process
  vim.api.nvim_command("terminal " .. cmd_to_run)

  -- Apply size after terminal is created
  if position == "left" or position == "right" then
    vim.cmd("vertical resize " .. width)
  else
    vim.cmd("resize " .. width)
  end

  -- Get the new buffer and configure it
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr].is_gemini_term = true

  -- Auto-enter insert mode when focusing the terminal buffer
  local group = vim.api.nvim_create_augroup("GeminiTerm", { clear = true })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    buffer = bufnr,
    callback = function()
      if vim.b[bufnr] and vim.b[bufnr].is_gemini_term then
        vim.cmd("startinsert")
      end
    end,
  })

  -- Set terminal-mode keymaps
  local keymaps = config.get().keymaps
  if keymaps then
    if keymaps.toggle_gemini then
      vim.keymap.set("t", keymaps.toggle_gemini, function()
        require("gemini.core.terminal").toggle()
      end, { noremap = true, silent = true, buffer = bufnr, desc = "Toggle Gemini terminal" })
    end
    if keymaps.switch_focus then
      vim.keymap.set("t", keymaps.switch_focus, function()
        require("gemini.core.terminal").switch_focus()
      end, { noremap = true, silent = true, buffer = bufnr, desc = "Switch focus to Gemini" })
    end
  end

  vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", {
    noremap = true,
    silent = true,
    buffer = bufnr,
    desc = "Exit terminal mode",
  })

  -- Store state
  local term_state = { bufnr = bufnr, winid = winid, opts = opts }
  M.terms[bufnr] = term_state
  M.last_active_bufnr = bufnr

  vim.cmd("startinsert")
  return term_state
end

function M.open(opts)
  opts = opts or {}
  local original_win = vim.api.nvim_get_current_win()

  local function handle_focus()
    if opts.focus_back then
      vim.api.nvim_set_current_win(original_win)
    end
  end

  -- Check for an existing terminal
  local active_term = M.last_active_bufnr and M.terms[M.last_active_bufnr]
  if active_term and vim.api.nvim_buf_is_valid(active_term.bufnr) then
    local winid = vim.fn.bufwinid(active_term.bufnr)

    if opts.cmd then
      -- Prompt user if a new command is provided
      local prompt = "A Gemini terminal is running. What to do?"
      local options = { "Discard", "Override", "Create New" }
      vim.ui.select(options, { prompt = prompt }, function(choice)
        if not choice or choice == "Discard" then
          return
        elseif choice == "Override" then
          if winid ~= -1 then
            vim.api.nvim_win_close(winid, true)
          end
          vim.api.nvim_buf_delete(active_term.bufnr, { force = true })
          M.terms[active_term.bufnr] = nil
          _create_terminal(opts)
          handle_focus()
        elseif choice == "Create New" then
          _create_terminal(opts)
          handle_focus()
        end
      end)
    else
      -- No new command, just focus or show the existing terminal
      if winid ~= -1 then
        vim.api.nvim_set_current_win(winid)
      else
        -- Window was closed, reopen it
        _show_terminal(active_term.bufnr, active_term.opts)
      end
      handle_focus()
    end
  else
    -- No existing terminal, create a new one
    _create_terminal(opts)
    handle_focus()
  end
end

local function get_gemini_terms()
  local terms = {}
  for bufnr, term in pairs(M.terms) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].is_gemini_term then
      table.insert(terms, term)
    end
  end
  return terms
end

function M.toggle()
  local all_terms = get_gemini_terms()
  if #all_terms == 0 then
    vim.notify("No active gemini-cli buffer.", vim.log.levels.INFO)
    return
  end

  local visible_terms, hidden_terms = {}, {}
  for _, term in ipairs(all_terms) do
    if vim.fn.bufwinid(term.bufnr) ~= -1 then
      table.insert(visible_terms, term)
    else
      table.insert(hidden_terms, term)
    end
  end

  if #visible_terms > 0 then
    -- Hide all visible terminals
    for _, term in ipairs(visible_terms) do
      vim.api.nvim_win_hide(term.winid)
    end
  else
    -- Show a hidden terminal
    if #hidden_terms == 1 then
      _show_terminal(hidden_terms[1].bufnr, hidden_terms[1].opts)
    elseif #hidden_terms > 1 then
      local opts = {}
      for i, term in ipairs(hidden_terms) do
        table.insert(opts, string.format("%d: %s", i, vim.api.nvim_buf_get_name(term.bufnr)))
      end
      vim.ui.select(opts, { prompt = "Select a Gemini buffer to show:" }, function(choice)
        if not choice then
          return
        end
        local idx = tonumber(choice:match("^%d+"))
        if idx and hidden_terms[idx] then
          _show_terminal(hidden_terms[idx].bufnr, hidden_terms[idx].opts)
        end
      end)
    end
  end
end

function M.switch_focus()
  local active_term = M.last_active_bufnr and M.terms[M.last_active_bufnr]
  if not active_term or not vim.api.nvim_buf_is_valid(active_term.bufnr) then
    vim.notify("No active gemini-cli buffer.", vim.log.levels.INFO)
    return
  end

  local winid = vim.fn.bufwinid(active_term.bufnr)
  if winid ~= -1 then
    if vim.api.nvim_get_current_win() == winid then
      -- Find another window to focus
      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        if w ~= winid then
          vim.api.nvim_set_current_win(w)
          return
        end
      end
    else
      -- Focus the terminal
      vim.api.nvim_set_current_win(winid)
      vim.cmd("startinsert")
    end
  else
    vim.notify("Gemini terminal is not visible.", vim.log.levels.INFO)
  end
end

return M
