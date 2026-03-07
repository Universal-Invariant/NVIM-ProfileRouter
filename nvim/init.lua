-- NVIM PROFILE ROUTER --
-- Prevent double load
if vim.g.routerinit_loaded then
	return
end
vim.g.routerinit_loaded = true
local uv = vim.uv or vim.loop
local current_file = debug.getinfo(1).source:sub(2) -- Remove leading '@'

-- Create a global user struct to handle user data
if not user then
	user = { org = { fn = {} }, env = {}, paths = {}, profile = {}, log = {}, guards = {}, app_paths = {}, options = {}, }
end
function user.fixPath(path)
	return string.gsub(vim.fn.fnamemodify(path, ":p:gs?/?\\?"), "[/\\]$", "")
end

user.is_windows = (vim.loop.os_uname().sysname:find("Windows"))
	or (jit.os == "Windows")
	or (package.config:sub(1, 1) == "\\")
user.path_sep = user.is_windows and "\\" or "/"

user.initialcd = vim.fn.getcwd() -- Store the current directory when being used




local function ensure_dir(path)
	local stat = vim.loop.fs_stat(path)
	if not stat then
		-- Recursively create directories
		vim.loop.fs_mkdir(path, 493) -- 493 = 0o755 in decimal
		user.log("Created directory: " .. path)
	end
end

-- Join elements into a path with separator
function _jp(...)
	local args = { ... }
	local sep = user.path_sep
	local r = args[1] or ""
	for i = 2, #args do
		if r[#r] == sep then
			r = r .. args[i]
		else
			r = r .. sep .. args[i]
		end
	end
	return r
end

-- Main handler for OS differences. Set paths in user.app_paths. for specific app path differences such as in dashboard, neoorg, etc. (then reference them from user.app_paths). This way there is a common place to set paths rather than having to track multiple files
if user.is_windows then
	-- Setup standard windows xdg paths(note these are setup later)
	user.env.home = vim.loop.os_homedir() or os.getenv("USERPROFILE") or "C:\\Users\\Default"
	user.env.XDG_CACHE_HOME = os.getenv("TEMP") or "C:\\Temp\\nvim"
	
	-- Setup universal app paths for multi-os usage - WINDOWS. If possible use [Common]Settings.lua
	
	-----------------------------------------------------------------
else
	-- Setup universal app paths for multi-os usage - LINUX. If possible use [Common]Settings.lua
		
	-----------------------------------------------------------------

	-- Setup standard linux xdg paths, default to user home
	user.env.home = vim.loop.os_homedir() or os.getenv("HOME") or "/home/default"
	-- Store XDG Paths to use without worry of them getting overwritten.
	-- hard coded for linux to be in /home/<user>
	user.env.XDG_CONFIG_HOME = _jp(user.env.home, ".config") -- vim.env.XDG_CONFIG_HOME
	user.env.XDG_DATA_HOME = _jp(user.env.home, ".data") --vim.env.XDG_DATA_HOME
	user.env.XDG_STATE_HOME = _jp(user.env.home, ".state") -- vim.env.XDG_STATE_HOME
	--user.env.XDG_RUNTIME_DIR = _jp(user.env.home, ".runtime") --vim.env.XDG_RUNTIME_DIR
	user.env.XDG_RUNTIME_DIR = "/run/user/1000" -- linux requires using standard runtime dir
	user.env.XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME or os.getenv("TEMP") or "/tmp/nvimtmp" -- TODO: fix path for either win32 or unix
	user.paths.router = _jp(user.env.XDG_CONFIG_HOME, "nvim")

	vim.env.XDG_CONFIG_HOME = user.env.XDG_CONFIG_HOME
	vim.env.XDG_DATA_HOME = user.env.XDG_DATA_HOME
	vim.env.XDG_STATE_HOME = user.env.XDG_STATE_HOME
	vim.env.XDG_RUNTIME_DIR = user.env.XDG_RUNTIME_DIR
	vim.env.XDG_CACHE_HOME = user.env.XDG_CACHE_HOME
	
	

end

--package.path = "" -- DEBUG: If we do not want to load other lua packages then set only for nvim

-- Enable verbose logging
vim.opt.verbose = 1
user.log.Filename = _jp(vim.env.XDG_DATA_HOME, "logs", "nvimlog.txt")
user.log.File = io.open(user.log.Filename, "w+")

user.log = setmetatable(user.log, {
	__call = function(table, ...)
		local msg = ""
		for i, v in ipairs({...}) do
			msg = msg .. tostring(v)
		end
		msg = os.date() .. ":" .. msg	
		--print(msg)
		--vim.api.nvim_echo({{msg, "Normal"}}, true, {})
		if user.log.File then
			--user.log.File:write(msg .. "\n")
		end
	end,
})


user.log(os.date() .. "---------------------------------------------------------\n󰬺 Loading router init.lua(".. current_file.. ")...")
if not user.log.File then print("User profile file log not functioning at " .. user.log.Filename) else user.log("User profile log: " .. user.log.Filename) end
user.log("TTY: " .. tostring(vim.api.nvim_call_function("has", { "tty" }))); user.log("Stdin is TTY: " .. tostring(vim.fn.filereadable("/dev/stdin"))); user.log("Env DISPLAY: " .. tostring(vim.env.DISPLAY))

-- ✅ Add Neovim's runtime Lua paths to package.path
user.log("vim.api.nvim_list_runtime_paths = " .. vim.inspect(vim.api.nvim_list_runtime_paths()))
for _, rtp in ipairs(vim.api.nvim_list_runtime_paths()) do
	local lua_path = _jp(rtp, "lua")
	-- Check if lua subdirectory exists (optional, but clean)
	if uv.fs_stat(lua_path) then
		package.path = _jp(lua_path, "?.lua;") .. package.path
		package.path = _jp(lua_path, "?", "init.lua;") .. package.path
		user.log("✅ Added Lua path: " .. lua_path)
	else
		user.log("ℹ️  Lua path not found (skipped): " .. lua_path)
	end
end

-- Add the nvim config path to be able to load lua files next to the routers init.lua
package.path = _jp(vim.env.XDG_CONFIG_HOME, "nvim", "?.lua;") .. package.path
user.log("package.path = " .. package.path)
vim.g.debug_require = true
require("mnvimutils")

user.log("\n Original XDG Paths:")
user.log("XDG_CONFIG_HOME = ".. vim.env.XDG_CONFIG_HOME	.. "\n"	.. "XDG_DATA_HOME = "	.. vim.env.XDG_DATA_HOME	.. "\n"	.. "XDG_STATE_HOME = "	.. vim.env.XDG_STATE_HOME	.. "\n"	.. "XDG_RUNTIME_DIR = "	.. vim.env.XDG_RUNTIME_DIR	.. "\n"	.. "XDG_CACHE_HOME = "	.. vim.env.XDG_CACHE_HOME)

-- Setup profile and appname
local profile_name = vim.env.NVIM_PROFILE or "Lazy"
user.profile.name = profile_name
vim.env.NVIM_APPNAME = profile_name


-- Store XDG Paths to use without worry of them getting overwritten.
user.env.XDG_CONFIG_HOME = vim.env.XDG_CONFIG_HOME
user.env.XDG_DATA_HOME = vim.env.XDG_DATA_HOME
user.env.XDG_STATE_HOME = vim.env.XDG_STATE_HOME
user.env.XDG_RUNTIME_DIR = vim.env.XDG_RUNTIME_DIR
user.env.XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME or os.getenv("TEMP") or (user.is_windows and "C:\\Temp" or "/tmp")
user.paths.router = _jp(user.env.XDG_CONFIG_HOME, "nvim")

-- Hijack vim.fn.stdpath to provide custom profile based paths
user.org.fn.stdpath = vim.fn.stdpath
vim.fn.stdpath = function(value)
	if value == "nvim" then
		return _jp(user.env.XDG_CONFIG_HOME, "nvim")
	end
	if value == "bootstrap" then
		return _jp(user.env.XDG_CONFIG_HOME, "nvim", "bootstrap")
	end
	if value == "config" then
		return _jp(user.env.XDG_CONFIG_HOME, "nvim", "profiles", profile_name)
	end
	if value == "data" then
		return _jp(user.env.XDG_DATA_HOME, "nvim", profile_name)
	end
	if value == "state" then
		return _jp(user.env.XDG_STATE_HOME, "nvim", profile_name)
	end
	if value == "run" then
		if user.is_windows then
			return _jp(user.env.XDG_RUNTIME_DIR, "nvim", profile_name)		
		end
		return user.env.XDG_RUNTIME_DIR -- linux requires using standard runtime so copy works with wayland
	end
	if value == "cache" then
		return _jp(user.env.XDG_CACHE_HOME, "nvim", profile_name)
	end
	--user.log("value = "..user.org.fn.stdpath(value))
	return user.org.fn.stdpath(value)
end

-- Set XDG custom paths to PARENT directories
local _nvim = vim.fn.stdpath("nvim")
local _bootstrap = vim.fn.stdpath("bootstrap")
local _config = vim.fn.stdpath("config")
local _data = vim.fn.stdpath("data")
local _state = vim.fn.stdpath("state")
local _run = vim.fn.stdpath("run")
local _cache = vim.fn.stdpath("cache")

user.paths.home = user.env.home 
user.paths.temp = _cache
user.paths.nvim = _nvim
user.paths.bootstrap = _bootstrap
user.paths.config = _config
user.paths.data = _data
user.paths.state = _state
user.paths.run = _run
user.paths.cache = _cache
user.paths.databases = _jp(user.paths.state, "databases")

vim.env.NVIM_APPNAME = profile_name


vim.opt.shadafile = _jp(user.paths.state, "nvim", profile_name, "main.shada")

user.log("\n Custom XDG Paths:")
user.log("XDG_CONFIG_HOME = ".. vim.env.XDG_CONFIG_HOME	.. "\n"	.. "XDG_DATA_HOME = "	.. vim.env.XDG_DATA_HOME	.. "\n"	.. "XDG_STATE_HOME = "	.. vim.env.XDG_STATE_HOME	.. "\n"	.. "XDG_RUNTIME_DIR = "	.. vim.env.XDG_RUNTIME_DIR	.. "\n"	.. "XDG_CACHE_HOME = "	.. vim.env.XDG_CACHE_HOME)
user.log("\n🚀 Requested profile: " .. profile_name)
user.log("NVIM_APPNAME = " .. (vim.env.NVIM_APPNAME or ""))
user.log("vim.env.LAZY_STDPATH = " .. (vim.env.LAZY_STDPATH or "<Not Set>"))
user.log("vim.env.LAZY_PATH = " .. (vim.env.LAZY_PATH or "<Not Set>"))
user.log("_config = " .. _config .. "\n_data = " .. _data .. "\n_state = " .. _state .. "\n_cache = " .. _cache)

-- Create the runtime\nvim\<profile> dir if necessary  (e.g., for fzf_lua)
ensure_dir(_cache)
ensure_dir(vim.env.XDG_RUNTIME_DIR)

--  Setup nvim root package path
package.path = _jp(_config, "?.lua;") .. package.path
user.log("package.path = " .. package.path)


user.log("Loading Common Settings...")
dofile(_jp(user.paths.nvim, "CommonSettings.lua"))

-- ========================
--  CHECK IF PROFILE EXISTS
-- ========================

local profile_dir = _config
local profile_init = _jp(profile_dir, "init.lua")

local bootstrap = _jp(_config, "bootstrap.lua")
local forceBS = false

if uv.fs_stat(profile_init) and not forceBS then
	user.log("✅ Profile found: " .. profile_name .. "@`" .. profile_init .. "`")
	user.paths.profile_init = profile_init
	user.paths.profile_dir = profile_dir
	dofile(profile_init)
elseif uv.fs_stat(bootstrap) then -- Bootstrap
	user.log("✅ Bootstrap found: " .. profile_name .. "@`" .. bootstrap .. "`")
	user.paths.bootstrap = bootstrap
	dofile(bootstrap)
else
	vim.api.nvim_err_writeln("❌ No profile directory or bootstrap file found for: " .. profile_name)
	vim.api.nvim_err_writeln("   Searched for:")
	vim.api.nvim_err_writeln("      Profile - " .. profile_init)
	vim.api.nvim_err_writeln("      Bootstrap - " .. bootstrap)
	vim.fn.getchar()
	os.exit(1)
end

--[[
	Notes: 
		nvim should be started with the env variable NVIM_APPNAME set to "nvim". (This gets nvim to use ...\nvim sub-directories which allows for nice organization of nvim)
		The master router init.lua file loaded by nvim is then at XDG_CONFIG_HOME\nvim\init.lua
		Profiles are in XDG_CONFIG_HOME\nvim\<profile_name>
		The profile init is in XDG_CONFIG_HOME\nvim\<profile_name>\init.lua
		
		The router routes the env variable NVIM_PROFILE to the approprate profile init.lua file and transfers control.
		A user table `user` contains informationa bout directories, profiles, and logging.
--]]

return {}
