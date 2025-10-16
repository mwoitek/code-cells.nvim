if vim.g.loaded_code_cells then return end
vim.g.loaded_code_cells = true

-- Jump to cells {{{
vim.keymap.set(
  { "n", "o", "x" },
  "<Plug>(CellsJumpNext)",
  function() require("code-cells.api.jump").to_next(nil, vim.v.count1) end
)
vim.keymap.set(
  { "n", "o", "x" },
  "<Plug>(CellsJumpPrev)",
  function() require("code-cells.api.jump").to_prev(nil, vim.v.count1) end
)
-- }}}

-- vim: foldmethod=marker:
