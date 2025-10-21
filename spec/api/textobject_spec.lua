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
  end)
end)
