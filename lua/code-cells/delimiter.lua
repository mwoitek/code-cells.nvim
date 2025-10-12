local M = {}

local valid = require "code-cells.validation"

-- Get delimiter {{{
---@param filetype string
---@return string? # User-defined cell delimiter for the given filetype
local function get_user_delimiter(filetype)
  if filetype == "" then return end
  local name = string.format("%s_delim", filetype)
  for _, vars in ipairs { vim.b, vim.g } do
    local var = vars[name]
    if type(var) == "string" then return var end
  end
end

---@param commentstring string
---@return string? # Cell delimiter built from commentstring
local function build_delimiter(commentstring)
  return commentstring:find "%%s" and commentstring:format "%%" or nil
end

---@return string? # Cell delimiter
function M.get()
  local delim = get_user_delimiter(vim.bo.filetype) or build_delimiter(vim.bo.commentstring)
  if not delim then
    local msg = "[code-cells] Current buffer does not have a valid delimiter"
    vim.notify(msg, vim.log.levels.WARN)
  end
  return delim
end
-- }}}

-- Get delimiter pattern {{{
---@param delimiter string? Cell delimiter
---@return string? # Vimscript regex that matches the given cell delimiter
function M.get_pattern(delimiter)
  if delimiter == nil then delimiter = M.get() end
  vim.validate("delimiter", delimiter, "string", true)
  if not delimiter then return end
  return [[\V\^]] .. vim.fn.escape(delimiter, [[\/?]]):gsub("%s+", [[\s\*]])
end
-- }}}

-- Find lines that match a pattern {{{
---@param pattern string Vimscript regex
---@param first_line integer? First line of the search region
---@param last_line integer? Last line of the search region
---@param max_matches integer? Maximum number of matches
---@return integer[]? # Lines where there is a match, or nil if no match was found
local function find_matching_lines(pattern, first_line, last_line, max_matches)
  vim.validate("pattern", pattern, "string")

  if first_line == nil then first_line = 1 end
  local line_count ---@type integer?
  if last_line == nil then
    line_count = vim.api.nvim_buf_line_count(0)
    last_line = line_count
  end

  local range = require "code-cells.range"
  if not range.is_valid(first_line, last_line) then return end

  vim.validate("max_matches", max_matches, valid.positive_integer, true)
  if not max_matches then
    line_count = line_count or vim.api.nvim_buf_line_count(0)
    max_matches = line_count + 1
  end

  local matches = {} ---@type integer[]
  local regex = vim.regex(pattern)
  local line = first_line

  while line <= last_line and #matches < max_matches do
    local start = regex:match_line(0, line - 1)
    if type(start) == "number" then matches[#matches + 1] = line end
    line = line + 1
  end

  return #matches > 0 and matches or nil
end
-- }}}

-- Find n-th delimiter {{{
---@param dir cells.Direction Search direction
---@param n integer? Ordinality (e.g, n=2 is second)
---@param opts cells.FindOpts? Search options
---@return integer? # Number of line containing the delimiter
function M.find_nth(dir, n, opts)
  -- NOTE: I won't bother with the validation of dir, since this parameter will
  -- be removed when I refactor this function.

  if n == nil then n = 1 end
  vim.validate("n", n, valid.non_zero_integer, "non-zero integer")

  -- TODO: implement more robust validation for such tables
  vim.validate("opts", opts, "table", true)
  opts = opts or {}

  if n < 0 then
    dir = dir == "up" and "down" or "up"
    n = -n
  end

  local delim_pattern = M.get_pattern()
  if not delim_pattern then return end

  local first_line ---@type integer
  local last_line ---@type integer

  local curr_line = vim.fn.line "."
  if dir == "up" then
    first_line = 1
    last_line = opts.include_curr and curr_line or curr_line - 1
  else
    first_line = curr_line + 1
    last_line = vim.api.nvim_buf_line_count(0)
  end

  local line_nums = find_matching_lines(delim_pattern, first_line, last_line)
  if not line_nums then return end

  local line_count = #line_nums
  if line_count < n then
    if not opts.allow_less then return end
    return dir == "up" and line_nums[1] or line_nums[line_count]
  end
  return dir == "up" and line_nums[line_count - n + 1] or line_nums[n]
end
-- }}}

return M

-- vim: foldmethod=marker:
