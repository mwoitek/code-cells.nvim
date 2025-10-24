local M = {}

-- Jump to cells {{{
---@param delimiter string? Cell delimiter
---@param count integer? Number of jumps
function M.to_next(delimiter, count)
  if count == 0 then return end
  local delim = require("code-cells.api.delimiter")
  local delim_line = delim.find_nth(delimiter, count or 1, { allow_less = true })
  if delim_line then vim.api.nvim_win_set_cursor(0, { delim_line, 0 }) end
end

---@param delimiter string? Cell delimiter
---@param count integer? Number of jumps
function M.to_prev(delimiter, count) M.to_next(delimiter, -(count or 1)) end
-- }}}

return M

-- vim: foldmethod=marker:
