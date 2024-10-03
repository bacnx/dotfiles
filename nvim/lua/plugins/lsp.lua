return {
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
                cssls = {},
                emmet_ls = {},
            },
        },
    },
    {
        'nvimdev/lspsaga.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        opts = {
            code_action = {
                extend_gitsigns = true,
            },
            ui = {
                code_action = '',
            },
        },
    },
}
