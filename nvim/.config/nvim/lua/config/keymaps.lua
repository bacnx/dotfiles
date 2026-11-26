local map = vim.keymap.set

-- ============================================================
-- ARROW-KEY NAVIGATION
-- Primary movement is via arrow keys (split keyboard / colemak-dh).
-- Nothing here unbinds or blocks h/j/k/l — arrows are added alongside.
-- ============================================================

-- Wrap-aware vertical motion: `wrap` is on, so a bare <Down>/<Up> would skip
-- over wrapped segments. The count guard keeps 5<Down> meaning five real lines.
map({ "n", "v" }, "<Down>", function()
  return vim.v.count == 0 and "gj" or "j"
end, { expr = true, desc = "Down (visual line)" })

map({ "n", "v" }, "<Up>", function()
  return vim.v.count == 0 and "gk" or "k"
end, { expr = true, desc = "Up (visual line)" })

-- Window resize. NOTE: many terminals swallow <C-S-Arrow>; if these do not
-- register, rebind to <leader> + arrow.
map("n", "<C-S-Left>", "<cmd>vertical resize -2<CR>", { desc = "Shrink window width" })
map("n", "<C-S-Right>", "<cmd>vertical resize +2<CR>", { desc = "Grow window width" })
map("n", "<C-S-Up>", "<cmd>resize +2<CR>", { desc = "Grow window height" })
map("n", "<C-S-Down>", "<cmd>resize -2<CR>", { desc = "Shrink window height" })

-- Move lines up/down — Alt+arrows, with J/K kept as a fallback
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save and quit
map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")

-- Buffer navigation
map("n", "<Tab>", "<cmd>bnext<CR>")
map("n", "<S-Tab>", "<cmd>bprev<CR>")
map("n", "<leader><leader>", "<cmd>b#<CR>")
map("n", "<leader>c", "<cmd>bdelete<CR>")
map("n", "<leader>C", "<cmd>%bdelete<CR>")

-- Copy the current file's path to the system clipboard (+ register).
-- `%:.` is relative to cwd (falls back to absolute outside it); `%:p` is absolute.
-- `with_line` appends the cursor line (`path:42`), or the selected range in
-- visual mode (`path:10-20`), for pointing a Claude Code session at code.
local function copy_path(modifier, with_line)
  return function()
    local path = vim.fn.expand(modifier)
    if path == "" then
      vim.notify("Buffer has no file", vim.log.levels.WARN)
      return
    end
    local what = modifier == "%:p" and "absolute file path" or "relative file path"
    if with_line then
      local first, last = vim.fn.line("v"), vim.fn.line(".")
      if first > last then
        first, last = last, first
      end
      if first == last then
        path = path .. ":" .. first
        what = "file path and line " .. first
      else
        path = path .. ":" .. first .. "-" .. last
        what = ("file path and lines %d-%d (%d lines)"):format(first, last, last - first + 1)
      end
      if vim.fn.mode():match("[vV\22]") then
        vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
      end
    end
    vim.fn.setreg("+", path)
    vim.notify(("Copied %s to clipboard:\n%s"):format(what, path), vim.log.levels.INFO)
  end
end
map("n", "<leader>yf", copy_path("%:."), { desc = "Copy file path (relative)" })
map("n", "<leader>yF", copy_path("%:p"), { desc = "Copy file path (absolute)" })
map({ "n", "x" }, "<leader>yl", copy_path("%:.", true), { desc = "Copy file path:line (relative)" })

-- Diagnostic keymaps
-- vim.diagnostic.jump requires an opts table with `count`; passing the bare
-- function errors instead of jumping.
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })

map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
map("n", "<leader>d", "<cmd>Telescope diagnostics<CR>", { desc = "Show workspace diagnostics" })
map("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Set diagnostics location list" })
