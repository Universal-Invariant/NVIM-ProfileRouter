-- Prevent double loading
if require("mnvimutils").auto_guard() then return end
local uv = vim.uv or vim.loop
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n󰬻 Loading "..user.profile.name .." profile("..current_file..")...")



-- Basic settings
vim.o.number = true -- Enable line numbers
vim.o.relativenumber = false -- Enable relative line numbers
vim.o.tabstop = 4 -- Number of spaces a tab represents
vim.o.shiftwidth = 4 -- Number of spaces for each indentation
vim.o.expandtab = false -- Convert tabs to spaces
vim.o.smartindent = true -- Automatically indent new lines
vim.o.wrap = false -- Disable line wrapping
vim.o.cursorline = true -- Highlight the current line
vim.o.termguicolors = true -- Enable 24-bit RGB colors

-- Syntax highlighting and filetype plugins
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')


-- Now load plugin-config

local plugin_config = _jp(user.paths.profile_dir,"lua","plugin-config.lua")
package.path = _jp(user.paths.profile_dir,"lua","?.lua;")..package.path
user.log("✅ Plugins config found: " .. user.profile.name.."@`"..plugin_config.."`")	
require("lua.plugin-config")