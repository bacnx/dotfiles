return {
    {
        'nvim-treesitter/nvim-treesitter',
        version = false,
        build = ':TSUpdate',
        event = { 'BufReadPre', 'BufNewFile' },
        lazy = vim.fn.argc(-1) == 0,
        dependencies = {
            'windwp/nvim-ts-autotag',
        },
        opts = {
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            ensure_installed = {
                'lua',
                'cpp',
                'typescript',
                'tsx',
            },
            auto_install = true,
            autotag = { enable = true },
            context_commentstring = {
                enable = true,
                enable_autocmd = false,
            },
        },
        config = function(_, opts)
            local treesitter = require('nvim-treesitter.configs')
            treesitter.setup(opts)
        end,
    },
}
