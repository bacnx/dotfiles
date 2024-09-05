return {
    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                icons = {
                    package_installed = '✓',
                    package_pending = '➜',
                    package_uninstalled = '✗',
                }
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

                -- formatter
                'gofumpt',
                'goimports',
                'golines',
            },
            auto_update = true,
            run_on_start = true,
        },
    },
    {
        'neovim/nvim-lspconfig',
        keys = {
            {
                'gd',
                function()
                    require('telescope.builtin').lsp_definitions()
                end,
                desc = 'Goto definition',
            },
            {
                'gI',
                function()
                    require('telescope.builtin').lsp_implementations()
                end,
                desc = 'Goto implementation',
            },
        },
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
                gopls = {
                    cmd = { 'gopls' },
                    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
                    root_dir = require('lspconfig.util').root_pattern('go.work', 'gomod', '.git'),
                    settings = {
                        gopls = {
                            completeUnimported = true,
                            semanticTokens = true,
                            analyses = {
                                unusedparams = true,
                            },
                            staticcheck = true,
                        },
                    },
                },
                cssls = {},
                emmet_ls = {},
            },
        },
    },
    {
        'nvimtools/none-ls.nvim',
        ft = { 'go', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        config = function()
            local null_ls = require('null-ls')
            local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.gofumpt,
                    null_ls.builtins.formatting.goimports,
                    null_ls.builtins.formatting.golines,
                    null_ls.builtins.formatting.prettier,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method('textDocument/formatting') then
                        vim.api.nvim_clear_autocmds({
                            group = augroup,
                            buffer = bufnr,
                        })
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr })
                            end,
                        })
                    end
                end,
            })
        end,
    },
}
