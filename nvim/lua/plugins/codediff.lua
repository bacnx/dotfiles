-- The diff library (libvscode_diff.so) is downloaded on first :CodeDiff.
-- Run `:CodeDiff install!` to force a reinstall.
require("codediff").setup({
  explorer = {
    -- <Up>/<Down> (and j/k) open the file under the cursor; focus stays in the explorer
    auto_open_on_cursor = true,
  },
  keymaps = {
    view = {
      -- Match the <leader>gh* hunk keys from gitsigns.lua
      stage_hunk = "<leader>ghs",
      unstage_hunk = "<leader>ghu",
      discard_hunk = "<leader>ghr",
      -- Default <leader>e would shadow the global diagnostic float
      focus_explorer = "<leader>ge",
    },
  },
})

-- Scroll the diff panes from the explorer without focusing them.
-- Scrolls the rightmost diff window, then :syncbind pulls the other
-- scrollbound pane to match (inline layout has only one pane).
local function scroll_diff(keys)
  local explorer_win = vim.api.nvim_get_current_win()
  local target, target_col = nil, -1
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local col = vim.api.nvim_win_get_position(win)[2]
    if win ~= explorer_win and vim.api.nvim_win_get_config(win).relative == "" and col > target_col then
      target, target_col = win, col
    end
  end
  if target then
    vim.api.nvim_win_call(target, function()
      vim.cmd("normal! " .. vim.keycode(keys))
      vim.cmd("syncbind")
    end)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "codediff-explorer",
  callback = function(ev)
    local function bmap(lhs, keys, desc)
      vim.keymap.set("n", lhs, function() scroll_diff(keys) end, { buffer = ev.buf, desc = desc })
    end
    bmap("<S-Down>", "3<C-e>", "CodeDiff: scroll diff down")
    bmap("<S-Up>", "3<C-y>", "CodeDiff: scroll diff up")
    bmap("<C-d>", "<C-d>", "CodeDiff: scroll diff half page down")
    bmap("<C-u>", "<C-u>", "CodeDiff: scroll diff half page up")
    bmap("<PageDown>", "<C-f>", "CodeDiff: scroll diff page down")
    bmap("<PageUp>", "<C-b>", "CodeDiff: scroll diff page up")
  end,
})

local map = vim.keymap.set
map("n", "<leader>gd", "<cmd>CodeDiff<CR>", { desc = "CodeDiff: working tree" })
map("n", "<leader>gD", "<cmd>CodeDiff main...<CR>", { desc = "CodeDiff: branch vs main" })
map("n", "<leader>gf", "<cmd>CodeDiff history %<CR>", { desc = "CodeDiff: file history" })
map("n", "<leader>gH", "<cmd>CodeDiff history<CR>", { desc = "CodeDiff: repo history" })
map("x", "<leader>gf", ":CodeDiff history<CR>", { desc = "CodeDiff: history of selected lines" })
