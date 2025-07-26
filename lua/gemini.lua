-- main module file
local module = require("gemini.module")

---@class Config
---@field width number|string The percentage of the screen width the terminal should take (e.g., 25).
---@field cmd string|table|nil The command to execute upon opening.
---@class TerminalOpts
---@field width number The width of the terminal window. For vertical splits, this is the character width; for horizontal splits, it is the number of rows.
---@field position 'left'|'right'|'top'|'bottom' The position of the terminal window.

---@class KeymapOpts
---@field gemini_ask string|false Mapping for the interactive ask function (`GeminiAsk`).
---@field gemini_open string|false Mapping for the bare open function (`Gemini`).
---@field toggle_gemini string|false Mapping for toggling the terminal window (`gemini.toggle`). Works in normal, insert, and terminal modes.
---@field switch_focus string|false Mapping for switching focus to/from the terminal (`gemini.switch_focus`). Works in normal, insert, and terminal modes.

---@class Config
---@field cmd string|table|nil The command to execute upon opening. Can be a string or a table of strings (e.g., `{"gemini", "--verbose"}`).
---@field focus_back boolean Whether to focus back on the original window after opening the terminal.
---@field terminal TerminalOpts Styling options for the terminal window.
---@field keymaps KeymapOpts Mappings for plugin actions. Set any key to `false` to disable it.
local config = {
  cmd = nil,
  focus_back = true,
  terminal = {
    width = 30,
    position = "right",
  },
  keymaps = {
    gemini_ask = "<leader>ga",
    gemini_open = false,
    toggle_gemini = "<leader>gt",
    switch_focus = "<leader>gf",
  },
}

---@class Gemini
local M = {}

---@type Config
M.config = config

--- Setup function for the plugin. Merges user-provided configuration.
---@param args Config?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})

  local keymaps = M.config.keymaps
  if keymaps.gemini_ask then
    vim.keymap.set({ "n", "v" }, keymaps.gemini_ask, M.GeminiAsk, { desc = "Ask Gemini" })
  end
  if keymaps.gemini_open then
    vim.keymap.set("n", keymaps.gemini_open, M.open, { desc = "Open Gemini" })
  end
  if keymaps.toggle_gemini then
    vim.keymap.set({ "n", "i" }, keymaps.toggle_gemini, module.toggle, { desc = "Toggle Gemini" })
  end
  if keymaps.switch_focus then
    vim.keymap.set({ "n", "i" }, keymaps.switch_focus, module.switch_focus, { desc = "Switch Focus" })
  end
end

-- This is the function that users will call.
-- It merges the default config with any runtime options.
---@param opts Config?
M.open = function(opts)
  local merged_opts = vim.tbl_deep_extend("force", {}, M.config, opts or {})
  module.open(merged_opts)
end

---@alias GetContextOpts { use_range: boolean }

-- Get the visual selection, or the whole file, and format it as a string.
---@param opts GetContextOpts?
---@return string?|nil, string? err
M.get_context_string = function(opts)
  opts = opts or {}
  local use_range = opts.use_range

  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return nil, "No buffer name"
  end

  local context_path = vim.fn.fnamemodify(file_path, ":p")
  local selection_range = ""

  if use_range then
    local start_line = vim.fn.line("'<")
    local start_col = vim.fn.col("'<")
    local end_line = vim.fn.line("'>")
    local end_col = vim.fn.col("'>")

    if start_line ~= 0 and end_line ~= 0 then
      selection_range = string.format(" L%dC%d-L%dC%d", start_line, start_col, end_line, end_col)
    end
  end

  return string.format("@%s%s", context_path, selection_range)
end

-- Echoes the context string.
---@param opts GetContextOpts?
M.ask = function(opts)
  local context_string, err = M.get_context_string(opts)
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  vim.api.nvim_echo({ { context_string, "Normal" } }, false, {})
end

-- Parses the context string into a human-readable format.
---@param context_string string?
---@return string?|nil, string? err
M.parse_context = function(context_string)
  if not context_string then
    return nil, "Invalid context string"
  end

  local file_match = context_string:match("@([^ ]+)")
  local range_match = context_string:match("(L%d+C%d+-L%d+C%d+)")

  if not file_match then
    return nil, "Could not parse file path"
  end

  local file_name = vim.fn.fnamemodify(file_match, ":.")
  local parsed_string = "@" .. file_name

  if range_match then
    local sL, sC, eL, eC = range_match:match("L(%d+)C(%d+)-L(%d+)C(%d+)")
    parsed_string = string.format("from line %s column %s to line %s column %s %s", sL, sC, eL, eC, parsed_string)
  end

  return parsed_string
end

---@alias AskAndParseOpts { use_range: boolean, input: string }

-- Gets the context, parses it, and echoes the result.
---@param opts AskAndParseOpts?
M.ask_and_parse = function(opts)
  opts = opts or {}
  local input_text = opts.input or ""

  local context_string, err = M.get_context_string(opts)
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local parsed_string, parse_err = M.parse_context(context_string)
  if parse_err then
    vim.notify(parse_err, vim.log.levels.ERROR)
    return
  end

  local final_string = input_text .. parsed_string
  -- Use print() to add a newline, as requested.
  print(final_string)
end

-- Asks the user for input and opens Gemini with the context.
M.GeminiAsk = function()
  -- Automatically detect if a visual selection was made.
  local start_line = vim.fn.line("'<")
  local use_range = start_line ~= 0

  vim.ui.input({ prompt = "Ask Gemini: " }, function(input)
    if not input or input == "" then
      vim.notify("GeminiAsk cancelled.", vim.log.levels.INFO)
      return
    end

    local context_string, err = M.get_context_string({ use_range = use_range })
    if err then
      vim.notify(err, vim.log.levels.WARN)
      return
    end

    local parsed_string, parse_err = M.parse_context(context_string)
    if parse_err then
      vim.notify(parse_err, vim.log.levels.ERROR)
      return
    end

    local final_string = input .. " " .. parsed_string
    M.open({ cmd = { "gemini", "-i", final_string } })
  end)
end

--- Returns the current configuration table.
---@return Config The current configuration.
function M.get_config()
  return M.config
end

return M
