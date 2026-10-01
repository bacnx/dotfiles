local theme = require("lualine.themes.auto")
local mocha = require("catppuccin.palettes").get_palette("mocha")
local muted_fg = "#7a7f8b"
local muted_bg = theme.normal.c.bg

for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
  if theme[mode] and theme[mode].c then
    theme[mode].c = vim.tbl_extend("force", theme[mode].c, { fg = muted_fg, bg = muted_bg })
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
-- Catppuccin's git colors (its gitsigns integration uses the same three).
local winbar_diff = {
  "diff",
  diff_color = {
    added = { fg = mocha.green },
    modified = { fg = mocha.yellow },
    removed = { fg = mocha.red },
  },
}

-- Text colour that follows the vim mode, using catppuccin's own lualine
-- mapping (normal blue, insert green, visual mauve, ...) but as fg only, so
-- the bar keeps its muted background.
local mode_fg = {
  n = mocha.blue,
  i = mocha.green,
  t = mocha.green,
  c = mocha.peach,
  v = mocha.mauve,
  V = mocha.mauve,
  ["\22"] = mocha.mauve, -- <C-v> blockwise visual
  s = mocha.mauve,
  S = mocha.mauve,
  ["\19"] = mocha.mauve, -- <C-s> blockwise select
  R = mocha.red,
}
local function mode_color()
  return { fg = mode_fg[vim.api.nvim_get_mode().mode:sub(1, 1)] or mocha.text, gui = "bold" }
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
        -- Same LazyVim icons as the sign column in diagnostics.lua.
        symbols = { error = "\u{f057} ", warn = "\u{f071} ", info = "\u{f05a} ", hint = "\u{f0eb} " },
        diagnostics_color = {
          error = "DiagnosticError",
          warn = "DiagnosticWarn",
          info = "DiagnosticInfo",
          hint = "DiagnosticHint",
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
    -- Lavender makes the focused window's file name pop.
    lualine_c = { winbar_dir, winbar_name({ fg = mocha.lavender, gui = "bold" }), winbar_diff },
  },
  inactive_winbar = {
    lualine_c = { winbar_dir, winbar_name(), winbar_diff },
  },
})
