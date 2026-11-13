require('telescope').setup({
  defaults = {
    -- 'flex' picks horizontal when there is room, vertical when there is not,
    -- so a narrow tmux pane gets a preview stacked below instead of none at all.
    layout_strategy = 'flex',
    -- Prompt on top with the best match right under it, read top to bottom.
    sorting_strategy = 'ascending',
    -- "init.lua  lua/telescope": the name to scan for first, its folder dimmed.
    path_display = { 'filename_first' },
    layout_config = {
      width = 0.9,
      height = 0.9,
      prompt_position = 'top',
      -- Below this many columns, flex flips to the vertical layout.
      flex = { flip_columns = 130 },
      -- preview_cutoff defaults to 120 and silently hides the preview under it.
      horizontal = { preview_width = 0.55, preview_cutoff = 0 },
      -- mirror moves the preview below, so the top prompt is not wedged
      -- between the preview and the results.
      vertical = { preview_height = 0.5, preview_cutoff = 0, mirror = true },
    },
    file_ignore_patterns = { 'node_modules/', '%.git/' },
    mappings = {
      i = {
        ['<C-k>'] = 'move_selection_previous',
        ['<C-j>'] = 'move_selection_next',
        -- One press closes; the prompt's normal mode is never used.
        ['<Esc>'] = 'close',
      },
    },
  },
  pickers = {
    find_files = { hidden = true },
    live_grep = {
      additional_args = function()
        return { '--hidden' }
      end,
    },
  },
  extensions = {
    file_browser = {
      hijack_netrw = true,
      hidden = true,
      -- Always side by side: flex's vertical layout leaves the browser only a
      -- handful of entries and preview lines.
      layout_strategy = 'horizontal',
    },
  },
})

local keymap = vim.keymap.set
local builtin = require('telescope.builtin')
keymap('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
keymap('n', '<leader>fg', builtin.live_grep,  { desc = 'Live grep' })
keymap('n', '<leader>fb', builtin.buffers,    { desc = 'Buffers' })
-- Reopen the last picker with its query and selection, e.g. the next grep hit.
keymap('n', '<leader>fr', builtin.resume,     { desc = 'Resume last picker' })
keymap('n', '<leader>fw', builtin.grep_string, { desc = 'Grep word under cursor' })
keymap('n', '<leader>fo', function()
  builtin.oldfiles({ only_cwd = true })
end, { desc = 'Recent files in cwd' })
keymap('n', '<leader>f/', builtin.current_buffer_fuzzy_find, { desc = 'Search in buffer' })
-- fS, not fs: fs is the file browser below.
keymap('n', '<leader>fS', builtin.lsp_document_symbols, { desc = 'Document symbols' })
keymap('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
keymap('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })

-- Same pickers, but ignoring .gitignore (dist/, build/, node_modules/, ...)
keymap('n', '<leader>fa', function()
  builtin.find_files({
    hidden = true,
    no_ignore = true,
    file_ignore_patterns = { '%.git/' },
  })
end, { desc = 'Find files (no ignore)' })
keymap('n', '<leader>fG', function()
  builtin.live_grep({ additional_args = function()
    return { '--hidden', '--no-ignore' }
  end })
end, { desc = 'Live grep (no ignore)' })

-- fzf syntax in every picker: 'exact  ^start  end$  !exclude
require('telescope').load_extension('fzf')
require('telescope').load_extension('file_browser')
keymap('n', '<leader>fs', function()
  require('telescope').extensions.file_browser.file_browser({
    path = '%:p:h',
    select_buffer = true,
  })
end)
