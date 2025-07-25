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

