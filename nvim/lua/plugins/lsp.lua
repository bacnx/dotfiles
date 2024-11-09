return {
    {
        'neovim/nvim-lspconfig',
        keys = {
            {
                'gI',
                function()
                    require('telescope.builtin').lsp_implementations()
                end,
                desc = 'Goto implementation',
            },
            {
                'gD',
                function()
                    require('telescope.builtin').lsp_definitions()
                end,
                desc = 'Goto definition',
            },
        },
        config = function(_, opts)
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local configs = require('lspconfig/configs')

            for lsp, config in pairs(opts.servers) do
                local lsp_config = vim.tbl_deep_extend('force', { capabilities = capabilities }, config)
                lspconfig[lsp].setup(lsp_config)
            end

            configs.golangcilsp = {
                default_config = {
                    cmd = { 'golangci-lint-langserver' },
                    root_dir = require('lspconfig').util.root_pattern('.git', 'go.mod'),
                    init_options = {
                        command = {
                            'golangci-lint',
                            'run',
                            '--enable-all',
                            '--disable',
                            'lll',
                            '--out-format',
                            'json',
                            '--issues-exit-code=1',
                        },
                    },
                },
            }
        end,
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim' },
                            },
                        },
                    },
                },
                clangd = {},
                ts_ls = {},
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
                golangci_lint_ls = {
                    filetypes = { 'go', 'gomod' },
                },
                cssls = {},
                emmet_ls = {},
                tailwindcss = {},
            },
        },
    },
}
