local assert = require("luassert")
local helpers = require("spec.helpers")

local api = vim.api

describe("code-cells.api.cell", function()
  local cell = require("code-cells.api.cell")

  after_each(helpers.unload_buffer)

  describe(".Cell", function()
    local Cell = cell.Cell

    before_each(function()
      helpers.edit_file("10.py")
      helpers.source_ftplugin()
    end)

    describe(":inner()", function()
      it([[finds the inner layer of a "normal" cell]], function()
        local first_line = 1
        local last_line = 4
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 2)
        assert.are_equal(inner_last, 3)
      end)

      it("finds the inner layer of a cell with leading/trailing blanks", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 6)
        assert.are_equal(inner_last, 12)
      end)

      it("finds the inner layer of a cell with a single non-empty line at the end", function()
        local first_line = 14
        local last_line = 18
        local c = Cell.new(first_line, last_line)
        local inner_first, inner_last = c:inner()
        assert.are_equal(inner_first, 15)
        assert.are_equal(inner_last, 18)
      end)

      it("finds the inner layer of a cell with blank lines only", function()
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
      it("finds the correct line when the cell has no leading blank", function()
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

    describe(":core()", function()
      it([[finds the core layer of a "normal" cell]], function()
        local first_line = 1
        local last_line = 4
        local c = Cell.new(first_line, last_line)
        local core_first, core_last = c:core()
        assert.are_equal(core_first, 2)
        assert.are_equal(core_last, 3)
      end)

      it("finds the core layer of a cell with leading/trailing blanks", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local core_first, core_last = c:core()
        assert.are_equal(core_first, 8)
        assert.are_equal(core_last, 10)
      end)

      it("finds the core layer of a cell with a single non-empty line at the end", function()
        local first_line = 14
        local last_line = 18
        local c = Cell.new(first_line, last_line)
        local core_first, core_last = c:core()
        assert.are_equal(core_first, 18)
        assert.are_equal(core_last, 18)
      end)

      it("finds the core layer of a cell with blank lines only", function()
        local first_line = 19
        local last_line = 24
        local c = Cell.new(first_line, last_line)
        local core_first, core_last = c:core()
        assert.are_equal(core_first, 20)
        assert.are_equal(core_last, 23)
      end)

      it("handles the case of a completely empty cell", function()
        local first_line = 25
        local last_line = 25
        local c = Cell.new(first_line, last_line)
        local core_first, core_last = c:core()
        assert.are_equal(core_first, 25)
        assert.are_equal(core_last, 25)
      end)
    end)

    describe(":range()", function()
      it("gets the outer range correctly", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local range_first, range_last = c:range("outer")
        assert.are_equal(range_first, 5)
        assert.are_equal(range_last, 13)
      end)

      it("gets the inner range correctly", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local range_first, range_last = c:range("inner")
        assert.are_equal(range_first, 6)
        assert.are_equal(range_last, 12)
      end)

      it("gets the core range correctly", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)
        local range_first, range_last = c:range("core")
        assert.are_equal(range_first, 8)
        assert.are_equal(range_last, 10)
      end)
    end)

    describe(":jump()", function()
      it("jumps to the first line of the outer layer", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        local layer = "outer"
        local position = "first"
        c:jump(layer, position)

        local new_pos = api.nvim_win_get_cursor(0)
        local exp_pos = { 5, 0 }
        assert.are.same(new_pos, exp_pos)
      end)

      it("jumps to the first line of the inner layer", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        local layer = "inner"
        local position = "first"
        c:jump(layer, position)

        local new_pos = api.nvim_win_get_cursor(0)
        local exp_pos = { 6, 0 }
        assert.are.same(new_pos, exp_pos)
      end)

      it("jumps to the first line of the core layer", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        local layer = "core"
        local position = "first"
        c:jump(layer, position)

        local new_pos = api.nvim_win_get_cursor(0)
        local exp_pos = { 8, 0 }
        assert.are.same(new_pos, exp_pos)
      end)

      it("jumps to the last line of the outer layer", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        local layer = "outer"
        local position = "last"
        c:jump(layer, position)

        local new_pos = api.nvim_win_get_cursor(0)
        local exp_pos = { 13, 0 }
        assert.are.same(new_pos, exp_pos)
      end)

      it("jumps to the last line of the inner layer", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        local layer = "inner"
        local position = "last"
        c:jump(layer, position)

        local new_pos = api.nvim_win_get_cursor(0)
        local exp_pos = { 12, 0 }
        assert.are.same(new_pos, exp_pos)
      end)

      it("jumps to the last line of the core layer", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        local layer = "core"
        local position = "last"
        c:jump(layer, position)

        local new_pos = api.nvim_win_get_cursor(0)
        local exp_pos = { 10, 0 }
        assert.are.same(new_pos, exp_pos)
      end)
    end)

    describe(":select()", function()
      it("correctly selects the outer layer of a cell", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        vim.cmd("normal! v")
        local layer = "outer"
        c:select(layer)

        local mode = api.nvim_get_mode().mode
        assert.are_equal(mode, "V")

        local selection = helpers.get_selection_range() ---@cast selection - ?
        assert.are.same(selection.first, { 5, 1 })
        assert.are.same(selection.last, { 13, 1 })
      end)

      it("correctly selects the inner layer of a cell", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        vim.cmd("normal! v")
        local layer = "inner"
        c:select(layer)

        local mode = api.nvim_get_mode().mode
        assert.are_equal(mode, "V")

        local selection = helpers.get_selection_range() ---@cast selection - ?
        assert.are.same(selection.first, { 6, 1 })
        assert.are.same(selection.last, { 12, 1 })
      end)

      it("correctly selects the core layer of a cell", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        vim.cmd("normal! v")
        local layer = "core"
        c:select(layer)

        local mode = api.nvim_get_mode().mode
        assert.are_equal(mode, "V")

        local selection = helpers.get_selection_range() ---@cast selection - ?
        assert.are.same(selection.first, { 8, 1 })
        assert.are.same(selection.last, { 10, 30 })
      end)

      it("does nothing if not in visual mode", function()
        local first_line = 5
        local last_line = 13
        local c = Cell.new(first_line, last_line)

        local init_pos = api.nvim_win_get_cursor(0)
        c:select("outer")

        local mode = api.nvim_get_mode().mode
        assert.are.Not.equal(mode, "V")
        assert.are_equal(mode, "n")

        local new_pos = api.nvim_win_get_cursor(0)
        assert.are.same(new_pos, init_pos)
      end)
    end)
  end)

  describe(".find_surrounding()", function()
    before_each(function()
      helpers.edit_file("11.sql")
      helpers.source_ftplugin()
    end)

    it("finds the cell that surrounds the current line", function()
      local init_pos = { 20, 17 }
      api.nvim_win_set_cursor(0, init_pos)

      local c = cell.find_surrounding()
      assert.is.Not.Nil(c)

      ---@cast c - ?
      assert.are_equal(c.first_line, 14)
      assert.are_equal(c.last_line, 25)
    end)

    it("finds the cell that surrounds the specified line", function()
      local line = 11
      local c = cell.find_surrounding(nil, line)
      assert.is.Not.Nil(c)
      ---@cast c - ?
      assert.are_equal(c.first_line, 6)
      assert.are_equal(c.last_line, 13)
    end)

    it("finds the cell that surrounds the specified line when it contains a delimiter", function()
      local line = 26
      local c = cell.find_surrounding(nil, line)
      assert.is.Not.Nil(c)
      ---@cast c - ?
      assert.are_equal(c.first_line, 26)
      assert.are_equal(c.last_line, 33)
    end)

    it("returns nil if there is no surrounding cell", function()
      local init_pos = { 3, 0 }
      api.nvim_win_set_cursor(0, init_pos)
      local c = cell.find_surrounding()
      assert.is_nil(c)
    end)
  end)

  describe(".find_closest()", function()
    before_each(function()
      helpers.edit_file("11.sql")
      helpers.source_ftplugin()
    end)

    it("finds the cell when the cursor is inside", function()
      local init_pos = { 28, 12 }
      api.nvim_win_set_cursor(0, init_pos)
      local c = cell.find_closest()
      assert.is.Not.Nil(c)
      ---@cast c - ?
      assert.are_equal(c.first_line, 26)
      assert.are_equal(c.last_line, 33)
    end)

    it("finds the cell when the cursor is outside", function()
      local init_pos = { 5, 0 }
      api.nvim_win_set_cursor(0, init_pos)
      local c = cell.find_closest()
      assert.is.Not.Nil(c)
      ---@cast c - ?
      assert.are_equal(c.first_line, 6)
      assert.are_equal(c.last_line, 13)
    end)

    it("finds the cell when the reference line is outside", function()
      local line = 2
      local c = cell.find_closest(nil, line)
      assert.is.Not.Nil(c)
      ---@cast c - ?
      assert.are_equal(c.first_line, 6)
      assert.are_equal(c.last_line, 13)
    end)

    it("returns nil when there is no cell at all", function()
      local delimiter = "# %%" -- actual delimiter is -- %%
      local line = 17
      local c = cell.find_closest(delimiter, line)
      assert.is_nil(c)
    end)
  end)
end)
