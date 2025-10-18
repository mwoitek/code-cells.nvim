local M = {}

local api = vim.api
local fn = vim.fn

---@param s string Input string
---@return boolean # true if input is empty, false otherwise
local function is_empty_string(s)
  local start = string.find(s, "^%s*$")
  return start ~= nil
end

---@class cells.Cell Code cell
---@field first_line integer Cell's first line
---@field last_line integer Cell's last line
local Cell = {}
Cell.__index = Cell

---@param first_line integer Cell's first line
---@param last_line integer? Cell's last line
---@return cells.Cell # Code cell
function Cell.new(first_line, last_line)
  local obj = {
    first_line = first_line,
    last_line = last_line or api.nvim_buf_line_count(0),
  }
  return setmetatable(obj, Cell)
end

---@return integer # First line of the cell's inner layer
---@return integer # Last line of the cell's inner layer
function Cell:inner()
  local first = self.first_line + 1
  local last = self.last_line
  if first > last then return self.first_line, self.last_line end

  local lstr = fn.getline(last)
  if not is_empty_string(lstr) then return first, last end

  last = last - 1
  if last >= first then return first, last end
  return self.first_line, self.last_line
end

---@return integer? # Cell's first non-blank line
function Cell:first_non_blank()
  local first = self.first_line + 1

  while first <= self.last_line do
    local lstr = fn.getline(first)
    if is_empty_string(lstr) then
      first = first + 1
    else
      break
    end
  end

  if first <= self.last_line then return first end
end

---@return integer? # Cell's last non-blank line
function Cell:last_non_blank()
  local last = self.last_line

  while last > self.first_line do
    local lstr = fn.getline(last)
    if is_empty_string(lstr) then
      last = last - 1
    else
      break
    end
  end

  if last > self.first_line then return last end
end

---@return integer # First line of the cell's core layer
---@return integer # Last line of the cell's core layer
function Cell:core()
  local first = self:first_non_blank()
  if not first then return self:inner() end
  local last = assert(self:last_non_blank())
  return first, last
end

---@alias cells.cell.Layer "outer"|"inner"|"core"

---@param layer cells.cell.Layer Cell layer
---@return integer # Cell's first line for the given layer
---@return integer # Cell's last line for the given layer
function Cell:range(layer)
  if layer == "outer" then
    return self.first_line, self.last_line
  elseif layer == "inner" then
    return self:inner()
  else
    return self:core()
  end
end

---@alias cells.cell.Position "first"|"last"

---@param layer cells.cell.Layer Cell layer
---@param position cells.cell.Position Jump position (first or last line)
function Cell:jump(layer, position)
  local first, last = self:range(layer)
  local line = position == "first" and first or last
  api.nvim_win_set_cursor(0, { line, 0 })
end

---@param layer cells.cell.Layer Cell layer
function Cell:select(layer)
  local mode = api.nvim_get_mode()
  if mode:lower() ~= "v" then return end
  vim.cmd("normal! " .. mode)

  local first, last = self:range(layer)
  api.nvim_win_set_cursor(0, { first, 0 })
  vim.cmd "normal! V"

  local last_col = fn.col { last, "$" } - 1
  api.nvim_win_set_cursor(0, { last, last_col })
end

M.Cell = Cell

return M
