if require("mnvimutils").auto_guard() then return end
local current_file = debug.getinfo(1).source:sub(2) 
user.log("\n󰬾 Loading "..user.profile.name .." profile plugin *autocmds* config("..current_file..")...")