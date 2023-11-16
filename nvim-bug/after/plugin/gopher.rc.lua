local status, gopher = pcall(require, 'gopher')
if not status then return end

gopher.setup()
