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

    describe(":inner()", function()
      it([[finds the inner part of a "normal" cell]], function()
        local first_line = 1
        local last_line = 4
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 2)
        assert.are_equal(inner_last, 3)
      end)

      it("finds the inner part of a cell with leading/trailing blanks", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 6)
        assert.are_equal(inner_last, 12)
      end)

      it("finds the inner part of a cell when only the last line is non-empty", function()
        local first_line = 14
        local last_line = 18
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 15)
        assert.are_equal(inner_last, 18)
      end)

      it("finds the inner part when the cell has only blank lines", function()
        local first_line = 19
        local last_line = 24
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 20)
        assert.are_equal(inner_last, 23)
      end)

      it("handles the case of a completely empty cell", function()
        local first_line = 25
        local last_line = 25
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 25)
        assert.are_equal(inner_last, 25)
      end)
    end)

    describe(":first_non_blank()", function()
      it("finds the correct line when there is no leading blank", function()
        local first_line = 1
        local last_line = 4
        local c = Cell.new(first_line, last_line)
        local first_non_blank = c:first_non_blank()
        assert.are_equal(first_non_blank, 2)
      end)

      it("finds the correct line when the cell has leading blanks", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local first_non_blank = c:first_non_blank()
        assert.are_equal(first_non_blank, 8)
      end)

      it("returns nil when the cell has only blank lines", function()
        local first_line = 19
        local last_line = 24
        local c = Cell.new(first_line, last_line)
        local first_non_blank = c:first_non_blank()
        assert.is_nil(first_non_blank)
      end)

      it("returns nil when the cell is completely empty", function()
        local first_line = 25
        local last_line = 25
        local c = Cell.new(first_line, last_line)
        local first_non_blank = c:first_non_blank()
        assert.is_nil(first_non_blank)
      end)
    end)

    describe(":last_non_blank()", function()
      it("finds the correct line when the cell has no trailing blank", function()
        local first_line = 14
        local last_line = 18
        local c = Cell.new(first_line, last_line)
        local last_non_blank = c:last_non_blank()
        assert.are_equal(last_non_blank, 18)
      end)

      it("finds the correct line when the cell has trailing blanks", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local last_non_blank = c:last_non_blank()
        assert.are_equal(last_non_blank, 10)
      end)

      it("returns nil when the cell has only blank lines", function()
        local first_line = 19
        local last_line = 24
        local c = Cell.new(first_line, last_line)
        local last_non_blank = c:last_non_blank()
        assert.is_nil(last_non_blank)
      end)

      it("returns nil when the cell is completely empty", function()
        local first_line = 25
        local last_line = 25
        local c = Cell.new(first_line, last_line)
        local last_non_blank = c:last_non_blank()
        assert.is_nil(last_non_blank)
      end)
    end)
  end)
end)
