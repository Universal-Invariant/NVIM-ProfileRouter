local uv = vim.uv or vim.loop
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n0 Loading "..user.profile.name .." profile plugin config("..current_file..")...")
--load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()



user.log("vim.env.LAZY_STDPATH = "..(vim.env.LAZY_STDPATH or "<not set>"))
user.log("vim.env.LAZY_PATH = "..(vim.env.LAZY_PATH or "<not set>"))


--local lazyrepo = "https://github.com/folke/lazy.nvim.git"
local lazyrepo = "https://github.com/Universal-Invariant/NVIM-lazy.nvim.git"

local uv = vim.uv or vim.loop
if vim.env.LAZY_STDPATH then
	local root = vim.fn.fnamemodify(vim.env.LAZY_STDPATH, ":p"):gsub("[\\/]$", "")
	for _, name in ipairs({ "config", "data", "state", "cache" }) do
		vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
		user.log("lazy bs = "..vim.env[("XDG_%s_HOME"):format(name:upper())].." = "..root .. "/" .. name)
	end
	vim.env.LAZY_PATH = vim.env.LAZY_STDPATH
end

if vim.env.LAZY_PATH and not uv.fs_stat(vim.env.LAZY_PATH) then vim.env.LAZY_PATH = nil end

local lazypath = user.fixPath(vim.env.LAZY_PATH or vim.fn.stdpath("data"))
user.log("lazypath = "..lazypath)
if not vim.env.LAZY_PATH and not uv.fs_stat(lazypath) then
	user.log("Cloning lazy.nvim...")
	local ok, out = pcall(vim.fn.system, {"git", "clone", "--filter=blob:none", lazyrepo, lazypath, })
	if not ok or vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({{ "Failed to clone lazy.nvim\n", "ErrorMsg" }, { vim.trim(out or ""), "WarningMsg" }, { "\nPress any key to exit...", "MoreMsg" },}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)





