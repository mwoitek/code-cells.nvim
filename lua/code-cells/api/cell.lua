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
local Cell_mt = { __index = Cell }

---@param first_line integer Cell's first line
---@param last_line integer? Cell's last line
---@return cells.Cell # Code cell
function Cell.new(first_line, last_line)
  local self = {
    first_line = first_line,
    last_line = last_line or api.nvim_buf_line_count(0),
  }
  self = setmetatable(self, Cell_mt)
  return self:skip_modelines()
end

local MODELINE_REGEX = vim.regex([[\v^(.*\s+)=([Vv]im=|ex)([<\=>]=\d+)=\:\s*]])

---@return cells.Cell
function Cell:skip_modelines()
  -- NOTE: Modelines at the top of the file are not a problem. So this method
  -- only tries to skip those at the end.

  local diff = api.nvim_buf_line_count(0) - vim.o.modelines
  local line = math.max(diff, self.first_line) + 1
  if line > self.last_line then return self end

  local count = 0
  while line <= self.last_line and count < vim.o.modelines do
    if MODELINE_REGEX:match_line(0, line - 1) then break end
    line = line + 1
    count = count + 1
  end

  if line <= self.last_line and count < vim.o.modelines then self.last_line = line - 1 end
  return self
end

---@return integer? # First line of the cell's inner layer
---@return integer? # Last line of the cell's inner layer
function Cell:inner()
  local first = self.first_line + 1
  local last = self.last_line
  if first > last then return end

  local lstr = fn.getline(last)
  if not is_empty_string(lstr) then return first, last end

  last = last - 1
  if last >= first then return first, last end
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

---@return integer? # First line of the cell's core layer
---@return integer? # Last line of the cell's core layer
function Cell:core()
  local first = self:first_non_blank()
  if not first then return self:inner() end
  local last = self:last_non_blank() ---@cast last - ?
  return first, last
end

---@param layer cells.CellLayer Cell layer
---@param force boolean? Force method to return non-nil results?
---@return integer? # Cell's first line for the given layer
---@return integer? # Cell's last line for the given layer
function Cell:range(layer, force)
  if layer == "inner" or layer == "core" then
    local first, last = self[layer](self)
    if first then
      return first, last
    elseif not force then
      return
    end
  end
  return self.first_line, self.last_line
end

---@param layer cells.CellLayer Cell layer
---@param position cells.CellPosition Jump position (first or last line)
function Cell:jump(layer, position)
  local first, last = self:range(layer, true)
  ---@cast first - ?
  ---@cast last - ?
  local line = position == "last" and last or first
  api.nvim_win_set_cursor(0, { line, 0 })
end

---@param layer cells.CellLayer Cell layer
function Cell:select(layer)
  -- TODO: expand existing selection

  local mode = api.nvim_get_mode().mode
  if mode:lower() ~= "v" then return end
  vim.cmd("normal! " .. mode)

  local first, last = self:range(layer)
  if not first then return end

  api.nvim_win_set_cursor(0, { first, 0 })
  vim.cmd("normal! V")

  local last_col = fn.col({ last, "$" }) - 1
  api.nvim_win_set_cursor(0, { last, last_col })
end

---@param delimiter string? Cell delimiter
---@param line integer? Reference line
---@return cells.Cell? # Surrounding cell, or nil if there is none
function M.find_surrounding(delimiter, line)
  local delim = require("code-cells.api.delimiter")

  local first_line = delim.find_nth(delimiter, -1, {
    line = line,
    include_line = true,
  })
  if not first_line then return end

  local last_line = delim.find_nth(delimiter, 1, { line = first_line })
  if last_line then last_line = last_line - 1 end

  return Cell.new(first_line, last_line)
end

---@param delimiter string? Cell delimiter
---@param line integer? Reference line
---@return cells.Cell? # Closest cell, or nil if there is none
function M.find_closest(delimiter, line)
  local surrounding = M.find_surrounding(delimiter, line)
  if surrounding then return surrounding end

  local lnums = require("code-cells.api.delimiter").find_below(delimiter, {
    line = line,
    max_matches = 2,
  })
  if not lnums then return end

  local first_line = lnums[1]
  local last_line = lnums[2] ---@type integer?
  if last_line then last_line = last_line - 1 end

  return Cell.new(first_line, last_line)
end

M.Cell = Cell

return M
