

vim.api.nvim_create_user_command('RUI', function(opts)
	vim.cmd("Lazy reload gh-fork-search")
 end, { desc = 'Reloads plugin' })
 
local gv = user.gh_vim_path

return {
	{"gh-fork-search",
		dir = user.is_windows and _jp(gv, "gh-fork-search.nvim"),	   
	},
	{"bisect-plugins",
		dir = user.is_windows and _jp(gv, "bisect-plugins.nvim"),
	},
	{"osc.nvim", -- Note, possibly copy struct.lua to packages dir for use.
		dir = user.is_windows and _jp(gv, "osc.nvim"),	   		
	},
	{"reaper-nvim",
		dir = user.is_windows and _jp(gv, "reaper.nvim"),	   		
		--dependencies = { "Universal-Invariant/NVIM-osc.nvim", "junegunn/fzf", "junegunn/fzf.vim" },
	},

}