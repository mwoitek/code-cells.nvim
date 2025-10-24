local M = {}

local assert = require("luassert")

local api = vim.api

---@param file_name string
function M.load_fixture(file_name)
  local file_path = vim.fs.joinpath("spec", "fixtures", file_name)
  vim.cmd.edit(file_path)
end

function M.unload_buffer()
  local file_path = api.nvim_buf_get_name(0)
  if file_path ~= "" then vim.cmd("bd!") end
end

---@param s string
---@param pattern string
---@return boolean
function M.string_contains(s, pattern)
  local start = string.find(s, pattern)
  return start ~= nil
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

---@return { first: integer[], last: integer[] }?
function M.get_selection_range()
  local mode = api.nvim_get_mode().mode
  if mode:lower() ~= "v" then return end
  vim.cmd("normal! " .. mode)

  local _, first_line, first_col = unpack(vim.fn.getcharpos("'<"))
  local _, last_line, last_col = unpack(vim.fn.getcharpos("'>"))

  return {
    first = { first_line, first_col },
    last = { last_line, last_col },
  }
end

return M
