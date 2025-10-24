local assert = require("luassert")
local utils = require("spec.utils")

local api = vim.api

describe("code-cells.api.delimiter", function()
  local delimiter = require("code-cells.api.delimiter")

  setup(function() vim.cmd("filetype on | filetype plugin on") end)

  after_each(utils.unload_buffer)

  describe(".get_pattern()", function()
    it("throws an error when the type of `delimiter` is wrong", function()
      local invalid_input = {
        boolean = false,
        ["function"] = function(x) return x * x end,
        number = 15,
        table = { wrong = true },
      }
      for _, delim in pairs(invalid_input) do
        utils.check_valid_msg("string", delimiter.get_pattern, delim)
      end
    end)
  end)

  describe(".find()", function()
    it("finds every match in a valid range", function()
      utils.load_fixture("01.py")
      local first_line = 3
      local last_line = 20
      local matches = delimiter.find(nil, first_line, last_line)
      local exp_matches = { 5, 10, 15 }
      assert.are.same(matches, exp_matches)
    end)

    it("finds matches in a valid range while respecting `max_matches`", function()
      utils.load_fixture("08.rb")
      local first_line = 2
      local last_line = 10
      local max_matches = 1
      local matches = delimiter.find(nil, first_line, last_line, max_matches)
      local exp_matches = { 4 }
      assert.are.same(matches, exp_matches)
    end)

    it("returns nil if no match is found in a valid range", function()
      utils.load_fixture("07.hs")
      local first_line = 5
      local last_line = 8
      local matches = delimiter.find(nil, first_line, last_line)
      assert.is_nil(matches)
    end)

    it("handles a valid range given in the reverse order", function()
      utils.load_fixture("03.jl")
      local first_line = 16
      local last_line = 1
      local matches = delimiter.find(nil, first_line, last_line)
      local exp_matches = { 15, 4, 1 }
      assert.are.same(matches, exp_matches)
    end)
  end)

  describe(".find_above()", function()
    it("finds every match above the current line", function()
      utils.load_fixture("05.js")
      local init_pos = { 15, 4 }
      api.nvim_win_set_cursor(0, init_pos)
      local matches = delimiter.find_above()
      local exp_matches = { 4, 1 }
      assert.are.same(matches, exp_matches)
    end)

    it("finds every match above the current line when the delimiter is explicitly given", function()
      utils.load_fixture("02.R")
      local init_pos = { 24, 4 }
      api.nvim_win_set_cursor(0, init_pos)
      local delim = "# %%"
      local matches = delimiter.find_above(delim)
      local exp_matches = { 23, 4, 1 }
      assert.are.same(matches, exp_matches)
    end)

    it("finds every match above a specified line (exclusive)", function()
      utils.load_fixture("09.lua")
      local matches = delimiter.find_above(nil, {
        line = 13,
        include_line = false,
      })
      local exp_matches = { 4, 1 }
      assert.are.same(matches, exp_matches)
    end)

    it("finds every match above a specified line (inclusive)", function()
      utils.load_fixture("09.lua")
      local matches = delimiter.find_above(nil, {
        line = 13,
        include_line = true,
      })
      local exp_matches = { 13, 4, 1 }
      assert.are.same(matches, exp_matches)
    end)

    it("finds every match above a specified line while respecting `max_matches`", function()
      utils.load_fixture("09.lua")
      local matches = delimiter.find_above(nil, {
        line = 25,
        max_matches = 3,
      })
      local exp_matches = { 21, 18, 13 }
      assert.are.same(matches, exp_matches)
    end)

    it("returns nil when no match is found above", function()
      utils.load_fixture("06.clj")
      local init_pos = { 1, 14 }
      api.nvim_win_set_cursor(0, init_pos)
      local matches = delimiter.find_above()
      assert.is_nil(matches)
    end)
  end)

  describe(".find_all()", function()
    it("finds all matches when the default argument is used", function()
      utils.load_fixture("09.lua")
      local matches = delimiter.find_all()
      local exp_matches = { 1, 4, 13, 18, 21, 38, 46, 49, 62 }
      assert.are.same(matches, exp_matches)
    end)

    it("finds all matches when the delimiter is explicitly given", function()
      utils.load_fixture("02.R")
      local delim = "# %%"
      local matches = delimiter.find_all(delim)
      local exp_matches = { 1, 4, 23 }
      assert.are.same(matches, exp_matches)
    end)
  end)

  describe(".find_nth()", function()
    it("finds next delimiter starting from the current line (exclusive)", function()
      utils.load_fixture("04.sql")
      local init_pos = { 1, 4 }
      api.nvim_win_set_cursor(0, init_pos)
      local n = 1
      local match = delimiter.find_nth(nil, n)
      local exp_match = 8
      assert.are_equal(match, exp_match)
    end)

    it("finds next delimiter starting from the current line (inclusive)", function()
      utils.load_fixture("04.sql")
      local init_pos = { 1, 4 }
      api.nvim_win_set_cursor(0, init_pos)
      local n = 1
      local match = delimiter.find_nth(nil, n, { include_line = true })
      local exp_match = 1
      assert.are_equal(match, exp_match)
    end)

    it("finds previous delimiter starting from the current line (exclusive)", function()
      utils.load_fixture("01.py")
      local init_pos = { 10, 3 }
      api.nvim_win_set_cursor(0, init_pos)
      local n = -1
      local match = delimiter.find_nth(nil, n)
      local exp_match = 5
      assert.are_equal(match, exp_match)
    end)

    it("finds previous delimiter starting from the current line (inclusive)", function()
      utils.load_fixture("01.py")
      local init_pos = { 10, 3 }
      api.nvim_win_set_cursor(0, init_pos)
      local n = -1
      local match = delimiter.find_nth(nil, n, { include_line = true })
      local exp_match = 10
      assert.are_equal(match, exp_match)
    end)
  end)
end)
