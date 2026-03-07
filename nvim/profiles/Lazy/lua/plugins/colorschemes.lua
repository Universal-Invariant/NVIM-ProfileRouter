return
{
		------ COLOR SCHEMES ------
		{"catppuccin/nvim", name = "catppuccin", priority = 1000, tag = "v1.10.0", },
		{"ellisonleao/gruvbox.nvim", priority = 1000},
		{"rebelot/kanagawa.nvim", priority = 1000},
		{"folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {}, },
		{"rose-pine/neovim", name = "rose-pine", priority = 1000},
		{"nyoom-engineering/oxocarbon.nvim", name = "oxocarbon", priority = 1000},
		{"datsfilipe/vesper.nvim", priority = 1000},
		{"sainnhe/everforest", version = false, lazy = false, priority = 1000, config = function() end,},
		{"savq/melange-nvim", name = "melange", priority = 1000},		
		{"bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
		{"Mofiqul/vscode.nvim", priority = 1000},
		{"navarasu/onedark.nvim", priority = 1000, config = function() require('onedark').setup { style = 'darker' } require('onedark').load() end },
		{"zaldih/themery.nvim",
				lazy = false,
				config = function()
				require("themery").setup({
					-- add the config here
					themes = {"habamax", "catppuccin", "gruvbox", "kanagawa", "tokyonight", "rose-pine", "oxocarbon", "vesper", "everforest", "melange", "moonfly", "vscode", "onedark"},
					livePreview = true,
				})
				end
		},
}