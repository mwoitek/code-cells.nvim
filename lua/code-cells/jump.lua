local M = {}

-- Jump to cells {{{
---@param dir cells.Direction Jump direction
---@param count integer? Number of jumps
local function jump_to_cell(dir, count)
  if count == 0 then return end
  local delimiter = require "code-cells.delimiter"
  local delim_line = delimiter.find_nth(dir, count, { allow_less = true })
  if delim_line then vim.api.nvim_win_set_cursor(0, { delim_line, 0 }) end
end

---@param count integer? Number of jumps
function M.jump_to_prev(count) jump_to_cell("up", count) end

---@param count integer? Number of jumps
function M.jump_to_next(count) jump_to_cell("down", count) end
-- }}}

return M

-- vim: foldmethod=marker:
