local M = {}

local api = vim.api

---@class cells.Cell Code cell
---@field first_line integer Cell's first line
---@field last_line integer Cell's last line
local Cell = {}
Cell.__index = Cell

---@param first_line integer? Cell's first line
---@param last_line integer? Cell's last line
---@return cells.Cell # Code cell
function Cell.new(first_line, last_line)
  local obj = {
    first_line = first_line or 1,
    last_line = last_line or api.nvim_buf_line_count(0),
  }
  return setmetatable(obj, Cell)
end

M.Cell = Cell

return M
