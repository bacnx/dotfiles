return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            -- hide default tab bar and use lualine tabs instead
            vim.opt.showtabline = 0

            require('lualine').setup({
                options = {
                    theme = 'auto',
                    section_separators = '',
                    component_separators = '',
                },
                sections = {
                    lualine_a = {
                        { 'windows', use_mode_colors = true },
                    },
                    lualine_b = {
                        'branch',
                        { 'diff', padding = { left = 0, right = 1 } },
                    },
                    lualine_c = {},

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
                    lualine_z = { 'location' },
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
            { '<leader>nd', ':NoiceDismiss <CR>' },
            { '<leader>nl', ':NoiceLast <CR>' },
            { '<leader>nh', ':NoiceHistory <CR>' },
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
