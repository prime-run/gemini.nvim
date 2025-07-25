vim.api.nvim_create_user_command("Gemini", function(cmd_opts)
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
  -- A range is present if the user selected something visually,
  -- or if they provided an explicit range like :% or :1,5
  local use_range = cmd_opts.range > 0
  require("gemini").ask({ use_range = use_range })
end, { nargs = 0, range = true, bang = true })

vim.api.nvim_create_user_command("GeminiParse", function(cmd_opts)
  local use_range = cmd_opts.range > 0
  local input_text = cmd_opts.fargs and table.concat(cmd_opts.fargs, " ") or ""
  local final_input = input_text == "" and "" or (input_text .. " ")

  require("gemini").ask_and_parse({ use_range = use_range, input = final_input })
end, { nargs = "*", range = true, bang = true })

