return {
    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                icons = {
                    package_installed = '✓',
                    package_pending = '➜',
                    package_uninstalled = '✗',
                },
            },
        },
    },
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        dependencies = 'williamboman/mason.nvim',
        opts = {
            ensure_installed = {
                -- lsp
                'lua-language-server',
                'clangd',
                'typescript-language-server',
                'gopls',
                'emmet-ls',
                'tailwindcss-language-server',
                'json-lsp',
                'protols',

                -- formatter
                'stylua',
                'gofumpt',
                'goimports',
                'prettierd',
                'buf',

                -- lintter
                'eslint_d',
                'golangci-lint',
            },
            auto_update = true,
            run_on_start = true,
        },
    },
}
