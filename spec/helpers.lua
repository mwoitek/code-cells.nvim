local M = {}

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
function M.str_contains(s, pattern)
  local start = string.find(s, pattern)
  return type(start) == "number"
end

return M
