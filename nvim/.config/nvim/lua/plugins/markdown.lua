-- Render markdown in the buffer: headings, tables, checkboxes, code blocks.
-- Rendering shows in normal mode; insert mode shows the raw text to edit.
-- Uses the markdown / markdown_inline parsers bundled with Neovim.
require("render-markdown").setup({
  file_types = { "markdown" },
  -- LaTeX rendering needs utftex or latex2text, neither of which is installed.
  latex = { enabled = false },
})

vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", { desc = "Toggle markdown render" })
