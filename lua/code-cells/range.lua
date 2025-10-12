local M = {}

local valid = require "code-cells.validation"

-- Validate line range {{{
---@param first_line integer Range's first line
---@param last_line integer Range's last line
---@return boolean # true for valid range, and false otherwise
function M.is_valid(first_line, last_line)
  vim.validate("first_line", first_line, valid.integer, "integer")
  vim.validate("last_line", last_line, valid.integer, "integer")
  return first_line <= last_line and first_line >= 1 and last_line <= vim.api.nvim_buf_line_count(0)
end
-- }}}

return M

-- vim: foldmethod=marker:
