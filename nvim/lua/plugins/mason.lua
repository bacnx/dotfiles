return {
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = "williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				-- lsp
				"lua-language-server",
				"clangd",
				"typescript-language-server",
				"gopls",
				"emmet-ls",

				-- formatter
				"stylua",
				"gofumpt",
				"goimports",
				"golines",
				"prettierd",

				-- lintter
				"eslint_d",
			},
			auto_update = true,
			run_on_start = true,
		},
	},
}
