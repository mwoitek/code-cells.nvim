local M = {}

---@class cells.TextobjectOpts
---@field lookahead boolean? If not inside a cell, look for the next one?
---@field skip_blanks boolean? For the inner textobject, skip leading/trailing blank lines?
local TextobjectOpts = {
  -- TODO: make these default values customizable
  lookahead = true,
  skip_blanks = false,
}
TextobjectOpts.__index = TextobjectOpts

---@param opts any
function TextobjectOpts.validate(opts)
  vim.validate("opts", opts, "table", true)
  if not opts then return end
  vim.validate("lookahead", opts.lookahead, "boolean", true)
  vim.validate("skip_blanks", opts.skip_blanks, "boolean", true)
end

---@param opts any
---@return cells.TextobjectOpts
function TextobjectOpts.new(opts)
  TextobjectOpts.validate(opts)
  return setmetatable(opts or {}, TextobjectOpts)
end

---@param delimiter string? Cell delimiter
---@param inner boolean? Inner textobject?
---@param opts cells.TextobjectOpts? Extra options
function M.textobject(delimiter, inner, opts)
  vim.validate("inner", inner, "boolean", true)
  opts = TextobjectOpts.new(opts)

  local cell ---@type cells.Cell?
  if opts.lookahead then
    cell = require("code-cells.api.cell").find_closest(delimiter)
  else
    cell = require("code-cells.api.cell").find_surrounding(delimiter)
  end
  if not cell then return end

  local layer ---@type cells.cell.Layer
  if not inner then
    layer = "outer"
  elseif opts.skip_blanks then
    layer = "core"
  else
    layer = "inner"
  end

  cell:select(layer)
end

return M
