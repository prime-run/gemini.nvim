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
  -- The command to execute upon opening. Can be a string or a table.
  cmd = nil,
  -- Whether to focus back on the original window after opening the terminal.
  focus_back = true,
  -- Styling options for the terminal window.
  terminal = {
    width = 30,
    position = "right", -- Can be 'left', 'right', 'top', or 'bottom'
  },
  -- Keymappings for plugin actions. Set to `false` to disable a mapping.
  keymaps = {
    gemini_ask = "<leader>ga",
    gemini_open = false,
    toggle_gemini = "<leader>gt",
    switch_focus = "<leader>gf",
  },
})
```

### Example Configuration

Here is a more detailed example:

```lua
require("gemini").setup({
  cmd = { "gemini", "--arg1" },
  focus_back = false,
  terminal = {
    width = 40,
    position = "left",
  },
  keymaps = {
    gemini_ask = "<leader>za",
    toggle_gemini = "<leader>zt",
    switch_focus = "<leader>zf",
  },
})
```

## Usage

The plugin is primarily controlled via keymaps.

### Keybindings

The following keymaps are available and can be configured in the `keymaps` table of the `setup` function:

-   `gemini_ask`: The primary interactive function. It is recommended to map this.
-   `gemini_open`: Opens the Gemini terminal without any specific prompt. Disabled by default.
-   `toggle_gemini`: Toggles the visibility of the Gemini terminal window.
-   `switch_focus`: Switches focus to and from the Gemini terminal window.

Here is an example of how to set the keymaps:

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
