-- vim-test dispatches into a tmux pane via vimux
vim.g["test#strategy"] = "vimux"

local map = vim.keymap.set

map("n", "<leader>tt", "<cmd>TestNearest<CR>", { silent = true, desc = "Test nearest" })
map("n", "<leader>tf", "<cmd>TestFile<CR>", { silent = true, desc = "Test file" })
map("n", "<leader>ta", "<cmd>TestSuite<CR>", { silent = true, desc = "Test suite" })
map("n", "<leader>tl", "<cmd>TestLast<CR>", { silent = true, desc = "Test last" })
map("n", "<leader>tg", "<cmd>TestVisit<CR>", { silent = true, desc = "Visit last test file" })
