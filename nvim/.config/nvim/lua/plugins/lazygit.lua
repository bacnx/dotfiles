-- lazygit.nvim is added with load = false; packadd on first use.
vim.keymap.set("n", "<leader>gg", function()
  vim.cmd.packadd("lazygit.nvim")
  vim.cmd("LazyGit")
end, { silent = true, desc = "LazyGit" })

-- lazygit's `e` sends files back to this nvim with --remote instead of nesting
-- one (see lazygit/config.yml). --remote edits in the current window, which is
-- lazygit's float, and lazygit.nvim closes that float on exit, so the file
-- would end up hidden. Remember a file that lands in a float while lazygit is
-- open, and show it in the window we return to.
local pending
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("lazygit_remote_edit", { clear = true }),
  callback = function(ev)
    if vim.g.lazygit_opened == 1 and vim.bo[ev.buf].buftype == "" and vim.api.nvim_win_get_config(0).relative ~= "" then
      pending = ev.buf
    end
  end,
})
vim.g.lazygit_on_exit_callback = function()
  if pending and vim.api.nvim_buf_is_valid(pending) then
    vim.api.nvim_win_set_buf(0, pending)
  end
  pending = nil
end
