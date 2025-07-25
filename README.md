# gemini.nvim

A Neovim plugin to open a terminal in a vertical split on the right.

## Installation

Install the plugin with your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

This is the recommended way to install `gemini.nvim`.

```lua
{
  "prime/gemini.nvim",
  -- `opts` will be passed to the `setup` function automatically.
  opts = {
    width = 30,
    cmd = "lazygit",
  },
}
```

Or, if you prefer to call `setup` manually:

```lua
{
  "prime/gemini.nvim",
  config = function()
    require("gemini").setup({
      width = 30,
      cmd = "lazygit",
    })
  end,
}
```

## Configuration

You can configure the plugin by passing an `opts` table to `lazy.nvim` or by calling the `setup` function directly. The options you provide will override the defaults.

**Default Configuration:**
```lua
{
  width = 25, -- width of the terminal in percentage (1-99)
  cmd = nil,  -- command to run when the terminal opens
}
```

**Example Setup:**
```lua
-- In your lazy.nvim spec:
opts = {
  width = 40,
  cmd = "btop",
}
```

## Usage

The plugin provides a user command and a Lua function to open the terminal. These will use the defaults you've set in your configuration.

### Command

You can override the configured settings by passing arguments to the command.

`:Gemini [width] [command]`

- `[width]` (optional): A number from 1 to 99 to specify the terminal width percentage.
- `[command]` (optional): The command to execute in the terminal.

**Examples:**
- `:Gemini`: Opens a terminal with your configured width and command.
- `:Gemini 50`: Opens a terminal with 50% width.
- `:Gemini lazygit`: Opens a terminal with your configured width and runs `lazygit`.
- `:Gemini 40 lazygit`: Opens a terminal with 40% width and runs `lazygit`.

### GeminiAsk Command

The `:GeminiAsk` command is designed to capture the context of your current buffer or visual selection.

- **With a visual selection**: It will echo the relative file path along with the start and end coordinates of your selection.
  - Example output: `@src/main.lua L10C5-L20C15`
- **Without a visual selection**: It will echo the relative file path of the current buffer.
  - Example output: `@src/main.lua`

`:GeminiAsk`

### Lua function

You can also override settings when calling the Lua function directly. This is useful for keymaps.

`require("gemini").open({ width = 40, cmd = "ls -la" })`

**Example Keymaps:**
```lua
-- Open with your default/configured settings
vim.keymap.set("n", "<leader>t", function() require("gemini").open() end, { desc = "Open terminal" })

-- Open with specific options, overriding your defaults
vim.keymap.set("n", "<leader>lg", function() require("gemini").open({ cmd = "lazygit" }) end, { desc = "Open lazygit" })
```