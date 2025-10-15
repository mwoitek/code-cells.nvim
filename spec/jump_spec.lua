-- local assert = require "luassert"
local helpers = require "spec.helpers"

describe("code-cells.api.jump", function()
  local jump

  setup(function() jump = require "code-cells.api.jump" end)

  teardown(function() jump = nil end)

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
        helpers.check_valid_msg("non-zero integer", jump.to_next, delimiter, count)
      end
    end)
  end)
end)
