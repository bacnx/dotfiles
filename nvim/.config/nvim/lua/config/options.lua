vim.opt.completeopt = "menu,menuone,noselect,popup,nearest"
vim.o.autocomplete = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function()
    vim.opt_local.autocomplete = false
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = true,
      })
    end
  end,
})

-- The cmdline gets the same treatment (:help cmdline-autocompletion): a popup
-- menu of matches opens while typing after :, / or ?. noselect keeps what was
-- typed until <Tab> or an arrow picks a match; 'wildoptions' already has pum.
vim.o.wildmode = "noselect:lastused,full"
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", "?" },
  callback = function()
    vim.fn.wildtrigger()
  end,
})
-- <Up>/<Down> close the menu and walk the cmdline history, as without it.
for _, key in ipairs({ "<Up>", "<Down>" }) do
  vim.keymap.set("c", key, function()
    return vim.fn.wildmenumode() == 1 and "<C-e>" .. key or key
  end, { expr = true })
end

-- bin/clip from this repo (symlinked to ~/.local/bin/clip) picks the backend --
-- clip.exe / win32yank on WSL, wl-copy on Wayland, xclip or xsel on X11 -- so
-- the choice is made in one place shared with .zshrc and tmux.
vim.g.clipboard = {
  name = "clip",
  copy = {
    ["+"] = "clip -i",
    ["*"] = "clip -i",
  },
  paste = {
    ["+"] = "clip -o",
    ["*"] = "clip -o",
  },
  cache_enabled = 0,
}
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = true
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.splitbelow = true
opt.splitright = true

opt.termguicolors = true
opt.cursorline = true
opt.showmode = false -- lualine already shows the mode
-- One statusline across the bottom instead of one per split; each window's
-- file name is already in its winbar (plugins/ui.lua).
opt.laststatus = 3

-- ui2 (experimental in 0.12) draws the cmdline and messages in floating
-- windows, so the row under the statusline can go: the cmdline appears only
-- while typing, and messages pop up bottom-right and fade after a few seconds
-- (g< or :messages shows them again). cmdheight must be set first: ui2 reads it
-- once, when the module loads. With no cmdline row, showcmd, the macro being
-- recorded and the search count move into lualine (see plugins/ui.lua).
opt.cmdheight = 0
opt.showcmdloc = "statusline"
require("vim._core.ui2").enable({ msg = { targets = "msg" } })
opt.showtabline = 0 -- never show the tabline; tabs still work via gt / gT

opt.undofile = true
opt.swapfile = false
opt.backup = false

opt.updatetime = 250
