local assert = require "luassert"
local helpers = require "spec.helpers"

describe("code-cells.api.cell", function()
  local cell = require "code-cells.api.cell"

  describe(".Cell", function()
    local Cell = cell.Cell

    describe(":trim_top()", function()
      it("works when the cell has nothing at the top that can be trimmed", function()
        helpers.edit_file "10.py"
        helpers.source_ftplugin()
        local first_line = 1
        local last_line = 4
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(first_line + 1, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell has something at the top that can be trimmed", function()
        helpers.edit_file "10.py"
        helpers.source_ftplugin()
        local first_line = 5
        local last_line = 13
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(8, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when only the last line is non-empty", function()
        helpers.edit_file "10.py"
        helpers.source_ftplugin()
        local first_line = 14
        local last_line = 18
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(last_line, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell has only blank lines", function()
        helpers.edit_file "10.py"
        helpers.source_ftplugin()
        local first_line = 19
        local last_line = 24
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(first_line + 1, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell is completely empty", function()
        helpers.edit_file "10.py"
        helpers.source_ftplugin()
        local first_line = 25
        local last_line = 25
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        assert.is_true(trimmed_cell == orig_cell)
      end)
    end)
  end)
end)
