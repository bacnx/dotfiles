local status, eslint = pcall(require, "eslint")
if (not status) then return end

eslint.setup({
})
