# gemini.nvim

A Neovim plugin for interacting with a `gemini` command-line tool, allowing you to ask questions and pass file context directly from the editor.

## Features

-   **Seamless Integration**: Open a `gemini` CLI session in a floating or vertical split terminal without leaving Neovim.
-   **Context-Aware**: Automatically pass the current file path or visual selection as context to your `gemini` commands.
-   **Interactive Prompts**: Provides a `vim.ui.input`-based prompt to ask questions interactively.
-   **Customizable**: Configure the terminal width, command arguments, and window focus behavior.
-   **Singleton Terminal**: Manages a single terminal instance, with options to override, discard, or create new sessions.

## Requirements

-   Neovim 0.8.0+
-   A `gemini` command-line tool installed and available in your system's `PATH`.

## Installation

Install the plugin using your favorite plugin manager.

### lazy.nvim

```lua
{
  "prime/gemini.nvim",
  config = function()
    require("gemini").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "prime/gemini.nvim",
  config = function()
    require("gemini").setup()
  end,
}
```

## Configuration

The plugin comes with the following default configuration, which you can override in the `setup` function.

```lua
require("gemini").setup({
  -- The percentage of the screen width the terminal should take (e.g., 25).
  width = 25,
  -- The command to execute upon opening. Can be a string or a table.
  cmd = nil,
  -- Whether to focus back on the original window after opening the terminal.
  focus_back = true,
})
```

### Example Configuration

Here is a more detailed example:

```lua
require("gemini").setup({
  width = 40,
  cmd = { "gemini", "--arg1" },
  focus_back = false,
})
```

## Usage

The plugin exposes a primary interactive function, `GeminiAsk`, which is the recommended way to use the plugin. It's best to map this to a keybinding.

### Keybindings

Since the most powerful feature is the interactive prompt, it's recommended to map the `GeminiAsk` function.

```lua
-- Set keymaps for asking Gemini questions
local gemini = require("gemini")

-- Normal mode: Ask a question about the current file
vim.keymap.set("n", "<leader>ga", gemini.GeminiAsk, { desc = "Ask Gemini" })

-- Visual mode: Ask a question about the selected text
vim.keymap.set("v", "<leader>ga", function()
    -- The `use_range` option is automatically detected in visual mode.
    gemini.GeminiAsk()
end, { desc = "Ask Gemini (Visual)" })
```

### Commands

The plugin also provides a set of user commands for more direct control:

-   `:Gemini [width] [cmd]`: Opens the Gemini terminal. You can optionally override the configured width and command.
    -   Example: `:Gemini 50 gemini --verbose`
-   `:[range]GeminiAsk`: Echoes the context string for the current file or visual selection. Useful for debugging.
-   `:[range]GeminiParse [text]`: Parses the context and prepends your `[text]` before printing it to the message area.

## License

This plugin is licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for more details.
