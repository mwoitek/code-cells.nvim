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

---@param layer cells.CellLayer Cell layer
---@param count integer? Count
function M.textobject(layer, count)
  local selected_count = vim.b._cells_selected_count or 0 ---@type integer
  local last_layer = vim.b._cells_selected_layer ---@type cells.CellLayer?

  local is_outer = layer == "outer"
  local is_outer_again = is_outer and last_layer == "outer"

  count = is_outer and (count or vim.v.count1) or 1
  local use_selection = selected_count > 1 or (selected_count == 1 and is_outer_again)

  local first_line ---@type integer?
  local last_line ---@type integer?
  if use_selection then
    first_line, last_line = get_line_range_from_selection()
  end

  local i = 0
  while i < count do
    local ref = (is_outer and last_line) and last_line + 1 or fn.line(".")

    local cell = require("code-cells.api.cell").find_closest(nil, ref)
    if not cell then break end

    local cell_first, cell_last = cell:range(layer)
    if not cell_first then break end

    first_line = first_line or cell_first
    last_line = cell_last

    i = i + 1
  end

  if i == 0 then return end

  ---@cast first_line -?
  ---@cast last_line -?
  select_line_range(first_line, last_line)

  if use_selection then
    if is_outer then selected_count = selected_count + (is_outer_again and i or i - 1) end
  else
    selected_count = i
  end

  api.nvim_buf_set_var(0, "_cells_selected_count", selected_count)
  api.nvim_buf_set_var(0, "_cells_selected_layer", layer)

  api.nvim_create_autocmd("ModeChanged", {
    buffer = 0,
    callback = function(ev)
      if string.sub(ev.match, 1, 1) ~= "V" then return end
      api.nvim_buf_del_var(ev.buf, "_cells_selected_count")
      api.nvim_buf_del_var(ev.buf, "_cells_selected_layer")
      return true
    end,
  })
end

return M
