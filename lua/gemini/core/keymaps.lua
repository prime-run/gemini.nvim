---@class GeminiKeymaps
local M = {}

---@class KeymapFns
---@field open fun()
---@field GeminiAsk fun()
---@field toggle fun()
---@field switch_focus fun()

--- Setup function for the keymaps.
---@param fns KeymapFns
function M.setup(fns)
  local config = require("gemini.core.config").get()
  local keymaps = config.keymaps

  if keymaps.gemini_ask then
    vim.keymap.set({ "n", "v" }, keymaps.gemini_ask, fns.GeminiAsk, { desc = "Ask Gemini" })
  end
  if keymaps.gemini_open then
    vim.keymap.set("n", keymaps.gemini_open, fns.open, { desc = "Open Gemini" })
  end
  if keymaps.toggle_gemini then
    vim.keymap.set({ "n", "i" }, keymaps.toggle_gemini, fns.toggle, { desc = "Toggle Gemini" })
  end
  if keymaps.switch_focus then
    vim.keymap.set({ "n", "i" }, keymaps.switch_focus, fns.switch_focus, { desc = "Switch Focus" })
  end
end

return M
