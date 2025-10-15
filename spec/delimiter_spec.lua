local assert = require "luassert"
local helpers = require "spec.helpers"

describe("code-cells.api.delimiter", function()
  local delimiter = require "code-cells.api.delimiter"

  after_each(helpers.unload_buffer)

  describe(".get_pattern()", function()
    it("throws an error when the type of `delimiter` is wrong", function()
      local invalid_input = {
        boolean = false,
        ["function"] = function(x) return x * x end,
        number = 15,
        table = { wrong = true },
      }
      for _, delim in pairs(invalid_input) do
        helpers.check_valid_msg("string", delimiter.get_pattern, delim)
      end
    end)
  end)

  describe(".find()", function()
    local find = delimiter.find

    it("finds every match in a valid range", function()
      helpers.edit_file "01.py"
      helpers.source_ftplugin()
      local first_line = 3
      local last_line = 20
      local matches = find(nil, first_line, last_line)
      local exp_matches = { 5, 10, 15 }
      assert.are.same(matches, exp_matches)
    end)

    it("finds matches in a valid range while respecting `max_matches`", function()
      helpers.edit_file "08.rb"
      helpers.source_ftplugin()
      local first_line = 2
      local last_line = 10
      local max_matches = 1
      local matches = find(nil, first_line, last_line, max_matches)
      local exp_matches = { 4 }
      assert.are.same(matches, exp_matches)
    end)

    it("returns nil if no match is found in a valid range", function()
      helpers.edit_file "07.hs"
      helpers.source_ftplugin()
      local first_line = 5
      local last_line = 8
      local matches = find(nil, first_line, last_line)
      assert.is_nil(matches)
    end)

    it("handles a valid range given in the reverse order", function()
      helpers.edit_file "03.jl"
      helpers.source_ftplugin()
      local first_line = 16
      local last_line = 1
      local matches = find(nil, first_line, last_line)
      local exp_matches = { 15, 4, 1 }
      assert.are.same(matches, exp_matches)
    end)
  end)

  describe(".find_nth()", function()
    it("TODO", function()
      -- TODO
    end)
  end)
end)
