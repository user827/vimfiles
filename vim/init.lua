-- requires net
--local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--if not vim.loop.fs_stat(lazypath) then
--  print("hello")
--  vim.fn.system({
--    "git",
--    "clone",
--    "--filter=blob:none",
--    "https://github.com/folke/lazy.nvim.git",
--    "--branch=stable", -- latest stable release
--    lazypath,
--  })
--end
--vim.opt.rtp:prepend(lazypath)
--
--local plugins = {
--  {"ellisonleao/glow.nvim", config = true, cmd = "Glow"}
--}
--
--local opts = {}
--
--require("lazy").setup(plugins, opts)

local vimrc = vim.fn.stdpath("config") .. "/vimrc"
vim.cmd.source(vimrc)
