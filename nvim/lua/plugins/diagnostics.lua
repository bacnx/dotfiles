vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  -- LazyVim's icons, written as escapes: pasting the raw Nerd Font glyphs has
  -- dropped them to plain spaces before.
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{f057}",
      [vim.diagnostic.severity.WARN] = "\u{f071}",
      [vim.diagnostic.severity.INFO] = "\u{f05a}",
      [vim.diagnostic.severity.HINT] = "\u{f0eb}",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

