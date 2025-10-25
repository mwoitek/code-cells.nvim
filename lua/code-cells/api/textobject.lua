local M = {}

---@param delimiter string? Cell delimiter
---@param layer cells.CellLayer Cell layer
function M.textobject(delimiter, layer)
  local cell = require("code-cells.api.cell").find_closest(delimiter)
  if not cell then return end
  cell:select(layer)
end

return M
