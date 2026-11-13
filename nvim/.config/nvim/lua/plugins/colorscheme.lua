local tokens = require("config.tokens")

require("catppuccin").setup({
  flavour = tokens.flavour,
  transparent_background = true,
  -- Catppuccin's gitsigns integration doesn't take effect here (the signs fell
  -- back to gitsigns' own Added/Changed/Removed links), so set them from tokens.
  custom_highlights = function()
    return {
      GitSignsAdd = { fg = tokens.git.added },
      GitSignsChange = { fg = tokens.git.changed },
      GitSignsDelete = { fg = tokens.git.removed },
    }
  end,
})

vim.cmd.colorscheme("catppuccin")
