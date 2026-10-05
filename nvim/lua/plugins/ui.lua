local t = require("config.tokens")
local theme = require("lualine.themes.auto")
local muted_bg = theme.normal.c.bg

for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
  if theme[mode] and theme[mode].c then
    theme[mode].c = vim.tbl_extend("force", theme[mode].c, { fg = t.text.muted, bg = muted_bg })
  end
end

-- In a codediff tab the left pane shows a codediff:// buffer, so both diff
-- panes take the path from the session instead (relative to the git root), plus
-- the revision that side shows. Both panes need a winbar, or none: a winbar on
-- one side only would push its lines a row below the other side's.
local function codediff_side()
  local lifecycle = package.loaded["codediff.ui.lifecycle"]
  local sess = lifecycle and lifecycle.get_session(vim.api.nvim_get_current_tabpage())
  if not sess then
    return nil
  end
  local win = vim.api.nvim_get_current_win()
  local side = (win == sess.original_win and "original") or (win == sess.modified_win and "modified") or nil
  if not side then
    return nil
  end
  -- An added or deleted file has a path on one side only.
  local path = sess[side] or sess[side == "original" and "modified" or "original"]
  return { path = path and path.relative or vim.fn.expand("%:~:."), revision = sess[side .. "_revision"] }
end
local function in_codediff()
  return codediff_side() ~= nil
end
local function not_in_codediff()
  return not in_codediff()
end

local function revision_label(revision)
  if revision == nil or revision == "WORKING" then
    return "working"
  elseif revision == "STAGED" then
    return "staged"
  elseif revision:match("^%x+$") and #revision >= 40 then
    return revision:sub(1, 7)
  end
  return revision
end

-- The winbar path is two components so only the file name stands out. The
-- leading space lives in the dir part, which is never empty, so a file in the
-- cwd root still gets padding.
local winbar_dir = {
  function()
    local side = codediff_side()
    local dir = vim.fn.fnamemodify(side and side.path or vim.fn.expand("%:~:."), ":h")
    return " " .. ((dir == "." or dir == "") and "" or dir .. "/")
  end,
  padding = 0,
}
local function winbar_name(color)
  return { "filename", path = 0, cond = not_in_codediff, padding = { left = 0, right = 1 }, color = color }
end
local function winbar_diff_name(color)
  return {
    function()
      return vim.fn.fnamemodify(codediff_side().path, ":t")
    end,
    cond = in_codediff,
    padding = { left = 0, right = 1 },
    color = color,
  }
end
local winbar_revision = {
  function()
    return revision_label(codediff_side().revision)
  end,
  cond = in_codediff,
}
-- Same git tokens as the gitsigns column (see colorscheme.lua).
local winbar_diff = {
  "diff",
  diff_color = {
    added = { fg = t.git.added },
    modified = { fg = t.git.changed },
    removed = { fg = t.git.removed },
  },
}

-- Text colour that follows the vim mode, using catppuccin's own lualine
-- mapping (normal blue, insert green, visual mauve, ...) but as fg only, so
-- the bar keeps its muted background.
local mode_fg = {
  n = t.mode.normal,
  i = t.mode.insert,
  t = t.mode.insert,
  c = t.mode.command,
  v = t.mode.visual,
  V = t.mode.visual,
  ["\22"] = t.mode.visual, -- <C-v> blockwise visual
  s = t.mode.visual,
  S = t.mode.visual,
  ["\19"] = t.mode.visual, -- <C-s> blockwise select
  R = t.mode.replace,
}
local function mode_color()
  return { fg = mode_fg[vim.api.nvim_get_mode().mode:sub(1, 1)] or t.mode.normal, gui = "bold" }
end

require("lualine").setup({
  options = {
    icons_enabled = false,
    theme = theme,
    component_separators = "",
    disabled_filetypes = {
      winbar = { "codediff-explorer", "codediff-history", "codediff-help" },
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      { "mode", color = mode_color },
      "branch",
    },
    lualine_x = {
      {
        "diagnostics",
        symbols = {
          error = t.icons.diag.error .. " ",
          warn = t.icons.diag.warn .. " ",
          info = t.icons.diag.info .. " ",
          hint = t.icons.diag.hint .. " ",
        },
        diagnostics_color = {
          error = { fg = t.diag.error },
          warn = { fg = t.diag.warn },
          info = { fg = t.diag.info },
          hint = { fg = t.diag.hint },
        },
        update_in_insert = false,
      },
      "lsp_status",
      "encoding",
      "progress",
      { "location", color = mode_color },
    },
    lualine_y = {},
    lualine_z = {},
  },
  winbar = {
    -- The accent makes the focused window's file name pop.
    lualine_c = {
      winbar_dir,
      winbar_name({ fg = t.text.accent, gui = "bold" }),
      winbar_diff_name({ fg = t.text.accent, gui = "bold" }),
      winbar_revision,
      winbar_diff,
    },
  },
  inactive_winbar = {
    lualine_c = { winbar_dir, winbar_name(), winbar_diff_name(), winbar_revision, winbar_diff },
  },
})
