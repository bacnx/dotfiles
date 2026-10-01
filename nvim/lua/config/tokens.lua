-- Semantic design tokens: what each color is *for*. Catppuccin's palette is the
-- primitive layer, so no hex lives here; plugin configs read these roles and
-- never the palette directly. get_palette works before catppuccin.setup().
local flavour = "mocha"
local p = require("catppuccin.palettes").get_palette(flavour)

return {
  flavour = flavour,
  text = { accent = p.lavender, muted = p.overlay1 },
  mode = { normal = p.blue, insert = p.green, visual = p.mauve, replace = p.red, command = p.peach },
  git = { added = p.green, changed = p.yellow, removed = p.red },
  diag = { error = p.red, warn = p.yellow, info = p.sky, hint = p.teal },
  -- LazyVim's icons, written as escapes: pasting the raw Nerd Font glyphs has
  -- dropped them to plain spaces before.
  icons = {
    diag = { error = "\u{f057}", warn = "\u{f071}", info = "\u{f05a}", hint = "\u{f0eb}" },
  },
}
