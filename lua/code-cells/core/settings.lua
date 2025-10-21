local M = {}

-- NOTE: I'm still not sure about how configuration variables will be stored.
-- So this code is considered just a draft.

local PREFIX = "cells"

---@param name string Variable name without prefix
---@param ... any Arguments to be passed to `vim.validate`
---@return any # Value of the variable specified by `name`, or nil if not set
function M.get_variable(name, ...)
  name = string.format("%s_%s", PREFIX, name)

  local buffer_val = vim.b[name]
  if buffer_val ~= nil then
    vim.validate("vim.b." .. name, buffer_val, ...)
    return buffer_val
  end

  local global_val = vim.g[name]
  if global_val ~= nil then
    vim.validate("vim.g." .. name, global_val, ...)
    return global_val
  end
end

return M
