return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            -- hide default tab bar and use lualine tabs instead
            vim.opt.showtabline = 0

            require('lualine').setup({
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = '',
                    section_separators = { left = '', right = '' },
                },
                sections = {
                    lualine_a = {
                        { 'mode', separator = { left = '' }, right_padding = 2 },
                    },
                    lualine_b = {
                        {
                            'branch',
                            fmt = function(str)
                                if vim.api.nvim_strwidth(str) > 20 then
                                    return ('%s..'):format(str:sub(1, 19))
                                end
                                return str
                            end,
                        },
                        { 'diff' },
                    },
                    lualine_c = { 'windows' },

                    lualine_x = {
                        'diagnostics',
                        {
                            require('noice').api.status.command.get,
                            cond = require('noice').api.status.command.has,
                            color = { fg = '#ff9e64' },
                        },
                        {
                            require('noice').api.status.mode.get,
                            cond = require('noice').api.status.mode.has,
                            color = { fg = '#ff9e64' },
                        },
                        {
                            require('noice').api.status.search.get,
                            cond = require('noice').api.status.search.has,
                            color = { fg = '#ff9e64' },
                        },
                    },
                    lualine_y = { 'progress' },
                    lualine_z = {
                        { 'location', separator = { right = '' }, left_padding = 2 },
                    },
                },
            })
        end,
    },
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify',
            'hrsh7th/nvim-cmp',
        },
        keys = {
            { '<leader>nd', ':NoiceDismiss <CR>', silent = true },
            { '<leader>nl', ':NoiceLast <CR>', silent = true },
            { '<leader>nh', ':NoiceHistory <CR>', silent = true },
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
        config = function(_, opts)
            opts.routes = opts.routes or {}
            table.insert(opts.routes, {
                filter = {
                    event = 'notify',
                    find = 'No information available',
                },
                opts = { skip = true },
            })

            require('noice').setup(opts)
            require('notify').setup({
                background_colour = '#000000',
            })
        end,
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        file_types = { 'markdown' },
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        opts = {},
    },
    {
        'folke/trouble.nvim',
        opts = {},
        cmd = 'Trouble',
        keys = {
            {
                '<leader>xx',
                '<cmd>Trouble diagnostics toggle<cr>',
                desc = 'Diagnostics (Trouble)',
            },
            {
                '<leader>xX',
                '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
                desc = 'Buffer Diagnostics (Trouble)',
            },
            {
                '<leader>cs',
                '<cmd>Trouble symbols toggle focus=false<cr>',
                desc = 'Symbols (Trouble)',
            },
            {
                '<leader>cl',
                '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
                desc = 'LSP Definitions / references / ... (Trouble)',
            },
            {
                '<leader>xL',
                '<cmd>Trouble loclist toggle<cr>',
                desc = 'Location List (Trouble)',
            },
            {
                '<leader>xQ',
                '<cmd>Trouble qflist toggle<cr>',
                desc = 'Quickfix List (Trouble)',
            },
        },
    },
}
