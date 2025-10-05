--if require("mnvimutils").auto_guard() then return end -- Cannot guard plugin files or it breaks lazyvim

local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n󰬽 Loading "..user.profile.name .." profile plugin config("..current_file..")...")


return {
		{"kdheepak/lazygit.nvim", dependencies = { "nvim-lua/plenary.nvim"}},
		{"L3MON4D3/LuaSnip", version = "v2.*" },
		{"brenton-leighton/multiple-cursors.nvim", version = "*",
			opts = {},  -- This causes the plugin setup function to be called
			keys = {
				{"<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "x"}, desc = "Add cursor and move down"},
				{"<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "x"}, desc = "Add cursor and move up"},
				{"<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move up"},
				{"<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move down"},
				{"<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = {"n", "i"}, desc = "Add or remove cursor"},
				{"<Leader>m", "<Cmd>MultipleCursorsAddVisualArea<CR>", mode = {"x"}, desc = "Add cursors to the lines of the visual area"},
				{"<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>", mode = {"n", "x"}, desc = "Add cursors to cword"},
				{"<Leader>A", "<Cmd>MultipleCursorsAddMatchesV<CR>", mode = {"n", "x"}, desc = "Add cursors to cword in previous area"},
				{"<Leader>d", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Add cursor and jump to next cword"},
				{"<Leader>D", "<Cmd>MultipleCursorsJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Jump to next cword"},
				{"<Leader>l", "<Cmd>MultipleCursorsLock<CR>", mode = {"n", "x"}, desc = "Lock virtual cursors"},
			},
		},
		{"kylechui/nvim-surround",
			version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
			event = "VeryLazy",
			config = function()
			require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
			})
			end
		},
		{"norcalli/nvim-colorizer.lua", version = "*"},
		{'NickvanDyke/opencode.nvim',
			dependencies = {
				-- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
				{ 'folke/snacks.nvim', opts = { input = { enabled = true } } },
			},
			config = function()
			-- `opencode.nvim` passes options via a global variable instead of `setup()` for faster startup
			---@type opencode.Opts
			vim.g.opencode_opts = {
			  -- Your configuration, if any — see `lua/opencode/config.lua`
			}

			-- Required for `opts.auto_reload`
			vim.opt.autoread = true

			-- Recommended keymaps
			vim.keymap.set('n', '<leader>ot', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
			vim.keymap.set('n', '<leader>oA', function() require('opencode').ask() end, { desc = 'Ask opencode' })
			vim.keymap.set('n', '<leader>oa', function() require('opencode').ask('@cursor: ') end, { desc = 'Ask opencode about this' })
			vim.keymap.set('v', '<leader>oa', function() require('opencode').ask('@selection: ') end, { desc = 'Ask opencode about selection' })
			vim.keymap.set('n', '<leader>on', function() require('opencode').command('session_new') end, { desc = 'New opencode session' })
			vim.keymap.set('n', '<leader>oy', function() require('opencode').command('messages_copy') end, { desc = 'Copy last opencode response' })
			vim.keymap.set('n', '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, { desc = 'Messages half page up' })
			vim.keymap.set('n', '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, { desc = 'Messages half page down' })
			vim.keymap.set({ 'n', 'v' }, '<leader>os', function() require('opencode').select() end, { desc = 'Select opencode prompt' })

			-- Example: keymap for custom prompt
			vim.keymap.set('n', '<leader>oe', function() require('opencode').prompt('Explain @cursor and its context') end, { desc = 'Explain this code' })
		  end,
		},
		{'nvim-telescope/telescope.nvim', tag = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' } },
		{"chentoast/marks.nvim", event = "VeryLazy", opts = {},},
		{
		  'stevearc/oil.nvim',
		  ---@module 'oil'
		  ---@type oil.SetupOpts
		  opts = {},
		  -- Optional dependencies
		  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
		  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
		  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		  lazy = false,
		},
		{
		  "mikavilpas/yazi.nvim",
		  version = "*", -- use the latest stable version
		  event = "VeryLazy",
		  dependencies = {
			{ "nvim-lua/plenary.nvim", lazy = true },
		  },
		  keys = {
			-- 👇 in this section, choose your own keymappings!
			{
			  "<leader>-",
			  mode = { "n", "v" },
			  "<cmd>Yazi<cr>",
			  desc = "Open yazi at the current file",
			},
			{
			  -- Open in the current working directory
			  "<leader>cw",
			  "<cmd>Yazi cwd<cr>",
			  desc = "Open the file manager in nvim's working directory",
			},
			{
			  "<c-up>",
			  "<cmd>Yazi toggle<cr>",
			  desc = "Resume the last yazi session",
			},
		  },
		  ---@type YaziConfig | {}
		  opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = false,
			keymaps = {
			  show_help = "<f1>",
			},
		  },
		  -- 👇 if you use `open_for_directories=true`, this is recommended
		  init = function()
			-- mark netrw as loaded so it's not loaded at all.
			--
			-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
			vim.g.loaded_netrwPlugin = 1
		  end,
		},
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
			  "nvim-lua/plenary.nvim",
			  "MunifTanjim/nui.nvim",
			  "nvim-tree/nvim-web-devicons", -- optional, but recommended
			},
			lazy = false, -- neo-tree will lazily load itself
		},
		{"lewis6991/gitsigns.nvim"},
		{"nvim-lualine/lualine.nvim"},
		{"MunifTanjim/nui.nvim"},
		{"rafamadriz/friendly-snippets"},
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
		{"mfussenegger/nvim-dap"},
		{"lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },


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

	} -- spec


