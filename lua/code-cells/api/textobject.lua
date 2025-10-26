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
local function textobject_outer(delimiter)
  local first_line ---@type integer?
  local ref_line ---@type integer?

  if vim.b._cells_obj_active then
    first_line, ref_line = get_line_range_from_selection()
    ref_line = ref_line + 1
  end

  local cell = require("code-cells.api.cell").find_closest(delimiter, ref_line)
  if not cell then return end

  select_line_range(first_line or cell.first_line, cell.last_line)

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
