local map = vim.keymap.set
local Snacks = require("snacks")

map({ "n", "v" }, "y", '"+y', { noremap = true })
map({ "n", "v" }, "Y", '"+Y', { noremap = true })
map("n", "p", '"+p', { noremap = true })
map("n", "P", '"+P', { noremap = true })

map("x", "p", function()
  local clipboard = vim.fn.getreg("+")
  local clipboard_type = vim.fn.getregtype("+")
  vim.cmd('normal! "+p')
  vim.fn.setreg("+", clipboard, clipboard_type)
end, { noremap = true, silent = true })

map("x", "P", function()
  local clipboard = vim.fn.getreg("+")
  local clipboard_type = vim.fn.getregtype("+")
  vim.cmd('normal! "+P')
  vim.fn.setreg("+", clipboard, clipboard_type)
end, { noremap = true, silent = true })

-- Use Snacks.picker instead of deprecated lazyvim.util.pick
map("n", "<leader><space>", function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end, { desc = "Find Files (cwd)" })
map("n", "<leader>ff", function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end, { desc = "Find Files (cwd)" })
map("n", "<leader>/", function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end, { desc = "Grep (cwd)" })
map("n", "<leader>sg", function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end, { desc = "Grep (cwd)" })
map("n", "<leader>sG", function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end, { desc = "Grep (cwd)" })
map({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word({ cwd = vim.fn.getcwd() }) end, { desc = "Word Search (cwd)" })
map({ "n", "x" }, "<leader>sW", function() Snacks.picker.grep_word({ cwd = vim.fn.getcwd() }) end, { desc = "Word Search (cwd)" })

map("n", "<leader>wH", "<C-w><", { desc = "Decrease window width" })
map("n", "<leader>wL", "<C-w>>", { desc = "Increase window width" })
map("n", "<leader>wK", "<C-w>+", { desc = "Increase window height" })
map("n", "<leader>wJ", "<C-w>-", { desc = "Decrease window height" })

map("i", "<A-BS>", "<C-w>", { desc = "Delete word backward" })
