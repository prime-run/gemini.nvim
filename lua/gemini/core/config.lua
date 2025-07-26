---@class GeminiConfig
local M = {}

---@type Config
M.options = {}

---@type Config
local defaults = {
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

--- Merges user-provided configuration with the defaults.
---@param args Config?
function M.setup(args)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), args or {})
end

--- Returns the current configuration table.
---@return Config The current configuration.
function M.get()
  return M.options
end

return M
