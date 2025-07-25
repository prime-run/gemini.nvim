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
M.ask = function(opts)
  opts = opts or {}
  local use_range = opts.use_range

  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    vim.notify("No buffer name", vim.log.levels.WARN)
    return
  end

  local relative_path = vim.fn.fnamemodify(file_path, ":.")
  local selection_range = ""

  if use_range then
    local start_line = vim.fn.line("'<")
    local start_col = vim.fn.col("'<")
    local end_line = vim.fn.line("'>")
    local end_col = vim.fn.col("'>")

    -- Check if the mark is valid before formatting
    if start_line ~= 0 and end_line ~= 0 then
      selection_range = string.format(" L%dC%d-L%dC%d", start_line, start_col, end_line, end_col)
    end
  end

  local output = string.format("@%s%s", relative_path, selection_range)
  vim.api.nvim_echo({ { output, "Normal" } }, false, {})
end

return M
