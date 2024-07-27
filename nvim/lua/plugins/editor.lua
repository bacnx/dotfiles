return {
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		lazy = false,
		dependencies = {
			'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
		},
		keys = {
			{
				';f',
				function()
					local builtin = require('telescope.builtin')
					builtin.find_files()
				end,
				desc = 'List file in current working directory',
			},
            {
                'sf',
                function()
                    local telescope = require('telescope')
                    local function telescope_buffer_dir()
                        return vim.fn.expand("%:p:h")
                    end

                    telescope.extensions.file_browser.file_browser({
                    path = "%:p:h",
                    cwd = telescope_buffer_dir(),
                    respect_gitignore = false,
                    hidden = true,
                    grouped = true,
                    previewer = false,
                    initial_mode = "normal",
                    layout_config = { height = 40 },
                  })
                end,
                desc = "Open File browser with the path of the current buffer",
            },
            {
                ';r',
                function()
                    local builtin = require('telescope.builtin')
                    builtin.live_grep()
                end,
                desc = 'Search for a string in your current working directory and get result live as you type'
            },
            {
                ';;',
                function()
                    local builtin = require('telescope.builtin')
                    builtin.resume()
                end,
                desc = 'Resume the previous telescope picker'
            }
		},
        opts = {
            defaults = {
                wrap_results = true,
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                file_ignore_patterns = { "node_modules" },
                winblend = 0,
                mappings = {
                    n = {},
                },
            },
        },
	},
    {
        'rmagatti/auto-session',
        dependencies = 'nvim-telescope/telescope.nvim',
        opts = {
            log_level = 'error',

            cwd_change_handling = {
                restore_upcoming_session = true,
                post_cwd_changed_hook = function()
                    require('lualine').refresh()
                end,
            },
        },
    },
    {
        'lewis6991/gitsigns.nvim',
        opts = {},
    },
    {
        'kdheepak/lazygit.nvim',
        cmd = {
            'LazyGit',
            'LazyGitConfig',
            'LazyGitCurrentFile',
            'LazyGitFilter',
            'LazyGitFilterCurrentFile',
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        keys = {
            { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
        },
    },
    {
        'christoomey/vim-tmux-navigator',
        cmd = {
            'TmuxNavigateLeft',
            'TmuxNavigateDown',
            'TmuxNavigateUp',
            'TmuxNavigateRight',
            'TmuxNavigatePrevious',
        },
        keys = {
            { '<c-h>', '<cmd><C-U>TmuxnavigateLeft<cr>'},
            { '<c-j>', '<cmd><C-U>TmuxnavigateDown<cr>'},
            { '<c-k>', '<cmd><C-U>TmuxnavigateUp<cr>'},
            { '<c-l>', '<cmd><C-U>TmuxnavigateRight<cr>'},
            { '<c-\\>', '<cmd><C-U>TmuxnavigatePrevious<cr>'},
        },
    },
    {
        'vim-test/vim-test',
        dependencies = 'preservim/vimux',
        keys = {
            { '<leader>t', ':TestNearest<CR>' },
            { '<leader>T', ':TestFile<CR>' },
            { '<leader>a', ':TestSuite<CR>' },
            { '<leader>l', ':TestLast<CR>' },
            { '<leader>g', ':TestVisit<CR>', },
        },
        config = function()
            vim.cmd 'let test#strategy = "vimux"'
        end,
    },
}
