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

-- vim: foldmethod=marker:
