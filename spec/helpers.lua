local M = {}

local assert = require "luassert"

---@param file_name string
function M.edit_file(file_name)
  local file_path = vim.fs.joinpath("spec", "fixtures", file_name)
  vim.cmd.edit(file_path)
end

function M.unload_buffer()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then return end
  vim.cmd "bd!"
end

---@param s string
---@param pattern string
---@return boolean
function M.string_contains(s, pattern)
  local start = string.find(s, pattern)
  return type(start) == "number"
end

---@param type_ string
---@param func function
---@param ... any
function M.check_valid_msg(type_, func, ...)
  local ok, err_msg = pcall(func, ...)
  assert.is_false(ok)

  local exp_msg = string.format(": expected %s, got ", type_)
  local msg_ok = M.string_contains(err_msg, vim.pesc(exp_msg))
  assert.is_true(msg_ok)
end

return M
