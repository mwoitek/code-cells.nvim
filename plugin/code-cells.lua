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

-- Cell textobject {{{
vim.keymap.set(
  "x",
  "<Plug>(CellsObjOuter)",
  function() require("code-cells.api.cell").textobject() end
)
vim.keymap.set(
  "x",
  "<Plug>(CellsObjInner)",
  function() require("code-cells.api.cell").textobject(nil, true) end
)
vim.keymap.set("o", "<Plug>(CellsObjOuter)", "<Cmd>normal v<Plug>(CellsObjOuter)<CR>")
vim.keymap.set("o", "<Plug>(CellsObjInner)", "<Cmd>normal v<Plug>(CellsObjInner)<CR>")
-- }}}

-- vim: foldmethod=marker:
