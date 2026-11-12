-- Keep the empty [No Name] buffer out of the buffer list.
--
-- Neovim creates one on its own: at startup with no file, and again after the
-- last buffer is deleted. It is listed, so <Tab> / <S-Tab> (:bnext / :bprev)
-- stop on it. Unlist it while it is empty, and list it again as soon as it gets
-- text or a name, so a real scratch buffer is never lost from the list.
local group = vim.api.nvim_create_augroup("unlist_empty_noname", { clear = true })

local function is_empty_noname(buf)
  if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].buftype ~= "" then return false end
  if vim.bo[buf].modified then return false end
  local count = vim.api.nvim_buf_line_count(buf) -- 0 when the buffer is not loaded yet
  return count == 0 or (count == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "")
end

local function sync(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if is_empty_noname(buf) then
    if vim.bo[buf].buflisted then
      vim.bo[buf].buflisted = false
      vim.b[buf].unlisted_as_empty = true
    end
  elseif vim.b[buf].unlisted_as_empty then
    -- Only relist what this file unlisted; plugins hide their own nameless buffers.
    vim.bo[buf].buflisted = true
    vim.b[buf].unlisted_as_empty = nil
  end
end

-- BufAdd fires before Neovim has finished setting the buffer up, so wait a tick.
vim.api.nvim_create_autocmd("BufAdd", {
  group = group,
  callback = function(ev)
    vim.schedule(function() sync(ev.buf) end)
  end,
})

vim.api.nvim_create_autocmd({ "BufModifiedSet", "BufFilePost" }, {
  group = group,
  callback = function(ev) sync(ev.buf) end,
})

-- The startup buffer exists before this file is loaded, so BufAdd never fires for it.
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do sync(buf) end
  end,
})
