local t = require("config.tokens")
local theme = require("lualine.themes.auto")
local muted_bg = theme.normal.c.bg

for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
  if theme[mode] and theme[mode].c then
    theme[mode].c = vim.tbl_extend("force", theme[mode].c, { fg = t.text.muted, bg = muted_bg })
  end
end

-- codediff's diff panes keep the real file's filetype, so disabled_filetypes
-- can't reach them; hide the winbar for any window in a codediff tab instead.
local function not_in_codediff()
  local lifecycle = package.loaded["codediff.ui.lifecycle"]
  return not (lifecycle and lifecycle.get_session(vim.api.nvim_get_current_tabpage()))
end
-- The winbar path is two components so only the file name stands out. The
-- leading space lives in the dir part, which is never empty, so a file in the
-- cwd root still gets padding.
local winbar_dir = {
  function()
    local dir = vim.fn.fnamemodify(vim.fn.expand("%:~:."), ":h")
    return " " .. ((dir == "." or dir == "") and "" or dir .. "/")
  end,
  cond = not_in_codediff,
  padding = 0,
}
local function winbar_name(color)
  return { "filename", path = 0, cond = not_in_codediff, padding = { left = 0, right = 1 }, color = color }
end
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
    lualine_c = { winbar_dir, winbar_name({ fg = t.text.accent, gui = "bold" }), winbar_diff },
  },
  inactive_winbar = {
    lualine_c = { winbar_dir, winbar_name(), winbar_diff },
  },
})
