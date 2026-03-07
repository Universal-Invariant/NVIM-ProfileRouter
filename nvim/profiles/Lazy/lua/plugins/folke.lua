return
{
	-- https://github.com/folke/snacks.nvi
	{"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = { 
		    bigfile = { enabled = true },
			dashboard = { enabled = true },
			explorer = { enabled = true },
			gh = { enabled = true},
			gitbrowse = { enabled = true},
			image = { enabled = true},
			indent = { enabled = true },
			input = { enabled = true,  timeout = 3000 },
			lazygit = { enabled = true},
			notifier = { enabled = true },			
			picker = { enabled = true },			
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			toggle = { enabled = true},
			win = { enabled = true}, 
			words = { enabled = true },
			styles = {
					notification = {
					wo = { wrap = true } -- Wrap notifications
				}
			}
		},
		--[[
		opts = function(_, opts)
			local layouts = require("snacks.picker.config.layouts")
			return {
				picker = {
					layout = layouts.telescope,
					sources = {
						smart = {
							layout = layouts.ivy,
						},
						select = {
							layout = layouts.ivy,
						},
					}
				},
			}
		end
		--]]
	},
	-- https://github.com/folke/which-key.nvim
	{"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
		}
	},
	--https://github.com/folke/persistence.nvim
	{"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		opts = {
			-- add any custom options here
		}
	},

}
