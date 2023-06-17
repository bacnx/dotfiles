require('base')
require('maps')
require('highlights')
require('plugins')

local has = vim.fn.has
local is_linux = has "linux"
local is_mac = has "macunix"
local is_win = has "win32"
local is_wsl = has "wsl"

if is_linux == 1 then
  require('macos') -- linux has same clipboard config with macos
end
if is_mac == 1 then
  require('macos')
end
if is_win == 1 then
  require('windows')
end
if is_wsl == 1 then
  require('wsl')
end
