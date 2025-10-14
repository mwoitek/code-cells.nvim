local M = {}

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
  vim.validate("delimiter", delimiter, "string", true)
  if not delimiter then
    delimiter = M.get()
    if not delimiter then return end
  end
  return [[\V\^]] .. vim.fn.escape(delimiter, [[\/?]]):gsub("%s+", [[\s\*]])
end
-- }}}

-- Find delimiters in a given region {{{
---@param delimiter string? Cell delimiter
---@param first_line integer First line of the search region
---@param last_line integer Last line of the search region (inclusive)
---@param max_matches integer? Maximum number of matches
---@return integer[]? # Lines where there is a match, or nil if no match was found
function M.find(delimiter, first_line, last_line, max_matches)
  local delim_pattern = M.get_pattern(delimiter)
  if not delim_pattern then return end

  local valid = require "code-cells.core.validation"
  vim.validate("first_line", first_line, valid.positive_integer, "positive integer")
  vim.validate("last_line", last_line, valid.positive_integer, "positive integer")

  vim.validate("max_matches", max_matches, valid.positive_integer, true, "positive integer")

  local line_count = nil ---@type integer?
  if not max_matches then
    line_count = vim.api.nvim_buf_line_count(0)
    max_matches = line_count + 1
  end

  local regex = vim.regex(delim_pattern)

  local min_line = first_line
  local max_line = last_line
  local incr = 1
  if min_line > max_line then
    min_line, max_line = max_line, min_line
    incr = -1
  end
  line_count = line_count or vim.api.nvim_buf_line_count(0)
  max_line = math.min(max_line, line_count)

  local matches = {} ---@type integer[]

  local iter_first = min_line
  local iter_last = max_line
  if incr < 0 then
    iter_first, iter_last = iter_last, iter_first
  end

  for line = iter_first, iter_last, incr do
    local start = regex:match_line(0, line - 1)
    if type(start) == "number" then
      matches[#matches + 1] = line
      if #matches == max_matches then break end
    end
  end

  return #matches > 0 and matches or nil
end

---@class cells.delimiter.FindOpts
---@field line integer? Reference line
---@field include_line boolean? Include reference line?
---@field max_matches integer? Maximum number of matches

---@param delimiter string? Cell delimiter
---@param opts cells.delimiter.FindOpts? Search options
---@return integer[]? # Lines where there is a match, or nil if no match was found
function M.find_above(delimiter, opts)
  vim.validate("opts", opts, "table", true)
  if opts then
    vim.validate("include_line", opts.include_line, "boolean", true)
    local valid = require "code-cells.core.validation"
    vim.validate("line", opts.line, valid.positive_integer, true, "positive integer")
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  opts = vim.tbl_extend("keep", opts or {}, {
    line = vim.fn.line ".",
    include_line = false,
    max_matches = line_count + 1,
  })
  opts.line = math.min(opts.line, line_count)

  local last_line = opts.include_line and opts.line or opts.line - 1
  if last_line == 0 then return end

  return M.find(delimiter, last_line, 1, opts.max_matches)
end

---@param delimiter string? Cell delimiter
---@return integer[]? # Lines where there is a match, or nil if no match was found
function M.find_all(delimiter) return M.find(delimiter) end
-- }}}

-- Find n-th delimiter {{{
---@class cells.delimiter.FindNthOpts
---@field allow_less boolean? Allow less matches than expected?
---@field include_curr boolean? Include current line?

---@param delimiter string? Cell delimiter
---@param n integer Search direction and ordinality
---@param opts cells.delimiter.FindNthOpts? Search options
---@return integer? # Number of line containing the delimiter
function M.find_nth(delimiter, n, opts)
  local delim_pattern = M.get_pattern(delimiter)
  if not delim_pattern then return end

  local valid = require "code-cells.core.validation"
  vim.validate("n", n, valid.non_zero_integer, "non-zero integer")

  vim.validate("opts", opts, "table", true)
  if opts then
    vim.validate("allow_less", opts.allow_less, "boolean", true)
    vim.validate("include_curr", opts.include_curr, "boolean", true)
  end
  opts = vim.tbl_extend("keep", opts or {}, {
    allow_less = false,
    include_curr = false,
  })

  local regex = vim.regex(delim_pattern)
  local incr = n < 0 and -1 or 1
  n = math.abs(n)

  local line = vim.fn.line "."
  local is_ok ---@type fun(l: integer): boolean

  if incr < 0 then
    line = opts.include_curr and line or line - 1
    if line == 0 then return end
    is_ok = function(l) return l >= 1 end
  else
    local last_line = vim.fn.line "$"
    if last_line == line then return end
    line = line + 1
    is_ok = function(l) return l <= last_line end
  end

  local last_match = nil ---@type integer?

  while n > 0 and is_ok(line) do
    local start = regex:match_line(0, line - 1)
    if type(start) == "number" then
      last_match = line
      n = n - 1
    end
    line = line + incr
  end

  if n == 0 or opts.allow_less then return last_match end
end
-- }}}

return M

-- vim: foldmethod=marker:
