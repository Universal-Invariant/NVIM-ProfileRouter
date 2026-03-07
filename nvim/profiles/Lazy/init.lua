-- Prevent double loading
if require("mnvimutils").auto_guard() then return end
local uv = vim.uv or vim.loop
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n1 Loading "..user.profile.name .." profile("..current_file..")...")

-- Load profile settings
dofile(_jp(user.paths.profile_dir, "Settings.lua"))

-- Now load plugin-config

local plugin_config = _jp(user.paths.profile_dir,"lua","plugin-config.lua")
package.path = _jp(user.paths.profile_dir,"lua","?.lua;").._jp(user.paths.profile_dir,"lua","?","?.lua;")..package.path
user.log("✅ Plugins config found: " .. user.profile.name.."@`"..plugin_config.."`")	
require("lua.plugin-config")
