-- local assert = require "luassert"
local helpers = require "spec.helpers"

describe("code-cells.api.delimiter", function()
  local delimiter

  setup(function() delimiter = require "code-cells.api.delimiter" end)

  teardown(function() delimiter = nil end)

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

  describe(".find_nth()", function()
    it("TODO", function()
      -- TODO
    end)
  end)
end)
