return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            require('catppuccin').setup({
                transparent_background = true,
            })
            vim.cmd.colorscheme "catppuccin"
        end,
    },
    -- {
    --     'olimorris/onedarkpro.nvim',
    --     priority = 1000,
    --     opts = {
    --         options = {
    --             cursorline = true,
    --             transparency = true,
    --         },
    --         styles = {
    --             comments = 'italic',
    --             keywords = 'bold,italic',
    --         },
    --     },
    --     config = function(_, opts)
    --         require('onedarkpro').setup(opts)
    --         vim.cmd.colorscheme('onedark')
    --     end,
    -- },
    -- {
    --     "craftzdog/solarized-osaka.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     opts = {
    --         transparent = true,
    --         styles = {
    --             sidebars = "transparent",
    --             -- floats = "transparent",
    --         },
    --     },
    --     config = function(_, opts)
    --         require("solarized-osaka").setup(opts)
    --         vim.cmd.colorscheme("solarized-osaka")
    --     end,
    -- },
}
