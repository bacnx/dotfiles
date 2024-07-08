return {
    {
        'williamboman/mason.nvim',
        dependencies = {
            { 'williamboman/mason-lspconfig.nvim', config = function() end },
        },
        opts = {
            -- WARN: not sure it work
            ensure_installed = {
                'tree-sitter-cli',
                'lua_ls',
                'clangd',
                'typescript-language-server',
            },
            ui = {
                icons = {
                    package_installed = '✓',
                    package_pending = '➜',
                    package_uninstalled = '✗',
                }
            },
        },
        config = true,
    },
    {
        'neovim/nvim-lspconfig',
        config = function(_, opts)
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            for lsp, config in pairs(opts.servers) do
                local lsp_config = vim.tbl_deep_extend(
                    'force',
                    { capabilities = capabilities },
                    config
                )
                lspconfig[lsp].setup(lsp_config)
            end
        end,
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = {'vim'},
                            },
                        },
                    },
                },
                clangd = {},
                tsserver = {},
            },
        },
    },
}
