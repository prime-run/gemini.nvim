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
    local start_line = vim.fn.line("'<")
    local start_col = vim.fn.col("'<")
    local end_line = vim.fn.line("'>")
    local end_col = vim.fn.col("'>")

    if start_line ~= 0 and end_line ~= 0 then
      selection_range = string.format(" L%dC%d-L%dC%d", start_line, start_col, end_line, end_col)
    end
  end

  return string.format("@%s%s", context_path, selection_range)
end

-- Parses the context string into a human-readable format.
---@param context_string string?
---@return string?|nil, string? err
function M.parse_context(context_string)
  if not context_string then
    return nil, "Invalid context string"
  end

  local file_match = context_string:match("@([^ ]+)")
  local range_match = context_string:match("(L%d+C%d+-L%d+C%d+)")

  if not file_match then
    return nil, "Could not parse file path"
  end

  local file_name = vim.fn.fnamemodify(file_match, ":.")
  local parsed_string = "@" .. file_name

  if range_match then
    local sL, sC, eL, eC = range_match:match("L(%d+)C(%d+)-L(%d+)C(%d+)")
    parsed_string = string.format("from line %s column %s to line %s column %s %s", sL, sC, eL, eC, parsed_string)
  end

  return parsed_string
end

return M
