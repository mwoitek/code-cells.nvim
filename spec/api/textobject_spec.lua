local assert = require "luassert"
local helpers = require "spec.helpers"

local api = vim.api

describe("code-cells.api.textobject", function()
  local to = require "code-cells.api.textobject"

  before_each(function()
    helpers.edit_file "11.sql"
    helpers.source_ftplugin()
  end)

  after_each(helpers.unload_buffer)

  describe(".textobject()", function()
    it("throws an error when `inner` is invalid", function()
      local invalid_input = {
        ["function"] = function(x) return x * 2 end,
        number = -3,
        string = "not valid",
        table = { fail = true },
      }
      for _, inner in pairs(invalid_input) do
        helpers.check_valid_msg("boolean", to.textobject, nil, inner)
      end
    end)

    it("throws an error when `opts` is invalid", function()
      local opts_1 = "INVALID"
      helpers.check_valid_msg("table", to.textobject, nil, true, opts_1)

      local opts_2 = { lookahead = 10 }
      helpers.check_valid_msg("boolean", to.textobject, nil, false, opts_2)

      local opts_3 = { skip_blanks = {} }
      helpers.check_valid_msg("boolean", to.textobject, nil, nil, opts_3)
    end)

    it("does nothing when not in visual mode", function()
      local init_pos = { 30, 2 }
      api.nvim_win_set_cursor(0, init_pos)

      to.textobject()

      local mode = api.nvim_get_mode().mode
      assert.are.Not.equal(mode, "V")
      assert.are_equal(mode, "n")

      local new_pos = api.nvim_win_get_cursor(0)
      assert.are.same(new_pos, init_pos)
    end)

    it("selects the outer range when inside of a cell", function()
      local init_pos = { 17, 21 }
      api.nvim_win_set_cursor(0, init_pos)

      vim.cmd "normal! v"
      to.textobject()

      local mode = api.nvim_get_mode().mode
      assert.are_equal(mode, "V")

      local selection = helpers.get_selection_range() ---@cast selection - ?
      assert.are.same(selection.first, { 14, 1 })
      assert.are.same(selection.last, { 25, 1 })
    end)

    it("selects the inner range when inside of a cell", function()
      local init_pos = { 32, 11 }
      api.nvim_win_set_cursor(0, init_pos)

      vim.cmd "normal! v"
      to.textobject(nil, true)

      local mode = api.nvim_get_mode().mode
      assert.are_equal(mode, "V")

      local selection = helpers.get_selection_range() ---@cast selection - ?
      assert.are.same(selection.first, { 27, 1 })
      assert.are.same(selection.last, { 33, 44 })
    end)

    it("selects the outer range when outside of a cell and lookahead is enabled", function()
      local init_pos = { 3, 0 }
      api.nvim_win_set_cursor(0, init_pos)

      vim.cmd "normal! v"
      to.textobject(nil, false, { lookahead = true })

      local mode = api.nvim_get_mode().mode
      assert.are_equal(mode, "V")

      local selection = helpers.get_selection_range() ---@cast selection - ?
      assert.are.same(selection.first, { 6, 1 })
      assert.are.same(selection.last, { 13, 1 })
    end)

    it("selects the inner range when outside of a cell and lookahead is enabled", function()
      local init_pos = { 2, 0 }
      api.nvim_win_set_cursor(0, init_pos)

      vim.cmd "normal! v"
      to.textobject(nil, true, { lookahead = true })

      local mode = api.nvim_get_mode().mode
      assert.are_equal(mode, "V")

      local selection = helpers.get_selection_range() ---@cast selection - ?
      assert.are.same(selection.first, { 7, 1 })
      assert.are.same(selection.last, { 12, 2 })
    end)

    it(
      "does not select the outer range when outside of a cell and lookahead is disabled",
      function()
        local init_pos = { 1, 0 }
        api.nvim_win_set_cursor(0, init_pos)

        vim.cmd "normal! v"
        to.textobject(nil, false, { lookahead = false })

        local mode = api.nvim_get_mode().mode
        assert.are.Not.equal(mode, "V")
        assert.are_equal(mode, "v")

        vim.cmd "normal! v"
        local new_pos = api.nvim_win_get_cursor(0)
        assert.are.same(new_pos, init_pos)
      end
    )

    it(
      "does not select the inner range when outside of a cell and lookahead is disabled",
      function()
        local init_pos = { 5, 0 }
        api.nvim_win_set_cursor(0, init_pos)

        vim.cmd "normal! v"
        to.textobject(nil, true, { lookahead = false })

        local mode = api.nvim_get_mode().mode
        assert.are.Not.equal(mode, "V")
        assert.are_equal(mode, "v")

        vim.cmd "normal! v"
        local new_pos = api.nvim_win_get_cursor(0)
        assert.are.same(new_pos, init_pos)
      end
    )

    it("can skip blank lines when selecting the inner range", function()
      local init_pos = { 15, 0 }
      api.nvim_win_set_cursor(0, init_pos)

      vim.cmd "normal! v"
      to.textobject(nil, true, { skip_blanks = true })

      local mode = api.nvim_get_mode().mode
      assert.are_equal(mode, "V")

      local selection = helpers.get_selection_range() ---@cast selection - ?
      assert.are.same(selection.first, { 17, 1 })
      assert.are.same(selection.last, { 22, 2 })
    end)

    it("selects the outer range when inside the very last cell", function()
      local init_pos = { 44, 8 }
      api.nvim_win_set_cursor(0, init_pos)

      vim.cmd "normal! v"
      to.textobject()

      local mode = api.nvim_get_mode().mode
      assert.are_equal(mode, "V")

      local selection = helpers.get_selection_range() ---@cast selection - ?
      assert.are.same(selection.first, { 42, 1 })
      assert.are.same(selection.last, { 44, 17 })
    end)

    it("selects the inner range when inside the very last cell", function()
      local init_pos = { 42, 3 }
      api.nvim_win_set_cursor(0, init_pos)

      vim.cmd "normal! v"
      to.textobject(nil, true)

      local mode = api.nvim_get_mode().mode
      assert.are_equal(mode, "V")

      local selection = helpers.get_selection_range() ---@cast selection - ?
      assert.are.same(selection.first, { 43, 1 })
      assert.are.same(selection.last, { 44, 17 })
    end)
  end)
end)
