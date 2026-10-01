local theme = require("lualine.themes.auto")
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
local winbar_filename = { "filename", path = 1, cond = not_in_codediff }

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
      "mode",
      "branch",
    },
    lualine_x = {
      "diagnostics",
      "lsp_status",
      "encoding",
      "progress",
      "location",
    },
    lualine_y = {},
    lualine_z = {},
  },
  winbar = {
    lualine_c = { winbar_filename, "diff" },
  },
  inactive_winbar = {
    lualine_c = { winbar_filename, "diff" },
  },
})
