--Global Keymaps: https://www.lazyvim.org/configuration/keymaps
if require("mnvimutils").auto_guard() then return end
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n󰬾 Loading "..user.profile.name .." profile plugin *keymaps* config("..current_file..")...")

local map = vim.keymap.set

-- Leader key
vim.g.mapleader = ' ' -- Space as the leader key
--vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })
--map('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })


-- Used with a batch file that allows :cq to quit and restart neovim immediately(Loops over runing nvim unless it exists normally)
--vim.api.nvim_set_keymap('n', '<leader>rr', ':cq<CR>', { noremap = true, silent = true })
--map('n', '<leader>rr', ':cq<CR>', { desc = "Restart Neovim", noremap = true, silent = true })