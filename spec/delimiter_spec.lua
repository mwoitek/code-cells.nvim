---@diagnostic disable: param-type-mismatch, undefined-field

local helpers = require "spec.helpers"

describe("code-cells.delimiter", function()
  local delimiter

  setup(function() delimiter = require "code-cells.delimiter" end)

  teardown(function() delimiter = nil end)

  describe(".get_pattern()", function()
    it("throws an error when the argument type is wrong", function()
      local invalid_input = {
        boolean = false,
        number = 15,
        table = { wrong = true },
      }
      for _, delim in pairs(invalid_input) do
        -- TODO: Extract this logic into a new function
        local ok, err_msg = pcall(delimiter.get_pattern, delim)
        assert.is_false(ok)
        local msg_ok = helpers.str_contains(err_msg, ": expected string, got ")
        assert.is_true(msg_ok)
      end
    end)
  end)

  describe(".find_nth()", function()
    it("throws errors when argument types are wrong", function()
      -- TODO: Add tests after refactoring
    end)
  end)
end)
