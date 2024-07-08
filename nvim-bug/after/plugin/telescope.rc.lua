local status, telescope = pcall(require, 'telescope')
if not status then return end
local builtin = require('telescope.builtin')

local function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

telescope.setup {}

telescope.load_extension 'file_browser'

vim.keymap.set('n', ';f', function()
  builtin.find_files({
    no_ignores = false
  })
end)
vim.keymap.set('n', ';r', function()
  builtin.live_grep()
end)

vim.keymap.set("n", "sf", function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 }
  })
end)
