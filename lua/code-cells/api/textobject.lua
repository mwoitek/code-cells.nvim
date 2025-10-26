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

---@return integer # Range's first line
---@return integer # Range's last line
local function get_line_range_from_selection()
  assert_mode("V")
  vim.cmd("normal! V")
  local _, first = unpack(fn.getcharpos("'<"))
  local _, last = unpack(fn.getcharpos("'>"))
  vim.cmd("normal! gv")
  return first, last
end

---@param first integer Range's first line
---@param last integer Range's last line
local function select_line_range(first, last)
  vim.cmd.execute([["normal! \<Esc>"]])
  assert_mode("n")
  local last_col = fn.charcol({ last, "$" }) - 1
  api.nvim_win_set_cursor(0, { first, 0 })
  vim.cmd("normal! V")
  api.nvim_win_set_cursor(0, { last, last_col })
end

---@param delimiter string? Cell delimiter
---@param count integer? Count
local function textobject_outer(delimiter, count)
  count = count or vim.v.count1

  local first ---@type integer?
  local last ---@type integer?

  if vim.b._cells_obj_active then
    first, last = get_line_range_from_selection()
  end

  local i = 0

  while i < count do
    local ref = last and last + 1 or fn.line(".")
    local cell = require("code-cells.api.cell").find_closest(delimiter, ref)
    if not cell then break end
    first = first or cell.first_line
    last = cell.last_line
    i = i + 1
  end

  if i == 0 then return end

  ---@cast first -?
  ---@cast last -?
  select_line_range(first, last)

  api.nvim_buf_set_var(0, "_cells_obj_active", true)
  api.nvim_create_autocmd("ModeChanged", {
    buffer = 0,
    callback = function(ev)
      if string.sub(ev.match, 1, 1) ~= "V" then return end
      api.nvim_buf_del_var(ev.buf, "_cells_obj_active")
      return true
    end,
  })
end

---@param delimiter string? Cell delimiter
---@param layer cells.CellLayer Cell layer
local function textobject_inner(delimiter, layer)
  -- TODO: improve
  local cell = require("code-cells.api.cell").find_closest(delimiter)
  if not cell then return end
  cell:select(layer)
end

---@param delimiter string? Cell delimiter
---@param layer cells.CellLayer Cell layer
function M.textobject(delimiter, layer)
  if layer == "inner" or layer == "core" then
    textobject_inner(delimiter, layer)
  else
    textobject_outer(delimiter)
  end
end

return M
