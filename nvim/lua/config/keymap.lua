local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Remap leader with <space>
vim.g.mapleader = ' '

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Tabpage
keymap.set('n', 'te', ':tabedit <Return>')
keymap.set('n', 'tn', ':tabnext <Return>', opts)
keymap.set('n', 'tp', ':tabprev <Return>', opts)
keymap.set('n', '<Tab>', ':tabnext <Return>', opts)
keymap.set('n', '<S-Tab>', ':tabprev <Return>', opts)
keymap.set('n', 'td', ':tab split <Return>', opts)
keymap.set('n', 'tc', ':tabclose <Return>', opts)
keymap.set('n', 'tq', ':quit <Return>', opts)
keymap.set('n', '<leader>q', ':quitall <Return>', opts)
keymap.set('n', 'to', ':tabonly <Return>', opts)
keymap.set('n', 'ti', ':tabs <Return>', opts)

-- Split window
keymap.set('n', 'ss', ':split<Return><C-w>w', opts)
keymap.set('n', 'sv', ':vsplit<Return><C-w>w', opts)
-- Move window
keymap.set('', 'sh', '<C-w>h')
keymap.set('', 'sk', '<C-w>k')
keymap.set('', 'sj', '<C-w>j')
keymap.set('', 'sl', '<C-w>l')

-- Diagnostics
keymap.set('n', ']d', function()
    vim.diagnostic.goto_next()
end, opts)
keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev()
end, opts)

-- Clear search with <esc>
keymap.set({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and Clear hlsearch' })

-- Copy current file path to clipboard
keymap.set('n', '<leader>fp', function()
    print('Copied: ' .. vim.fn.expand('%'))
    vim.fn.setreg('+', vim.fn.expand('%'))
end, opts)
