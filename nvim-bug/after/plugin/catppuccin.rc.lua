local status, catppuccin = pcall(require, 'catppuccin')
if not status then return end

catppuccin.setup({
  transparent_background = true,
  custom_highlights = function(colors)
    return {
      Comment = { fg = colors.flamingo },
      TabLineSel = { bg = colors.pink },
      CmpBorder = { fg = colors.pink },
      Pmenu = { bg = colors.none },
    }
  end,
  integrations = {
    telescope = {
      enabled = true,
      style = 'nvchad',
    },
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
      },
      inlay_hints = {
        background = true,
      },
    },
    mason = true,
    cmp = true,
  },
})

vim.cmd.colorscheme 'catppuccin'
