local status, nvimtree = pcall(require, "nvim-tree")
if (not status) then return end

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

nvimtree.setup {
  actions = {
    open_file = {
      quit_on_open = true
    }
  }
}

-- mapping
vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<enter>')
vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<enter>')
