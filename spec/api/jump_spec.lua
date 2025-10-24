local assert = require("luassert")
local utils = require("spec.utils")

describe("code-cells.api.jump", function()
  local jump = require("code-cells.api.jump")

  setup(function() vim.cmd("filetype on | filetype plugin on") end)

  after_each(utils.unload_buffer)

  describe(".to_next()", function()
    it("throws an error when the type of `count` is wrong", function()
      local delimiter = "-- %%"
      local invalid_input = {
        boolean = true,
        float = -1.3,
        ["function"] = function(x) return x + 1 end,
        string = "wrong",
        table = { no = true },
      }
      for _, count in pairs(invalid_input) do
        utils.check_valid_msg("non-zero integer", jump.to_next, delimiter, count)
      end
    end)

    it("moves the cursor as expected when default arguments are used", function()
      utils.load_fixture("01.py")
      local init_pos = { 11, 28 }
      vim.api.nvim_win_set_cursor(0, init_pos)
      jump.to_next()
      local new_pos = vim.api.nvim_win_get_cursor(0)
      local exp_pos = { 15, 0 }
      assert.are.same(new_pos, exp_pos)
    end)

    it("moves the cursor as expected when the delimiter is explicitly given", function()
      utils.load_fixture("02.R")
      local init_pos = { 12, 6 }
      vim.api.nvim_win_set_cursor(0, init_pos)
      local delimiter = "# %%"
      local count = 1
      jump.to_next(delimiter, count)
      local new_pos = vim.api.nvim_win_get_cursor(0)
      local exp_pos = { 23, 0 }
      assert.are.same(new_pos, exp_pos)
    end)

    it("moves the cursor as expected when the count is greater than 1", function()
      utils.load_fixture("03.jl")
      local init_pos = { 2, 17 }
      vim.api.nvim_win_set_cursor(0, init_pos)
      local count = 2
      jump.to_next(nil, count)
      local new_pos = vim.api.nvim_win_get_cursor(0)
      local exp_pos = { 15, 0 }
      assert.are.same(new_pos, exp_pos)
    end)

    it(
      "moves the cursor as expected when the count is greater than the number of cells that follow",
      function()
        utils.load_fixture("05.js")
        local init_pos = { 3, 0 }
        vim.api.nvim_win_set_cursor(0, init_pos)
        local count = 10
        jump.to_next(nil, count)
        local new_pos = vim.api.nvim_win_get_cursor(0)
        local exp_pos = { 19, 0 }
        assert.are.same(new_pos, exp_pos)
      end
    )

    it("moves the cursor as expected when the count is negative", function()
      utils.load_fixture("06.clj")
      local init_pos = { 6, 25 }
      vim.api.nvim_win_set_cursor(0, init_pos)
      local count = -1
      jump.to_next(nil, count)
      local new_pos = vim.api.nvim_win_get_cursor(0)
      local exp_pos = { 4, 0 }
      assert.are.same(new_pos, exp_pos)
    end)

    it("does nothing when there is no next cell", function()
      utils.load_fixture("04.sql")
      local init_pos = { 10, 11 }
      vim.api.nvim_win_set_cursor(0, init_pos)
      local count = 1
      jump.to_next(nil, count)
      local new_pos = vim.api.nvim_win_get_cursor(0)
      assert.are.same(new_pos, init_pos)
    end)

    it("does nothing when the cursor is initally at the bottom of the buffer", function()
      utils.load_fixture("04.sql")
      local init_pos = { vim.fn.line("$"), 0 }
      vim.api.nvim_win_set_cursor(0, init_pos)
      local count = 1
      jump.to_next(nil, count)
      local new_pos = vim.api.nvim_win_get_cursor(0)
      assert.are.same(new_pos, init_pos)
    end)
  end)
end)
