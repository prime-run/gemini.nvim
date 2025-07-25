-- main module file
local module = require("gemini.module")

---@class Config
---@field width number|string The percentage of the screen width the terminal should take (e.g., 25).
---@field cmd string|table|nil The command to execute upon opening.
local config = {
  width = 25,
  cmd = nil,
}

---@class Gemini
local M = {}

---@type Config
M.config = config

---@param args Config?
-- Setup function for the plugin. Merges user-provided configuration.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

-- This is the function that users will call.
-- It merges the default config with any runtime options.
M.open = function(opts)
  local merged_opts = vim.tbl_deep_extend("force", {}, M.config, opts or {})
  module.open(merged_opts)
end

-- Get the visual selection, or the whole file, and format it as a string.
M.get_context_string = function(opts)
  opts = opts or {}
  local use_range = opts.use_range

  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return nil, "No buffer name"
  end

  local relative_path = vim.fn.fnamemodify(file_path, ":.")
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

  return string.format("@%s%s", relative_path, selection_range)
end

-- Echoes the context string.
M.ask = function(opts)
  local context_string, err = M.get_context_string(opts)
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  vim.api.nvim_echo({ { context_string, "Normal" } }, false, {})
end

-- Parses the context string into a human-readable format.
M.parse_context = function(context_string)
  if not context_string then
    return nil, "Invalid context string"
  end

  local file_match = context_string:match("@([^ ]+)")
  local range_match = context_string:match("(L%d+C%d+-L%d+C%d+)")

  if not file_match then
    return nil, "Could not parse file path"
  end

  local file_name = vim.fn.fnamemodify(file_match, ":t")
  local parsed_string = "@" .. file_name

  if range_match then
    local sL, sC, eL, eC = range_match:match("L(%d+)C(%d+)-L(%d+)C(%d+)")
    parsed_string = string.format("from line %s column %s to line %s column %s %s", sL, sC, eL, eC, parsed_string)
  end

  return parsed_string
end

-- Gets the context, parses it, and echoes the result.
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

return M
