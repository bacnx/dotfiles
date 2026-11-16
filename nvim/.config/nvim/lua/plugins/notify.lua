-- Dress up ui2's message window (see options.lua): a rounded border whose
-- colour and title follow the level of the newest message in it. There is no
-- notify plugin: vim.notify goes through nvim_echo into this one window, which
-- stacks messages, so the border reflects the latest one.
--
-- vim._core.ui2 is private (0.12, experimental); if it changes shape this
-- module bails out and messages keep the plain default window.
local ok_ui, ui = pcall(require, "vim._core.ui2")
local ok_msgs, msgs = pcall(require, "vim._core.ui2.messages")
if not (ok_ui and ok_msgs and type(msgs.msg_show) == "function") then
  return
end

local t = require("config.tokens")
local api = vim.api

local levels = {
  error = { title = "Error", icon = t.icons.diag.error, color = t.diag.error },
  warn = { title = "Warning", icon = t.icons.diag.warn, color = t.diag.warn },
  info = { title = "Info", icon = t.icons.diag.info, color = t.diag.info },
}

local function set_highlights()
  for name, l in pairs(levels) do
    local cap = name:sub(1, 1):upper() .. name:sub(2)
    api.nvim_set_hl(0, "MsgBorder" .. cap, { fg = l.color })
    api.nvim_set_hl(0, "MsgTitle" .. cap, { fg = l.color, bold = true })
    l.title_hl = "MsgTitle" .. cap
    l.winhl = ("FloatBorder:MsgBorder%s,FloatTitle:%s"):format(cap, l.title_hl)
  end
end
set_highlights()
api.nvim_create_autocmd("ColorScheme", {
  group = api.nvim_create_augroup("ui2_msg_hl", { clear = true }),
  callback = set_highlights,
})

-- vim.notify drops the level: ERROR arrives as an error kind, WARN only as a
-- WarningMsg chunk, everything else as a plain message.
local error_kinds = { emsg = true, echoerr = true, lua_error = true, rpc_error = true }
local function level_of(kind, content)
  if error_kinds[kind] then
    return "error"
  end
  local err_id, warn_id = vim.fn.hlID("ErrorMsg"), vim.fn.hlID("WarningMsg")
  local found = kind == "wmsg" and "warn" or "info"
  for _, chunk in ipairs(content or {}) do
    if chunk[3] == err_id then
      return "error"
    elseif chunk[3] == warn_id then
      found = "warn"
    end
  end
  return found
end

local function msg_win()
  local win = ui.wins and ui.wins.msg
  return win and api.nvim_win_is_valid(win) and win or nil
end

local function style(level)
  local win = msg_win()
  if not win then
    return
  end
  local l = levels[level]
  api.nvim_win_set_config(win, {
    border = "rounded",
    title = { { (" %s %s "):format(l.icon, l.title), l.title_hl } },
    title_pos = "left",
  })
  -- Keep ui2's own entries (it hides Search there) and swap only ours.
  local keep = vim.tbl_filter(function(e)
    return not e:match("^FloatBorder:") and not e:match("^FloatTitle:")
  end, vim.split(vim.wo[win].winhighlight, ",", { trimempty = true }))
  table.insert(keep, l.winhl)
  vim.wo[win].winhighlight = table.concat(keep, ",")
end

-- Restyle only when the message actually landed in the msg window (not the
-- pager, a dialog or the search count), told apart by its buffer changing.
local msg_show = msgs.msg_show
msgs.msg_show = function(kind, content, ...)
  local buf = ui.bufs and ui.bufs.msg
  local tick = buf and api.nvim_buf_is_valid(buf) and api.nvim_buf_get_changedtick(buf)
  msg_show(kind, content, ...)
  buf = ui.bufs and ui.bufs.msg
  if buf and api.nvim_buf_is_valid(buf) and api.nvim_buf_get_changedtick(buf) ~= tick then
    pcall(style, level_of(kind, content))
  end
end
