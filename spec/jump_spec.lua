local assert = require "luassert"
local helpers = require "spec.helpers"

describe("code-cells.api.jump", function()
  local jump

  setup(function() jump = require "code-cells.api.jump" end)

  teardown(function() jump = nil end)

  after_each(helpers.unload_buffer)

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

    it("moves the cursor as expected when default arguments are used", function()
      helpers.edit_file "01.py"
      helpers.source_ftplugin()
      local init_pos = { 11, 28 }
      vim.api.nvim_win_set_cursor(0, init_pos)
      jump.to_next()
      local new_pos = vim.api.nvim_win_get_cursor(0)
      local exp_pos = { 15, 0 }
      assert.are.same(new_pos, exp_pos)
    end)
  end)
end)
