local status, null_ls = pcall(require, "null-ls")
if (not status) then return end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  })
end

null_ls.setup {
  sources = {
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.diagnostics.eslint_d.with({
      diagnostics_format = '[eslint] #{m}\n(#{c})'
    }),
    null_ls.builtins.diagnostics.fish
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          lsp_formatting(bufnr)
        end,
      })
    end
  end
}

vim.api.nvim_create_user_command(
  'DisableLspFormatting',
  function()
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = 0 })
  end,
  { nargs = 0 }
)
-- local status, null_ls = pcall(require, "null-ls")
-- if (not status) then return end
--
-- local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
-- local event = "BufWritePre" -- or "BufWritePost"
-- local async = event == "BufWritePost"
--
-- null_ls.setup({
--   on_attach = function(client, bufnr)
--     if client.supports_method("textDocument/formatting") then
--       vim.keymap.set("n", "<Leader>f", function()
--         vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
--       end, { buffer = bufnr, desc = "[lsp] format" })
--
--       -- format on save
--       vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
--       vim.api.nvim_create_autocmd(event, {
--         buffer = bufnr,
--         group = group,
--         callback = function()
--           vim.lsp.buf.format({ bufnr = bufnr, async = async })
--         end,
--         desc = "[lsp] format on save",
--       })
--     end
--
--     if client.supports_method("textDocument/rangeFormatting") then
--       vim.keymap.set("x", "<Leader>f", function()
--         vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
--       end, { buffer = bufnr, desc = "[lsp] format" })
--     end
--   end,
-- })
