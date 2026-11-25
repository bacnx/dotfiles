-- Run :TSUpdate automatically after nvim-treesitter is updated
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      -- If plugin wasn't active this session, load it first
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

-- ============================================================
-- TREESITTER PARSERS
-- ============================================================
-- nvim-treesitter's main branch takes no ensure_installed / highlight / indent
-- options in setup(); install() is how to keep parsers present. It runs async
-- and skips parsers already installed. Compiling needs tree-sitter-cli and a C
-- compiler. yaml and html are for render-markdown (front matter, inline HTML).
require('nvim-treesitter').install({ 'go', 'lua', 'javascript', 'sql', 'yaml', 'html', 'c_sharp' })

-- ASP.NET files Neovim gives no filetype. An .ashx handler is C# after its
-- <%@ WebHandler %> directive line (which the C# parser marks as an error); an
-- .aspx page is mostly HTML with inline <% %> code.
vim.filetype.add({ extension = { ashx = 'cs', aspx = 'html' } })

-- ============================================================
-- TREESITTER HIGHLIGHTING (your original config, slightly improved)
-- ============================================================
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    -- Only start if a parser for this language actually exists
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start()
    end
  end,
})
