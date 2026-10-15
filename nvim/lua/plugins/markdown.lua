-- Render markdown in the buffer: headings, tables, checkboxes, code blocks.
-- Rendering shows in normal mode; insert mode shows the raw text to edit.
-- Uses the markdown / markdown_inline parsers bundled with Neovim.
require("render-markdown").setup({
  file_types = { "markdown" },
})

vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", { desc = "Toggle markdown render" })
