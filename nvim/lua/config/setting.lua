-- General Settings
vim.opt.mouse = ''                 -- Disable mouse support
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard
vim.opt.syntax = 'on'              -- Enable syntax highlighting
vim.opt.termguicolors = true       -- Enable true-color support

-- Line Numbers
vim.opt.number = true              -- Show absolute line numbers
vim.opt.relativenumber = true      -- Show relative line numbers

-- Indentation
vim.opt.tabstop = 4                -- Set tab width to 4 spaces
vim.opt.smartindent = true         -- Enable smart indentation
vim.opt.shiftwidth = 4             -- Indentation uses 4 spaces
vim.opt.expandtab = true           -- Use spaces instead of tabs

-- Scrolling and Cursor
vim.opt.scrolloff = 3              -- Keep 3 lines visible around cursor
vim.opt.cursorline = true          -- Highlight cursor line

-- Interface
vim.opt.wrap = false               -- Disable line wrapping
vim.opt.laststatus = 3             -- Use global status line
vim.opt.showmode = false           -- Hide mode indicator
