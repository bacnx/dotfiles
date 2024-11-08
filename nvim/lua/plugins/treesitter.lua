return {
    {
        'nvim-treesitter/nvim-treesitter',
        version = false,
        build = ':TSUpdate',
        event = { 'BufReadPre', 'BufNewFile' },
        lazy = vim.fn.argc(-1) == 0,
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
                'go',
                'markdown_inline',
            },
            auto_install = true,
        },
        config = function(_, opts)
            local treesitter = require('nvim-treesitter.configs')
            treesitter.setup(opts)
        end,
    },
}
