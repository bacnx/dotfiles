local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local function extend_opts(custom_opts)
    return vim.tbl_extend('force', opts, custom_opts)
end

-- Remap leader with <space>
vim.g.mapleader = ' '

-- Buffers
keymap.set('n', 'te', ':enew <Return>', { desc = 'Create a new unnamed buffer on current window' })
keymap.set('n', '<Tab>', ':bnext <Return>', extend_opts({ desc = 'Next buffer' }))
keymap.set('n', '<S-Tab>', ':bprevious <Return>', extend_opts({ desc = 'Previous buffer' }))
keymap.set('n', 'tq', ':bdelete <Return>', extend_opts({ desc = 'Delete buffer' }))
keymap.set('n', '<leader>q', ':quitall <Return>', extend_opts({ desc = 'Quit nvim' }))
keymap.set('n', '<leader><leader>', ':b# <Return>', extend_opts({ desc = 'Switch to last edited buffer' }))

-- Split window
keymap.set('n', 'ss', ':split<Return><C-w>w', opts)
keymap.set('n', 'sv', ':vsplit<Return><C-w>w', opts)

-- Clear search with <esc>
keymap.set({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and Clear hlsearch' })
