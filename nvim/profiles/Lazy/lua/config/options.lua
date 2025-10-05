if require("mnvimutils").auto_guard() then return end
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n󰬾 Loading "..user.profile.name .." profile plugin *options* config("..current_file..")...")

-- Disable LazyVim's update checker
vim.g.lazyvim_update_check_interval = 60*60*24*7*2