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
                    lualine_c = {
                        { 'tabs', use_mode_colors = true, show_modified_status = false },
                    },

                    lualine_x = {
                        {
                            function() return require('noice').api.status.mode.get() end,
                            cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
                        },
                        'diagnostics',
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
            require('noice').setup(opts)
            require('notify').setup({
                background_colour = '#000000',
            })
        end,
    },
}
