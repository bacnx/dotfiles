-- vim-test dispatches into a tmux pane via vimux
vim.g["test#strategy"] = "vimux"

-- vim-test's gotest runs the whole package for TestFile (`go test ./dir/...`),
-- since go test has no per-file mode. Go buffers instead get `-run` limited to
-- the top-level tests declared in the file, against that one package.
local function go_test_file()
  local file = vim.fn.expand("%:.")
  if not file:match("_test%.go$") then
    local alt = file:gsub("%.go$", "_test.go")
    if vim.fn.filereadable(alt) == 0 then
      return vim.cmd("TestFile")
    end
    file = alt
  end

  local names = {}
  for _, line in ipairs(vim.fn.readfile(file)) do
    local name = line:match("^func%s+([%w_]+)%s*%(")
    if name and (name:match("^Test") or name:match("^Example") or name:match("^Fuzz")) then
      table.insert(names, name)
    end
  end
  if #names == 0 then
    return vim.notify("No tests in " .. file, vim.log.levels.WARN)
  end

  local dir = vim.fn.fnamemodify(file, ":h")
  if not dir:match("^/") then
    dir = "./" .. dir
  end
  -- keep :TestVisit working, since this bypasses test#run
  local line = file == vim.fn.expand("%:.") and vim.fn.line(".") or 1
  vim.g["test#last_position"] = { file = file, line = line, col = 1 }
  vim.fn["test#execute"]("go#gotest", {
    "-run " .. vim.fn.shellescape("^(" .. table.concat(names, "|") .. ")$"),
    dir,
  })
end

local map = vim.keymap.set

map("n", "<leader>tt", "<cmd>TestNearest<CR>", { silent = true, desc = "Test nearest" })
map("n", "<leader>tf", function()
  if vim.bo.filetype == "go" then
    go_test_file()
  else
    vim.cmd("TestFile")
  end
end, { silent = true, desc = "Test file" })
map("n", "<leader>ta", "<cmd>TestSuite<CR>", { silent = true, desc = "Test suite" })
map("n", "<leader>tl", "<cmd>TestLast<CR>", { silent = true, desc = "Test last" })
map("n", "<leader>tg", "<cmd>TestVisit<CR>", { silent = true, desc = "Visit last test file" })
