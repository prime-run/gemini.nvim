local gemini = require("gemini")
local config = require("gemini.core.config")

describe("gemini.nvim", function()
  -- Make sure to reset the configuration before each test
  before_each(function()
    -- Reset the require cache to get a fresh module instance
    package.loaded["gemini"] = nil
    package.loaded["gemini.core.config"] = nil
    gemini = require("gemini")
    config = require("gemini.core.config")
  end)

  describe("setup()", function()
    it("should use default config values", function()
      gemini.setup()
      local c = config.get()
      assert.are.same("right", c.terminal.position)
      assert.are.same(30, c.terminal.width)
      assert.are.same("<leader>ga", c.keymaps.gemini_ask)
    end)

    it("should merge user config with defaults", function()
      gemini.setup({
        terminal = {
          width = 50,
          position = "left",
        },
        keymaps = {
          gemini_ask = "<leader>xx",
        },
      })
      local c = config.get()
      assert.are.same("left", c.terminal.position)
      assert.are.same(50, c.terminal.width)
      assert.are.same("<leader>xx", c.keymaps.gemini_ask)
      assert.are.same(true, c.focus_back) -- Should still have other defaults
    end)
  end)
end)
