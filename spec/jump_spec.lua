---@diagnostic disable: param-type-mismatch, undefined-field

describe("code-cells.jump", function()
  local jump
  local valid

  setup(function()
    jump = require "code-cells.jump"
    valid = require "code-cells.validation"
  end)

  teardown(function()
    jump = nil
    valid = nil
  end)

  describe(".to_next()", function()
    it("throws an error when the type of `count` is wrong", function()
      local s = spy.on(valid, "non_zero_integer")
      local delimiter = "-- %%"
      local invalid_input = {
        boolean = true,
        float = -1.3,
        string = "wrong",
        table = { no = true },
      }
      for _, count in pairs(invalid_input) do
        assert.has_error(function() jump.to_next(delimiter, count) end)
        assert.spy(s).was_called_with(count)
      end
    end)
  end)
end)
