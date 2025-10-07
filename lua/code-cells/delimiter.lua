local M = {}

-- Find lines that match a pattern {{{
vim.cmd [[
function! CellsFindMatchingLines(pattern, first_line, last_line)
  let line_nums = []
  let view = winsaveview()
  execute 'sil! keepj keepp ' . a:first_line . ',' . a:last_line . 'g/' .
          \ a:pattern . "/call add(line_nums, line('.'))"
  call winrestview(view)
  return line_nums
endfunction
]]

---@param pattern string Vimscript regex
---@param first_line integer? First line of the search region
---@param last_line integer? Last line of the search region
---@return integer[]? # Lines where there is a match or nil if no match was found
local function find_matching_lines(pattern, first_line, last_line)
  first_line = first_line or 1
  last_line = last_line or vim.api.nvim_buf_line_count(0)
  local line_nums = vim.fn.CellsFindMatchingLines(pattern, first_line, last_line) ---@type integer[]
  return #line_nums > 0 and line_nums or nil
end
-- }}}

-- Find n-th delimiter {{{
---@param dir cells.Direction
---@param n integer?
---@param opts cells.FindOpts?
---@return integer?
function M.find_nth(dir, n, opts)
  n = n or 1
  opts = opts or {}

  -- TODO: generalize the code for getting the cell delimiter
  local delim_pattern = "^# %%"

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

  local range = require "code-cells.range"
  if not range.is_valid(first_line, last_line) then return end

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
