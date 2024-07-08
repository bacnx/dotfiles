local status, ts = pcall(require, 'nvim-treesitter.configs')
if not status then return end

ts.setup {
  ensure_installed = {
    "lua",
    "go",
    "sql",
  },
  sync_install = true,
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
}
