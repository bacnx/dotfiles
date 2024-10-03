return {
    {
        -- TODO: improve with treesitter
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = true,
    },
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        opts = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            return {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-k>'] = cmp.mapping.select_prev_item(),
                    ['<C-j>'] = cmp.mapping.select_next_item(),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = require('cmp').config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                }, {
                    { name = 'buffer' },
                }),
            }
        end,
    },
    { 'tpope/vim-sleuth' },
}
