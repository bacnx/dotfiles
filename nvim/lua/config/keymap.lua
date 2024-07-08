local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Remap leader with <space>
vim.g.mapleader = " "

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- New tab
keymap.set("n", "te", ":tabedit <Return>")
-- Move tab
keymap.set("n", "<Tab>", ":tabnext <Return>", opts)
keymap.set("n", "<S-Tab>", ":tabprev <Return>", opts)
-- Close tab
keymap.set("n", "tq", function()
  local total_tabs = vim.fn.tabpagenr("$")
  local current_tab = vim.fn.tabpagenr()
  local total_windows = vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")

  if current_tab == 1 or current_tab == total_tabs or total_windows > 1 then
    vim.api.nvim_command("quit")
  else
    vim.api.nvim_command("quit")
    vim.api.nvim_command("tabprev")
  end
end, opts)
-- Close all tab
keymap.set("n", "<leader>qq", ":qa <Return>")
-- Close all tabs except the current tab
keymap.set("n", "to", ":tabonly <Return>")
-- Split window
keymap.set("n", "ss", ":split<Return><C-w>w", opts)
keymap.set("n", "sv", ":vsplit<Return><C-w>w", opts)
-- Move window
keymap.set("", "sh", "<C-w>h")
keymap.set("", "sk", "<C-w>k")
keymap.set("", "sj", "<C-w>j")
keymap.set("", "sl", "<C-w>l")

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end, opts)

-- Copy current file path to clipboard
keymap.set("n", "<leader>fp", function()
  print("Copied: " .. vim.fn.expand("%"))
  vim.fn.setreg("+", vim.fn.expand("%"))
end, opts)
