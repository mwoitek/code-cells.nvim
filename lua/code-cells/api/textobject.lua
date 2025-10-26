local M = {}

local api = vim.api
local fn = vim.fn

---@param modes string|string[]
local function assert_mode(modes)
  local mode = api.nvim_get_mode().mode
  local ok ---@type boolean
  if type(modes) == "string" then
    ok = modes == mode
  else
    ok = vim.tbl_contains(modes, mode)
  end
  assert(ok, "invalid mode")
end

---@return integer
---@return integer
local function get_line_range_from_selection()
  assert_mode("V")
  vim.cmd("normal! V")
  local _, first = unpack(fn.getcharpos("'<"))
  local _, last = unpack(fn.getcharpos("'>"))
  return first, last
end

---@param first integer
---@param last integer
local function select_line_range(first, last)
  assert_mode("n")
  api.nvim_win_set_cursor(0, { first, 0 })
  vim.cmd("normal! V")
  local last_col = fn.charcol({ last, "$" }) - 2
  api.nvim_win_set_cursor(0, { last, last_col })
end

---@param delimiter string? Cell delimiter
---@param layer cells.CellLayer Cell layer
function M.textobject(delimiter, layer)
  local cell = require("code-cells.api.cell").find_closest(delimiter)
  if not cell then return end
  cell:select(layer)
end

return M
