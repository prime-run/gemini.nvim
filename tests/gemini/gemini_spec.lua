local gemini = require "gemini"

describe("gemini.nvim", function()
  -- Make sure to reset the configuration before each test
  before_each(function()
    -- Reset the require cache to get a fresh module instance
    package.loaded["gemini"] = nil
    package.loaded["gemini.module"] = nil
    gemini = require "gemini"
  end)

  describe("setup()", function()
    it("should use default config values", function()
      gemini.setup()
      local config = gemini.get_config() -- We may need to expose config for testing
      assert.are.same("right", config.terminal.position)
      assert.are.same(30, config.terminal.width)
      assert.are.same("<leader>ga", config.keymaps.gemini_ask)
    end)

    it("should merge user config with defaults", function()
      gemini.setup {
        terminal = {
          width = 50,
          position = "left",
        },
        keymaps = {
          gemini_ask = "<leader>xx",
        },
      }
      local config = gemini.get_config()
      assert.are.same("left", config.terminal.position)
      assert.are.same(50, config.terminal.width)
      assert.are.same("<leader>xx", config.keymaps.gemini_ask)
      assert.are.same(true, config.focus_back) -- Should still have other defaults
    end)
  end)
end)