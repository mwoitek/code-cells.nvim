local M = {}

local api = vim.api
local fn = vim.fn

---@param s string Input string
---@return boolean # true if input is empty, false otherwise
local function is_empty_string(s)
  local start = string.find(s, "^%s*$")
  return type(start) == "number"
end

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

---@param c1 cells.Cell First cell
---@param c2 cells.Cell Second cell
---@return boolean # true if cells are equal, false otherwise
function Cell.__eq(c1, c2) return c1.first_line == c2.first_line and c1.last_line == c2.last_line end

---@return cells.Cell # Trimmed code cell
function Cell:trim_top()
  local new_first = self.first_line + 1
  local lstr ---@type string?

  while new_first <= self.last_line do
    lstr = fn.getline(new_first)
    if is_empty_string(lstr) then
      new_first = new_first + 1
    else
      break
    end
  end

  if new_first > self.last_line then
    return lstr and Cell.new(self.first_line + 1, self.last_line) or self
  end
  return Cell.new(new_first, self.last_line)
end

---@return cells.Cell # Trimmed code cell
function Cell:trim_bottom()
  local new_last = self.last_line
  local lstr ---@type string?

  while new_last > self.first_line do
    lstr = fn.getline(new_last)
    if is_empty_string(lstr) then
      new_last = new_last - 1
    else
      break
    end
  end

  if new_last == self.first_line then
    return lstr and Cell.new(self.first_line, self.first_line + 1) or self
  end
  return Cell.new(self.first_line, new_last)
end

---@param skip_lead_blanks boolean? Skip leading blank lines?
---@return cells.Cell # Inner part of the given cell
function Cell:inner(skip_lead_blanks)
  if skip_lead_blanks == nil then skip_lead_blanks = true end
  local inner = self:trim_bottom()
  if skip_lead_blanks then return inner:trim_top() end
  local new_first = inner.first_line + 1
  if new_first <= inner.last_line then inner.first_line = new_first end
  return inner
end

M.Cell = Cell

return M
