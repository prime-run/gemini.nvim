# gemini.nvim

A powerful Neovim plugin to manage a persistent, context-aware terminal in a vertical split.

## Features

- **Singleton Terminal**: The plugin manages a single terminal instance. Instead of creating duplicates, it intelligently focuses the existing terminal.
- **Context-Aware Commands**: The `:GeminiAsk` command captures file and selection context to run commands with.
- **Interactive Conflict Resolution**: If you send a new command while the terminal is busy, you are prompted to **Discard**, **Override**, or open a **New** terminal.
- **Focus Management**: Automatically returns focus to your original window after opening the terminal (configurable).
- **Customizable**: Configure terminal width, startup command, and focus behavior.

## Installation

Install with your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "prime/gemini.nvim",
  opts = {
    -- Your configuration goes here
    width = 30,
    focus_back = true,
  },
}
```

## Configuration

Configure the plugin by passing an `opts` table to `lazy.nvim` or by calling `require("gemini").setup()` manually.

**Default Configuration:**
```lua
{
  width = 25,        -- Terminal width in percentage (1-99).
  cmd = nil,         -- Default command to run on open.
  focus_back = true, -- Focus back to original window after opening.
}
```

**Example Setup:**
```lua
-- In your lazy.nvim spec:
opts = {
  width = 40,
  focus_back = false,
  cmd = "btop",
}
```

## Usage

The plugin provides two main user commands and a flexible Lua API.

### :Gemini

Opens the terminal with your configured settings. If a command is passed, it will be executed.

`:Gemini [command]`

- `[command]` (optional): The command to execute.

**Examples:**
- `:Gemini`: Opens a terminal with your configured command.
- `:Gemini lazygit`: Opens a terminal and runs `lazygit`.

### :GeminiAsk

This is the plugin's most powerful feature. It prompts for your input, combines it with the current file context (including visual selections), and executes a `gemini -i "..."` command.

**How it works:**
1.  Run `:GeminiAsk` in normal mode or with a visual selection.
2.  A prompt will appear asking for your input.
3.  Your input is combined with the file path and selection range.
4.  The result is executed in the terminal: `gemini -i "YOUR_INPUT @path/to/file L10-L20"`

To use it, you must create a user command in your Neovim configuration:

```lua
-- In your init.lua or a plugin configuration file
vim.api.nvim_create_user_command('GeminiAsk', function()
  require('gemini').GeminiAsk()
end, { range = true, desc = 'Ask Gemini with context' })
```

### Lua Functions

You can call the Lua functions directly for more control, which is ideal for keymaps.

`require("gemini").open({ width = 40, cmd = "ls -la" })`
`require("gemini").GeminiAsk()`

**Example Keymaps:**
```lua
-- Open the terminal with default settings
vim.keymap.set("n", "<leader>t", function() require("gemini").open() end, { desc = "Open terminal" })

-- Open lazygit
vim.keymap.set("n", "<leader>lg", function() require("gemini").open({ cmd = "lazygit" }) end, { desc = "Open lazygit" })

-- Use the interactive GeminiAsk command
vim.keymap.set({"n", "v"}, "<leader>ga", function() require("gemini").GeminiAsk() end, { desc = "Ask Gemini" })
```
