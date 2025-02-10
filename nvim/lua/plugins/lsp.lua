return {
    {
        'neovim/nvim-lspconfig',
        keys = {
            {
                'gI',
                require('telescope.builtin').lsp_implementations,
                desc = 'Goto implementation',
            },
            {
                'gD',
                require('telescope.builtin').lsp_definitions,
                desc = 'Goto definition',
            },
        },
        config = function(_, opts)
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            for lsp, config in pairs(opts.servers) do
                local lsp_config = vim.tbl_deep_extend('force', { capabilities = capabilities }, config)
                lspconfig[lsp].setup(lsp_config)
            end
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
                clangd = {
                    filetypes = { 'c', 'objc', 'cpp', 'objcpp' },
                },
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
                protols = {},
                jsonls = {},
            },
        },
    },
}
