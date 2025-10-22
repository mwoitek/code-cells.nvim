local M = {}

local api = vim.api
local fn = vim.fn
local min = math.min

-- Get delimiter {{{
---@param filetype string
---@return string? # User-defined cell delimiter for the given filetype
local function get_user_delimiter(filetype)
  if filetype == "" then return end
  local name = string.format("%s_delim", filetype)
  for _, vars in ipairs({ vim.b, vim.g }) do
    local var = vars[name]
    if type(var) == "string" then return var end
  end
end

---@param commentstring string
---@return string? # Cell delimiter built from commentstring
local function build_delimiter(commentstring)
  return commentstring:find("%%s") and commentstring:format("%%") or nil
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
  return [[\V\^]] .. fn.escape(delimiter, [[\/?]]):gsub("%s+", [[\s\*]])
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

  local valid = require("code-cells.core.validation")
  vim.validate("first_line", first_line, valid.positive_integer, "positive integer")
  vim.validate("last_line", last_line, valid.positive_integer, "positive integer")
  vim.validate("max_matches", max_matches, valid.positive_integer, true, "positive integer")

  local line_count ---@type integer?
  if not max_matches then
    line_count = api.nvim_buf_line_count(0)
    max_matches = line_count + 1
  end

  local incr ---@type integer
  line_count = line_count or api.nvim_buf_line_count(0)
  if first_line > last_line then
    incr = -1
    first_line = min(first_line, line_count)
  elseif first_line < last_line then
    incr = 1
    last_line = min(last_line, line_count)
  else
    incr = 1
    first_line = min(first_line, line_count)
    last_line = first_line
  end

  local matches = {} ---@type integer[]
  local regex = vim.regex(delim_pattern)

  for line = first_line, last_line, incr do
    if regex:match_line(0, line - 1) then
      matches[#matches + 1] = line
      if #matches == max_matches then break end
    end
  end

  if #matches > 0 then return matches end
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
    local valid = require("code-cells.core.validation")
    vim.validate("line", opts.line, valid.positive_integer, true, "positive integer")
  end

  local line_count = api.nvim_buf_line_count(0)
  opts = vim.tbl_extend("keep", opts or {}, {
    line = fn.line("."),
    include_line = false,
    max_matches = line_count + 1,
  })
  opts.line = min(opts.line, line_count)

  local last_line = opts.include_line and opts.line or opts.line - 1
  if last_line == 0 then return end

  return M.find(delimiter, last_line, 1, opts.max_matches)
end

---@param delimiter string? Cell delimiter
---@param opts cells.delimiter.FindOpts? Search options
---@return integer[]? # Lines where there is a match, or nil if no match was found
function M.find_below(delimiter, opts)
  vim.validate("opts", opts, "table", true)
  if opts then
    vim.validate("include_line", opts.include_line, "boolean", true)
    local valid = require("code-cells.core.validation")
    vim.validate("line", opts.line, valid.positive_integer, true, "positive integer")
  end

  local line_count = api.nvim_buf_line_count(0)
  opts = vim.tbl_extend("keep", opts or {}, {
    line = fn.line("."),
    include_line = false,
    max_matches = line_count + 1,
  })
  opts.line = min(opts.line, line_count)

  local first_line = opts.include_line and opts.line or opts.line + 1
  if first_line > line_count then return end

  return M.find(delimiter, first_line, line_count, opts.max_matches)
end

---@param delimiter string? Cell delimiter
---@return integer[]? # Lines where there is a match, or nil if no match was found
function M.find_all(delimiter)
  local first_line = 1
  local last_line = api.nvim_buf_line_count(0)
  return M.find(delimiter, first_line, last_line)
end
-- }}}

-- Find n-th delimiter {{{
---@class cells.delimiter.FindNthOpts
---@field line integer? Reference line
---@field include_line boolean? Include reference line?
---@field allow_less boolean? Allow less matches than expected?

---@param delimiter string? Cell delimiter
---@param n integer Search direction and ordinality
---@param opts cells.delimiter.FindNthOpts? Search options
---@return integer? # Number of line containing the delimiter
function M.find_nth(delimiter, n, opts)
  local delim_pattern = M.get_pattern(delimiter)
  if not delim_pattern then return end

  vim.validate("opts", opts, "table", true)

  local valid = require("code-cells.core.validation")
  vim.validate("n", n, valid.non_zero_integer, "non-zero integer")

  if opts then
    vim.validate("allow_less", opts.allow_less, "boolean", true)
    vim.validate("include_line", opts.include_line, "boolean", true)
    vim.validate("line", opts.line, valid.positive_integer, true, "positive integer")
  end

  opts = vim.tbl_extend("keep", opts or {}, {
    line = fn.line("."),
    include_line = false,
    allow_less = false,
  })

  local incr ---@type integer
  if n < 0 then
    incr = -1
    n = -n
  else
    incr = 1
  end

  local line_count = api.nvim_buf_line_count(0)
  local iter_first = min(opts.line, line_count)
  if not opts.include_line then iter_first = iter_first + incr end

  local iter_last ---@type integer
  if incr == -1 then
    if iter_first == 0 then return end
    iter_last = 1
  else
    if iter_first > line_count then return end
    iter_last = line_count
  end

  local last_match ---@type integer?
  local regex = vim.regex(delim_pattern)

  for line = iter_first, iter_last, incr do
    if regex:match_line(0, line - 1) then
      last_match = line
      n = n - 1
      if n == 0 then break end
    end
  end

  if n == 0 or opts.allow_less then return last_match end
end
-- }}}

return M

-- vim: foldmethod=marker:
