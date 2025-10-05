if require("mnvimutils").auto_guard() then return end
local uv = vim.uv or vim.loop
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n󰬼 Loading "..user.profile.name .." profile plugin config("..current_file..")...")

local profile_dir = vim.fn.fnamemodify(current_file, ":p:h")  -- Get full path of parent directory
profile_dir = vim.fn.fnamemodify(profile_dir, ":p")  -- Normalize
local lua_dir = _jp(profile_dir,"lua")



-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"



local lazypath = _jp(user.paths.data,"lua")
user.log("lazypath = "..lazypath)
package.path = _jp(lazypath,"?","init.lua;")..package.path
package.path = _jp(lazypath,"?.lua;")..package.path
user.log("package.path = "..package.path)



-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{"LazyVim/LazyVim", version = "*", import = "lazyvim.plugins", priority = 10000, lazy = false, opts = { colorscheme = "catppuccin" } },
		{"folke/lazy.nvim", version = "*" },
		{
			"AstroNvim/AstroNvim",
			version = "^5", -- Remove version tracking to elect for nightly AstroNvim
			import = "astronvim.plugins",
			opts = { -- AstroNvim options must be set here with the `import` key
				mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
				maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
				icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
				pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
				update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
			},  
		},
		{ import = "community" },
		{ import = "plugins" },
		{ import = "plugins" },  -- This will load plugins/*.lua
	},
  
	install = { colorscheme = { "tokyonight", "astrotheme", "habamax", "gruvbox", "catppuccin", "kanagawa" } },
	checker = {
		enabled = true,
		notify = true,
		--frequency = 86400,
	},
	ui = { backdrop = 100 },
	performance = {
		rtp = {
			-- disable some rtp plugins, add more to your liking
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"zipPlugin",
			},
		},
	},	
})




local profile_luapath = _jp(user.paths.config,"profiles","Lazy","lua")
package.path = _jp(profile_luapath,"?.lua;")..package.path
package.path = _jp(profile_luapath,"?","init.lua;")..package.path

-- ✅ NOW require LazyVim (after setup)
require("lazyvim")

-- ✅ Manually load colors config (LazyVim does not load it)
require("config.colors")

user.log("✅ LazyVim loaded and auto-loading config/plugins")



