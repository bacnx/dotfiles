local tokens = require("config.tokens")

local session_file = vim.fn.stdpath("state") .. "/startpage_session.json"

local function cwd_short()
  local cwd = vim.fn.getcwd()
  local home = vim.fn.expand("~")
  return cwd:sub(1, #home) == home and "~" .. cwd:sub(#home + 1) or cwd
end

local function recent_files()
  local cwd = vim.fn.getcwd() .. "/"
  local files = {}
  for _, path in ipairs(vim.v.oldfiles) do
    if path:sub(1, #cwd) == cwd and vim.fn.filereadable(path) == 1 then
      files[#files + 1] = path
      if #files == 10 then break end
    end
  end
  return files
end

local function save_session()
  local bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.bo[buf].buftype == "" then
        bufs[#bufs + 1] = name
      end
    end
  end
  local ok, encoded = pcall(vim.json.encode, bufs)
  if not ok then return end
  local f = io.open(session_file, "w")
  if f then
    f:write(encoded)
    f:close()
  end
end

local function restore_session()
  local f = io.open(session_file, "r")
  if not f then
    vim.notify("No saved session", vim.log.levels.INFO)
    return
  end
  local content = f:read("*a")
  f:close()
  local ok, paths = pcall(vim.json.decode, content)
  if not ok or type(paths) ~= "table" or #paths == 0 then
    vim.notify("Session is empty", vim.log.levels.INFO)
    return
  end
  for i, path in ipairs(paths) do
    if vim.fn.filereadable(path) == 1 then
      if i == 1 then
        vim.cmd.edit(path)
      else
        vim.cmd.badd(path)
      end
    end
  end
end

local header = {
  "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
  "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
  "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
  "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
  "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
  "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}

-- Font Awesome glyphs from the Nerd Font, written as escapes (see tokens.lua).
local icons = {
  folder = "\u{f07c}",
  branch = "\u{f126}",
  recent = "\u{f1da}",
}

local actions = {
  { key = "f", label = "find file" },
  { key = "g", label = "grep" },
  { key = "e", label = "explore" },
  { key = "r", label = "restore" },
  { key = "q", label = "close" },
}

local ns = vim.api.nvim_create_namespace("startpage")

local function set_highlights()
  local t = tokens.startpage
  for i, color in ipairs(t.header) do
    vim.api.nvim_set_hl(0, "StartpageHeader" .. i, { fg = color })
  end
  vim.api.nvim_set_hl(0, "StartpageTitle", { fg = tokens.text.accent, bold = true })
  vim.api.nvim_set_hl(0, "StartpageMuted", { fg = tokens.text.muted })
  vim.api.nvim_set_hl(0, "StartpageSection", { fg = t.section, bold = true })
  vim.api.nvim_set_hl(0, "StartpageKey", { fg = t.key, bold = true })
end

set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

local function git_branch()
  local out = vim.fn.systemlist({ "git", "-C", vim.fn.getcwd(), "branch", "--show-current" })
  return vim.v.shell_error == 0 and out[1] or nil
end

-- A row is a list of { text, hl } chunks. "center" rows are centred one by one;
-- "block" rows share one left edge so the file list stays aligned.
local function build_rows(files, cwd, with_header)
  local rows = {}
  local function add(align, chunks) rows[#rows + 1] = { align = align, chunks = chunks or {} } end

  if with_header then
    for i, line in ipairs(header) do
      add("center", { { line, "StartpageHeader" .. i } })
    end
    add("center")
  end

  add("center", { { icons.folder .. "  " .. vim.fn.fnamemodify(cwd, ":t"), "StartpageTitle" } })
  local where = { { cwd_short(), "StartpageMuted" } }
  local branch = git_branch()
  if branch and branch ~= "" then
    where[#where + 1] = { "   " .. icons.branch .. " " .. branch, "StartpageMuted" }
  end
  add("center", where)
  add("center")

  add("block", { { icons.recent .. "  Recent files", "StartpageSection" } })
  add("block")

  local names, dirs, name_width = {}, {}, 0
  for i, path in ipairs(files) do
    local rel = path:sub(#cwd + 2)
    names[i] = vim.fn.fnamemodify(rel, ":t")
    local dir = vim.fn.fnamemodify(rel, ":h")
    dirs[i] = dir == "." and "" or dir
    name_width = math.max(name_width, vim.fn.strdisplaywidth(names[i]))
  end

  local file_rows = {}
  for i = 1, #files do
    local pad = dirs[i] == "" and "" or (" "):rep(name_width - vim.fn.strdisplaywidth(names[i]) + 3)
    add("block", {
      { tostring(i == 10 and 0 or i), "StartpageKey" },
      { "   " .. names[i] .. pad },
      { dirs[i], "StartpageMuted" },
    })
    file_rows[i] = #rows
  end
  if #files == 0 then
    add("block", { { "No recent files in this folder", "StartpageMuted" } })
  end
  add("center")

  local bar = {}
  for i, action in ipairs(actions) do
    if i > 1 then bar[#bar + 1] = { "     " } end
    bar[#bar + 1] = { action.key, "StartpageKey" }
    bar[#bar + 1] = { " " .. action.label, "StartpageMuted" }
  end
  add("center", bar)
  add("center")

  local v = vim.version()
  add("center", { { ("nvim %d.%d.%d"):format(v.major, v.minor, v.patch), "StartpageMuted" } })

  return rows, file_rows
end

local function row_width(row)
  local w = 0
  for _, chunk in ipairs(row.chunks) do w = w + vim.fn.strdisplaywidth(chunk[1]) end
  return w
end

-- Lays the rows out in the middle of `win`. Returns the line of each file and
-- the column where every file line starts.
local function render(buf, win, files, cwd)
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

  local rows, file_rows = build_rows(files, cwd, true)
  -- Drop the logo when it does not fit, instead of clipping it.
  if vim.fn.strdisplaywidth(header[1]) > width or #rows > height then
    rows, file_rows = build_rows(files, cwd, false)
  end

  local block_width = 0
  for _, row in ipairs(rows) do
    if row.align == "block" then block_width = math.max(block_width, row_width(row)) end
  end
  local block_left = math.max(0, math.floor((width - block_width) / 2))
  local top = math.max(0, math.floor((height - #rows) / 2))

  local lines, marks = {}, {}
  for _ = 1, top do lines[#lines + 1] = "" end
  for _, row in ipairs(rows) do
    local left = row.align == "block" and block_left or math.max(0, math.floor((width - row_width(row)) / 2))
    local line = #row.chunks == 0 and "" or (" "):rep(left)
    for _, chunk in ipairs(row.chunks) do
      if chunk[2] then
        marks[#marks + 1] = { #lines, #line, #line + #chunk[1], chunk[2] }
      end
      line = line .. chunk[1]
    end
    lines[#lines + 1] = line
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end

  local file_lines = {}
  for i, r in ipairs(file_rows) do file_lines[i] = top + r end
  return file_lines, block_left
end

local function open_startpage()
  local files = recent_files()
  local cwd = vim.fn.getcwd()

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_buf(buf)

  vim.bo[buf].buftype   = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile  = false
  vim.bo[buf].filetype  = "startpage"

  -- "local" scope, like :setlocal, so the next file opened here gets the usual options back.
  for name, value in pairs({
    number = false, relativenumber = false, signcolumn = "no", foldcolumn = "0",
    statuscolumn = "", colorcolumn = "", list = false, wrap = false, spell = false,
    scrolloff = 0, sidescrolloff = 0, fillchars = "eob: ",
  }) do
    vim.api.nvim_set_option_value(name, value, { scope = "local", win = win })
  end

  local file_lines, col, selected = {}, 0, 1

  local function select(i)
    if file_lines[i] then
      selected = i
      vim.api.nvim_win_set_cursor(0, { file_lines[i], col })
    end
  end

  local function draw()
    local shown = vim.fn.win_findbuf(buf)[1]
    if not shown then return end
    file_lines, col = render(buf, shown, files, cwd)
    if vim.api.nvim_get_current_buf() == buf then select(selected) end
  end

  draw()

  local group = vim.api.nvim_create_augroup("startpage_layout", { clear = true })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, { group = group, callback = draw })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function() vim.api.nvim_del_augroup_by_id(group) end,
  })

  local map = function(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, noremap = true, silent = true })
  end

  for slot, path in ipairs(files) do
    map(tostring(slot == 10 and 0 or slot), function() vim.cmd.edit(path) end)
  end

  map("<CR>", function()
    if files[selected] then vim.cmd.edit(files[selected]) end
  end)

  -- arrows are the primary movement here; j/k stay bound as a fallback
  local function move_down() select(selected + 1) end
  local function move_up() select(selected - 1) end
  map("j", move_down)
  map("<Down>", move_down)
  map("k", move_up)
  map("<Up>", move_up)

  map("f", function() require("telescope.builtin").find_files() end)
  map("g", function() require("telescope.builtin").live_grep() end)
  map("e", function() require("telescope").extensions.file_browser.file_browser({ path = cwd }) end)
  map("r", restore_session)
  map("q", function() vim.cmd.bdelete() end)
  map("<leader>ff", "<cmd>Telescope find_files<CR>")
end

vim.api.nvim_create_autocmd("VimLeave", { callback = save_session })

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if vim.fn.argc() == 0 then
      open_startpage()
    elseif vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      -- `nvim <dir>` (television's atlas-repos runs `nvim .`): start in that dir
      -- on the start page. file_browser's netrw hijack only fires after
      -- VimEnter, and by then the current buffer is no longer the directory.
      local dir_buf = vim.api.nvim_get_current_buf()
      vim.fn.chdir(vim.fn.fnamemodify(vim.fn.argv(0), ":p"))
      open_startpage()
      if vim.api.nvim_buf_is_valid(dir_buf) then
        vim.api.nvim_buf_delete(dir_buf, { force = true })
      end
    end
  end,
})
