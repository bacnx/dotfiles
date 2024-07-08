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
}
