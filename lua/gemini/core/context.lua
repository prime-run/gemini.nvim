---@class GeminiContext
local M = {}

---@alias GetContextOpts { use_range: boolean }

-- Get the visual selection, or the whole file, and format it as a string.
---@param opts GetContextOpts?
---@return string?|nil, string? err
function M.get_context_string(opts)
  opts = opts or {}
  local use_range = opts.use_range

  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return nil, "No buffer name"
  end

  local context_path = vim.fn.fnamemodify(file_path, ":p")
  local selection_range = ""

  if use_range then
    local pos1 = vim.fn.getpos("'<")
    local pos2 = vim.fn.getpos("'>")
    local start_line = pos1[2]
    local start_col = pos1[3]
    local end_line = pos2[2]
    local end_col = pos2[3]

    if start_line ~= 0 and end_line ~= 0 then
      selection_range = string.format(" L%dC%d-L%dC%d", start_line, start_col, end_line, end_col)
    end
  end

  return string.format("@%s%s", context_path, selection_range)
end

-- Formats the context string into a GitHub-style address.
---@param context_string string?
---@return string?|nil, string? err
function M.format_context(context_string)
  if not context_string then
    return nil, "Invalid context string"
  end

  local file_match = context_string:match("@([^ ]+)")
  local range_match = context_string:match("L(%d+)C(%d+)-L(%d+)C(%d+)")

  if not file_match then
    return nil, "Could not parse file path"
  end

  local file_name = vim.fn.fnamemodify(file_match, ":.")
  local parsed_string = "@" .. file_name

  if range_match then
    local sL, sC, eL, eC = context_string:match("L(%d+)C(%d+)-L(%d+)C(%d+)")
    parsed_string = string.format("%s:%s:%s-%s:%s", parsed_string, sL, sC, eL, eC)
  end

  return parsed_string
end

return M
