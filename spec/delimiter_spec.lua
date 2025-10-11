---@diagnostic disable: param-type-mismatch, undefined-field

describe("code-cells.delimiter", function()
  local delimiter = require "code-cells.delimiter"

  describe(".get_pattern()", function()
    it("throws an error when the argument type is wrong", function()
      local delim = { wrong = true }
      assert.has_error(function() delimiter.get_pattern(delim) end)
    end)
  end)

  describe(".find_nth()", function()
    it("throws errors when argument types are wrong", function()
      -- TODO: Add tests after refactoring
    end)
  end)
end)
