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

-- Toggling the layout (t) moves focus into the diff pane; when it was pressed
-- from the explorer, put the cursor back there once the re-render settles.
local view = require("codediff.ui.view")
local toggle_layout = view.toggle_layout
view.toggle_layout = function(tabpage)
  local from_win = vim.api.nvim_get_current_win()
  local ok = toggle_layout(tabpage)
  if vim.bo[vim.api.nvim_win_get_buf(from_win)].filetype == "codediff-explorer" then
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(from_win) then
        vim.api.nvim_set_current_win(from_win)
      end
    end)
  end
  return ok
end

-- Wrap long lines in the inline layout only: side-by-side needs 'wrap' off to
-- keep both panes aligned row for row. codediff resets wrap=false on every
-- inline render, so turn it back on whenever that happens.
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "wrap",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local lifecycle = package.loaded["codediff.ui.lifecycle"]
    local sess = lifecycle and lifecycle.get_session(vim.api.nvim_win_get_tabpage(win))
    if sess and sess.layout == "inline" and sess.modified_win == win and not vim.wo[win].wrap then
      vim.wo[win].wrap = true
    end
  end,
})

-- codediff leaves 'relativenumber' to the user, so the diff panes inherit the
-- global setting; use absolute numbers there so both sides line up by number.
-- codediff snapshots each pane's number options into sess.window_profiles and
-- re-applies that snapshot whenever the pane changes, so patch it too.
-- BufWinEnter re-applies it because a buffer brings back the window options it
-- last had, which would turn relative numbers on again when switching files.
local function absolute_numbers(tabpage)
  local lifecycle = package.loaded["codediff.ui.lifecycle"]
  local sess = lifecycle and lifecycle.get_session(tabpage)
  if not sess then
    return
  end
  for _, profile in pairs(sess.window_profiles or {}) do
    profile.relativenumber = false
  end
  for _, win in ipairs({ sess.original_win, sess.modified_win }) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].relativenumber = false
    end
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "CodeDiffOpen",
  callback = function(ev)
    absolute_numbers(ev.data.tabpage)
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    absolute_numbers(vim.api.nvim_get_current_tabpage())
  end,
})

-- codediff clears both panes' winbar on every BufEnter/WinEnter, and lualine's
-- timer only puts it back up to a second later, so the panes jump a row. Put
-- the lualine winbar (path + revision, see ui.lua) back right after codediff.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  callback = function()
    local lifecycle = package.loaded["codediff.ui.lifecycle"]
    if lifecycle and lifecycle.get_session(vim.api.nvim_get_current_tabpage()) then
      vim.schedule(function()
        require("lualine").refresh({ scope = "tabpage", place = { "winbar" } })
      end)
    end
  end,
})

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
