-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override explorer to show hidden files by default
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer.open({ hidden = true, ignored = true })
end, { desc = "Explorer (with hidden)" })

vim.keymap.set("n", "<leader>fe", function()
  Snacks.explorer.open({ hidden = true, ignored = true })
end, { desc = "Explorer (with hidden)" })

vim.keymap.set("n", "<leader>fE", function()
  Snacks.explorer.open({ hidden = true, ignored = true, cwd = LazyVim.root() })
end, { desc = "Explorer (root, with hidden)" })
