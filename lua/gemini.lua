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

return M