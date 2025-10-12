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

  describe(".jump_to_prev()", function()
    it("throws an error when the argument type is wrong", function()
      local s = spy.on(valid, "non_zero_integer")
      local invalid_input = {
        boolean = false,
        float = 3.14,
        string = "NO",
        table = { ok = false },
      }
      for _, count in pairs(invalid_input) do
        assert.has_error(function() jump.jump_to_prev(count) end)
        assert.spy(s).was_called_with(count)
      end
    end)
  end)

  describe(".jump_to_next()", function()
    it("throws an error when the argument type is wrong", function()
      local s = spy.on(valid, "non_zero_integer")
      local invalid_input = {
        boolean = true,
        float = -1.3,
        string = "wrong",
        table = { no = true },
      }
      for _, count in pairs(invalid_input) do
        assert.has_error(function() jump.jump_to_next(count) end)
        assert.spy(s).was_called_with(count)
      end
    end)
  end)
end)
