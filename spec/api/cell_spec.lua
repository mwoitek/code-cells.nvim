local assert = require "luassert"
local helpers = require "spec.helpers"

describe("code-cells.api.cell", function()
  local cell = require "code-cells.api.cell"

  describe(".Cell", function()
    local Cell = cell.Cell

    before_each(function()
      helpers.edit_file "10.py"
      helpers.source_ftplugin()
    end)

    after_each(helpers.unload_buffer)

    describe(":trim_top()", function()
      it("works when the cell has nothing at the top that can be trimmed", function()
        local first_line = 1
        local last_line = 4
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(first_line + 1, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell has something at the top that can be trimmed", function()
        local first_line = 5
        local last_line = 13
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(8, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when only the last line is non-empty", function()
        local first_line = 14
        local last_line = 18
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(last_line, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell has only blank lines", function()
        local first_line = 19
        local last_line = 24
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        local exp_cell = Cell.new(first_line + 1, last_line)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell is completely empty", function()
        local first_line = 25
        local last_line = 25
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_top()
        assert.is_true(trimmed_cell == orig_cell)
      end)
    end)

    describe(":trim_bottom()", function()
      it("works when the cell has nothing at the bottom that can be trimmed", function()
        local first_line = 14
        local last_line = 18
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_bottom()
        assert.is_true(trimmed_cell == orig_cell)
      end)

      it("works when the cell has something at the bottom that can be trimmed", function()
        local first_line = 5
        local last_line = 13
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_bottom()
        local exp_cell = Cell.new(first_line, 10)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell has only blank lines", function()
        local first_line = 19
        local last_line = 24
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_bottom()
        local exp_cell = Cell.new(first_line, first_line + 1)
        assert.is_true(trimmed_cell == exp_cell)
      end)

      it("works when the cell is completely empty", function()
        local first_line = 25
        local last_line = 25
        local orig_cell = Cell.new(first_line, last_line)
        local trimmed_cell = orig_cell:trim_bottom()
        assert.is_true(trimmed_cell == orig_cell)
      end)
    end)

    describe(":inner()", function()
      it([[finds the inner part of a "normal" cell]], function()
        local first_line = 1
        local last_line = 4
        local c = Cell.new(first_line, last_line)
        local inner = c:inner()
        local exp_inner = Cell.new(2, 3)
        assert.is_true(inner == exp_inner)
      end)

      it("finds the inner part of a cell with blanks at the top and bottom", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local inner = c:inner()
        local exp_inner = Cell.new(8, 10)
        assert.is_true(inner == exp_inner)
      end)

      it("finds the inner part of a cell with a single non-empty line at the end", function()
        local first_line = 14
        local last_line = 18
        local c = Cell.new(first_line, last_line)
        local inner = c:inner()
        local exp_inner = Cell.new(last_line, last_line)
        assert.is_true(inner == exp_inner)
      end)

      it("finds the inner part of a cell with only blank lines", function()
        local first_line = 19
        local last_line = 24
        local c = Cell.new(first_line, last_line)
        local inner = c:inner()
        local exp_inner = Cell.new(first_line + 1, first_line + 1)
        assert.is_true(inner == exp_inner)
      end)

      it("handles the case of a cell that is completely empty", function()
        local first_line = 25
        local last_line = 25
        local c = Cell.new(first_line, last_line)
        local inner = c:inner()
        assert.is_true(inner == c)
      end)

      it("finds the inner part of a cell while respecting `skip_lead_blanks=false`", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local inner = c:inner(false)
        local exp_inner = Cell.new(first_line + 1, 10)
        assert.is_true(inner == exp_inner)
      end)
    end)
  end)
end)
