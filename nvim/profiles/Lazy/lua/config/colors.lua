if require("mnvimutils").auto_guard() then return end
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n5 Loading "..user.profile.name .." profile plugin *colors* config("..current_file..")...")


vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#5c6370" })
