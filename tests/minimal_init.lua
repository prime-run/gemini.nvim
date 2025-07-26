-- tests/minimal_init.lua
-- This file is run by Neovim before the tests start.
-- It is responsible for setting up the test environment.

-- Get plenary.nvim, which is used for testing
local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
if vim.fn.isdirectory(plenary_dir) == 0 then
  vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end
vim.opt.rtp:append(plenary_dir)

-- Add the current directory to the runtime path
vim.opt.rtp:append(".")

-- Load plenary's busted integration
-- This must be done *before* the test command is run
vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
