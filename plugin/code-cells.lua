if vim.g.loaded_code_cells then return end
vim.g.loaded_code_cells = true

-- Jump to cells {{{
vim.keymap.set(
  "n",
  "<Plug>(CellsJumpPrev)",
  function() require("code-cells.jump").jump_to_prev(vim.v.count1) end,
)
vim.keymap.set(
  "n",
  "<Plug>(CellsJumpNext)",
  function() require("code-cells.jump").jump_to_next(vim.v.count1) end,
)
-- }}}

-- vim: foldmethod=marker:
