---@class Gemini
local M = {}

local config = require("gemini.core.config")
local terminal = require("gemini.core.terminal")
local context = require("gemini.core.context")
local keymaps = require("gemini.core.keymaps")

--- Setup function for the plugin. Merges user-provided configuration.
---@param args Config?
function M.setup(args)
  config.setup(args)
  keymaps.setup({
    open = M.open,
    GeminiAsk = M.GeminiAsk,
    toggle = terminal.toggle,
    switch_focus = terminal.switch_focus,
  })
end

-- This is the function that users will call.
-- It merges the default config with any runtime options.
---@param opts Config?
function M.open(opts)
  local merged_opts = vim.tbl_deep_extend("force", {}, config.get(), opts or {})
  terminal.open(merged_opts)
end

-- Asks the user for input and opens Gemini with the context.
function M.GeminiAsk()
  -- Automatically detect if a visual selection was made.
  local start_line = vim.fn.line("'<")
  local use_range = start_line ~= 0

  vim.ui.input({ prompt = "Ask Gemini: " }, function(input)
    if not input or input == "" then
      vim.notify("GeminiAsk cancelled.", vim.log.levels.INFO)
      return
    end

    local context_string, err = context.get_context_string({ use_range = use_range })
    if err then
      vim.notify(err, vim.log.levels.WARN)
      return
    end

    local parsed_string, parse_err = context.parse_context(context_string)
    if parse_err then
      vim.notify(parse_err, vim.log.levels.ERROR)
      return
    end

    local final_string = input .. " " .. parsed_string
    M.open({ cmd = { "gemini", "-i", final_string } })
  end)
end

vim.api.nvim_create_user_command("Gemini", function(cmd_opts)
  ---@param cmd_opts CommandOpts
  ---@type { width?: number|string, cmd?: string|table }
  local opts = {}
  local fargs = cmd_opts.fargs or {}

  if #fargs > 0 then
    local first_arg_num = tonumber(fargs[1])
    if first_arg_num and first_arg_num > 0 and first_arg_num < 100 then
      opts.width = first_arg_num
      if #fargs > 1 then
        opts.cmd = table.concat(fargs, " ", 2) -- The rest is the command
      end
    else
      opts.cmd = table.concat(fargs, " ")
    end
  end

  -- Require the main module and call the open function
  require("gemini").open(opts)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("GeminiAsk", function(cmd_opts)
  ---@param cmd_opts CommandOpts
  -- A range is present if the user selected something visually,
  -- or if they provided an explicit range like :% or :1,5
  local use_range = cmd_opts.range > 0
  require("gemini").ask({ use_range = use_range })
end, { nargs = 0, range = true, bang = true })

vim.api.nvim_create_user_command("GeminiParse", function(cmd_opts)
  ---@param cmd_opts CommandOpts
  local use_range = cmd_opts.range > 0
  local input_text = cmd_opts.fargs and table.concat(cmd_opts.fargs, " ") or ""
  local final_input = input_text == "" and "" or (input_text .. " ")

  require("gemini").ask_and_parse({ use_range = use_range, input = final_input })
end, { nargs = "*", range = true, bang = true })

return M
