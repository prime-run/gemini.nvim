package = "gemini.nvim"
version = "scm-1"

source = {
  url = "git://github.com/prime/gemini.nvim",
}

description = {
  summary = "A Neovim plugin for interacting with a Gemini command-line tool.",
  homepage = "https://github.com/prime/gemini.nvim",
  license = "MIT",
  maintainer = "prime <prime@example.com>",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["gemini"] = "lua/gemini.lua",
    ["gemini.core.config"] = "lua/gemini/core/config.lua",
    ["gemini.core.terminal"] = "lua/gemini/core/terminal.lua",
    ["gemini.core.context"] = "lua/gemini/core/context.lua",
    ["gemini.core.keymaps"] = "lua/gemini/core/keymaps.lua",
  },
  install = {
    lua = {
      ["gemini"] = "lua/gemini.lua",
      ["gemini.core.config"] = "lua/gemini/core/config.lua",
      ["gemini.core.terminal"] = "lua/gemini/core/terminal.lua",
      ["gemini.core.context"] = "lua/gemini/core/context.lua",
      ["gemini.core.keymaps"] = "lua/gemini/core/keymaps.lua",
    },
  },
  copy_directories = { "doc", "plugin" },
}
