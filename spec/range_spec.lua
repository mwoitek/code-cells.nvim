describe("code-cells.range", function()
  local range = require "code-cells.range"

  describe(".is_valid()", function()
    local is_valid = range.is_valid

    it("returns false if the first line is greater than the last", function()
      local first_line = 3
      local last_line = 1
      assert.is_false(is_valid(first_line, last_line))
    end)

    it("returns false if the last line is greater than the line count", function()
      local file_path = "spec/fixtures/01.py"
      vim.cmd.edit { args = { file_path }, bang = true }

      local first_line = 1
      local last_line = 9999
      assert.is_false(is_valid(first_line, last_line))
    end)
  end)
end)
