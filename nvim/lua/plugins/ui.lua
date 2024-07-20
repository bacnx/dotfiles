return {
    -- {
    --     'akinsho/bufferline.nvim',
    --     event = 'VeryLazy',
    --     version = 'v4.5.0',
    --     dependencies = {
    --         'nvim-tree/nvim-web-devicons',
    --     },
    --     -- keys = {
    --     --     { '<Tab>', '<Cmd>BufferLineCycleNext<CR>', desc = 'Next tab' },
    --     --     { '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', desc = 'Prev tab' },
    --     -- },
    --     opts = {},
    -- },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        opts = {
            options = {
                -- theme = 'codedark',
                theme = 'onedark',
                section_separators = '',
                component_separators = '',
            },
        },
    },
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify',
            'hrsh7th/nvim-cmp',
        },
        opts = {
            lsp = {
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                lsp_doc_border = false,
            },
        },
    },
}
