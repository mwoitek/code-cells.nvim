local M = {}

local assert = require("luassert")

local api = vim.api

---@param file_name string
function M.edit_file(file_name)
  local file_path = vim.fs.joinpath("spec", "fixtures", file_name)
  vim.cmd.edit(file_path)
end

function M.unload_buffer()
  local file_path = api.nvim_buf_get_name(0)
  if file_path == "" then return end
  vim.cmd("bd!")
end

-- NOTE: The test code will be executed with nlua. This tool does NOT load
-- filetype plugins. But, for some tests, I want them to be loaded. The
-- following function uses the path to the open file to find the right ftplugin
-- file, and then sources it. Since I'm relying on `vim.filetype.match`, this
-- function does NOT work for all filetypes (e.g., it fails for R files).
-- However, for a test helper, its code is good enough.
function M.source_ftplugin()
  local file_path = api.nvim_buf_get_name(0)

  local file_type = vim.filetype.match({ filename = file_path })
  if not file_type then
    local msg = string.format("Failed to get filetype for %s", file_path)
    error(msg)
  end

  local pattern = string.format("ftplugin/%s.vim", file_type)
  local plugin_files = api.nvim_get_runtime_file(pattern, true)

  ---@diagnostic disable-next-line: deprecated
  local plugin_file = table.foreach(
    plugin_files,
    ---@param f string
    function(_, f)
      local start = string.find(f, "runtime")
      if type(start) == "number" then return f end
    end
  )
  if not plugin_file then
    local msg = string.format("Failed to find ftplugin file for %s", file_type)
    error(msg)
  end

  vim.cmd.source(plugin_file)
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
