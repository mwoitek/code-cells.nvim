vim.cmd.colorscheme "retrobox"

vim.g.loaded_matchit = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.wo.number = true
vim.wo.relativenumber = true

local plugin_path = os.getenv "MY_PLUGIN_PATH"
if not plugin_path then
  local msg = "Failed to load plugin"
  vim.notify(msg, vim.log.levels.ERROR)
  return
end
vim.opt.runtimepath:append(plugin_path)

vim.keymap.set({ "n", "o", "x" }, "<Space>cp", "<Plug>(CellsJumpPrev)")
vim.keymap.set({ "n", "o", "x" }, "<Space>cn", "<Plug>(CellsJumpNext)")
