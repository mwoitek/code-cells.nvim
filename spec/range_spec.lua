---@diagnostic disable: undefined-field

---@param file_name string
local function edit_file(file_name)
  local file_path = vim.fs.joinpath("spec", "fixtures", file_name)
  vim.cmd.edit(file_path)
end

local function unload_buffer()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then return end
  vim.cmd "bd!"
end

describe("code-cells.range", function()
  local range = require "code-cells.range"

  after_each(unload_buffer)

  describe(".is_valid()", function()
    local is_valid

    setup(function() is_valid = range.is_valid end)

    teardown(function() is_valid = nil end)

    it("returns true for a valid line range", function()
      edit_file "01.py"
      local first_line = 10
      local last_line = 20
      assert.is_true(is_valid(first_line, last_line))
    end)

    it("throws errors when argument types are wrong", function()
      local first_1 = "1"
      local last_1 = 2
      assert.has_error(function() is_valid(first_1, last_1) end)

      local first_2 = 10
      local last_2 = 20.5
      assert.has_error(function() is_valid(first_2, last_2) end)
    end)

    it("returns false if the first line is greater than the last", function()
      local first_line = 3
      local last_line = 1
      assert.is_false(is_valid(first_line, last_line))
    end)

    it("returns false if the first line is less than 1", function()
      local first_line = 0
      local last_line = 2
      assert.is_false(is_valid(first_line, last_line))
    end)

    it("returns false if the last line is greater than the line count", function()
      edit_file "02.R"
      local first_line = 1
      local last_line = 9999
      assert.is_false(is_valid(first_line, last_line))
    end)
  end)
end)
