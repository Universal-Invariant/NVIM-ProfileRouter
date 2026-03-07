-- Global common settings(Settings shared by all profiles, else see Settings.lua in profile directory)

-- https://neovim.io/doc/user/options.html
-- Basic settings
local vim = vim
local o = vim.opt
local c = vim.cmd
local g = vim.g
local s = vim.keymap.s

o.number = true -- Enable line numbers
o.relativenumber = false -- Enable relative line numbers
o.tabstop = 4 -- Number of spaces a tab represents
o.shiftwidth = 4 -- Number of spaces for each indentation
o.expandtab = false -- Convert tabs to spaces
o.smartindent = true -- Automatically indent new lines
o.wrap = false -- Disable line wrapping
o.cursorline = true -- Highlight the current line
o.termguicolors = true -- Enable 24-bit RGB colors
o.shortmess = "ltToOCFmrwasI" -- simplify some messages
o.showtabline = 2 -- always show tabline
o.virtualedit = "onemore" -- allow moving after last char on line
o.warn = false -- no warning when buffer changed
o.autocompletedelay = 600
o.autoread = false -- autoread changed files
o.autowrite = false -- autowrite files in certain contexts
o.breakindent = true -- wraps follow previous indentations
o.clipboard = "unnamedplus"
o.encoding = "utf-8"
o.guicursor = "n-v-c:block,i:hor25-blinkon100-blinkoff75"



-- Set leader keys
g.mapleader = " "
g.maplocalleader = "\\"

-- Syntax highlighting and filetype plugins
c('syntax enable')
c('filetype plugin indent on')



g.autoformat = false -- turn off autoformatting

-- reaper-nvim settings
g.reaper_fuzzy_command = "fzf"
g.reaper_target_transport = "udp"
g.reaper_target_port = 8783
g.reaper_target_ip = "127.0.0.1"
g.reaper_browser_command = "firefox"


-- Initial code folding
o.foldcolumn = "1"
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"

o.foldlevel = 10
o.foldlevelstart = 1
o.foldnestmax = 4
o.foldenable = true

		

o.diffopt:append({
  "filler",      -- Show empty lines for deleted/added content
  "closeoff",    -- Turn off diff when one window is closed
  "algorithm:histogram",  -- Better diff algorithm (more accurate)
  "indent-heuristic",     -- Better handling of indented code
})



------------------ Paths
user.app_paths.dashboard = {}

user.app_paths.neorg = {ws = {}}
user.paths.localplugins = {}
if user.is_windows then	
	local home = user.paths.home
	user.app_paths.neorg.ws.Main = [[L:\Files\orgnotes\main]]
	user.app_paths.neorg.ws.Alt	= [[L:\Files\orgnotes\alt]]

	user.app_paths.luabin = [[L:\Programming\Lua\bin\lua.exe]]	
	user.app_paths.pythonbin = [[L:\Programming\Python\python.exe]]
	user.app_paths.local_lua_ext_path = [[L:\gh\Programming\Lua\Apps\local-lua-debugger-vscode]]   
	user.paths.localplugins.lazynvim = [[L:\gh\vim\lazy.nvim]]
	
	user.app_paths.coffebar_projectsdir1 = [[L:\gh\]]
	user.app_paths.coffebar_projectsdir2 = [[L:\Reaper_Common\lua\]]
	
	user.app_paths.dashboard.projects = "L:/gh"
	user.app_paths.dashboard.projects2 = "L:/reaper_common/lua"
	
	g.sqlite_clib_path = _jp(user.paths.nvim, "sqlite3.dll") -- install for sqlite plugins(kkharji) see https://github.com/nvim-telescope/telescope-frecency.nvim/issues/63
	
	user.gh_vim_path = [[L:\gh\vim\]]
	
else
	local home = user.paths.home
	user.app_paths.neorg.ws.Main = home..".config/ornotes/main"
	user.app_paths.neorg.ws.Alt	= home..".config/orgnotes/alt"
	
	user.app_paths.luabin = "/usr/bin/lua"
	user.app_paths.pythonbin = home.."miniforge3/bin/python3"
	user.app_paths.local_lua_ext_path = home..".vscode/extensions/tomblind.local-lua-debugger-vscode-0.3.3"	
	user.paths.localplugins.lazynvim = home.."nvim/lazy.nvim"


	user.app_paths.coffebar_projectsdir1 = home.."/projects"
	user.app_paths.coffebar_projectsdir2 = home.."/projects2"

	user.app_paths.dashboard.projects = home.."/projects"
	user.app_paths.dashboard.projects2 = home.."/projects2"

	g.sqlite_clib_path = home.."dll/nvim/sqlite3.dll"
	
	user.gh_vim_path = "/media/L/gh/vim/"

	-- Setup clipboard to work with ubuntu
	o.clipboard = "unnamed, unnamedplus"
	g.clipboard = {
		name = "wl-clipboard",
		copy = {
			["+"] = { "wl-copy", "--type", "text/plain" },
			["*"] = { "wl-copy", "--type", "text/plain" },
		},
		paste = {
			["+"] = { "wl-paste"},--, "--no-newline" },
			["*"] = { "wl-paste"},--, "--no-newline" },
		},
		cache_enabled = 1,
	}


end

g.python3_host_prog = user.app_paths.pythonbin



------------------ Extra functionality

vim.api.nvim_create_user_command('CloseFloatingWindows', function(opts)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_win_close(win, opts.bang)
    end
  end
end, { bang = true, nargs = 0 })