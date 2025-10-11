---@diagnostic disable: param-type-mismatch, undefined-field

describe("code-cells.jump", function()
  local jump = require "code-cells.jump"

  describe(".jump_to_prev()", function()
    it("throws an error when the argument type is wrong", function()
      local count = 3.14
      assert.has_error(function() jump.jump_to_prev(count) end)
    end)
  end)

  describe(".jump_to_next()", function()
    it("throws an error when the argument type is wrong", function()
      local count = true
      assert.has_error(function() jump.jump_to_next(count) end)
    end)
  end)
end)
