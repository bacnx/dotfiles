return {
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                javascript = { 'prettierd', 'eslint_d' },
                typescript = { 'prettierd', 'eslint_d' },
                javascriptreact = { 'prettierd', 'eslint_d' },
                typescriptreact = { 'prettierd', 'eslint_d' },
                css = { 'prettierd' },
                html = { 'prettierd' },
                json = { 'prettierd' },
                go = { 'gofumpt', 'goimports', 'golines' },
                gomod = { 'gofumpt', 'goimports', 'golines' },
                gowork = { 'gofumpt', 'goimports', 'golines' },
                gotmpl = { 'gofumpt', 'goimports', 'golines' },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
        },

        keys = {
            {
                '<leader>mp',
                function()
                    require('conform').format({
                        lsp_fallback = true,
                        async = false,
                        timeout_ms = 1000,
                    })
                end,
                mode = { 'n', 'v' },
                desc = 'Format file or range (in visual mode)',
            },
        },
    },
}
