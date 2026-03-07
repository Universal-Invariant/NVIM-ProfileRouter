--if require("mnvimutils").auto_guard() then return end -- Cannot guard plugin files or it breaks lazyvim

local current_file = debug.getinfo(1).source:sub(2) -- Remove leading '@'
user.log("\n4 Loading " .. user.profile.name .. " profile plugin config(" .. current_file .. ")...")

return {
	{"nvim-lua/plenary.nvim" },
	{"nvim-tree/nvim-web-devicons"},
	{"nvim-mini/mini.icons"},
	{"hrsh7th/nvim-cmp"},
	{"Shatur/neovim-session-manager"},
	{"kdheepak/lazygit.nvim", --[[dependencies = { "nvim-lua/plenary.nvim" }--]] },
	{"nvim-mini/mini.nvim", version = "*", branch },
	{'ldelossa/litee.nvim'},
	{'ldelossa/gh.nvim'}, -- https://github.com/ldelossa/gh.nvim   https://www.youtube.com/watch?v=hhrWwYfMK1I
	{'ldelossa/nvim-ide', lazy = true},
	{'dnlhc/glance.nvim', cmd = 'Glance'},
	{'akinsho/toggleterm.nvim', version = "*", opts = {}},
	{"L3MON4D3/LuaSnip",
		version = "v2.*",
		run = "make install_jsregexp",
		build = (function()
			if user.is_windows then
				return
			end
			return "make install_jsregexp"
		end)(),
		dependencies = {
			{ "rafamadriz/friendly-snippets" },
			(function()
				if user.is_windows == 1 then
					return "rgarber11/jsregexp_windows_prebuilt"
				end
				return
			end)(),
		},
		keys = function()
			-- Disable default tab keybinding in LuaSnip for tabout
			return {}
		end,
	},
	{"brenton-leighton/multiple-cursors.nvim",
		version = "*",
		opts = {}, -- This causes the plugin setup function to be called
		keys = {
			{ "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "x" }, desc = "Add cursor and move down" },
			{ "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "x" }, desc = "Add cursor and move up" },
			{ "<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "i", "x" }, desc = "Add cursor and move up" },
			{
				"<C-Down>",
				"<Cmd>MultipleCursorsAddDown<CR>",
				mode = { "n", "i", "x" },
				desc = "Add cursor and move down",
			},
			{
				"<C-LeftMouse>",
				"<Cmd>MultipleCursorsMouseAddDelete<CR>",
				mode = { "n", "i" },
				desc = "Add or remove cursor",
			},
			{
				"<Leader>m",
				"<Cmd>MultipleCursorsAddVisualArea<CR>",
				mode = { "x" },
				desc = "Add cursors to the lines of the visual area",
			},
			{ "<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" }, desc = "Add cursors to cword" },
			{
				"<Leader>A",
				"<Cmd>MultipleCursorsAddMatchesV<CR>",
				mode = { "n", "x" },
				desc = "Add cursors to cword in previous area",
			},
			{
				"<Leader>d",
				"<Cmd>MultipleCursorsAddJumpNextMatch<CR>",
				mode = { "n", "x" },
				desc = "Add cursor and jump to next cword",
			},
			{ "<Leader>D", "<Cmd>MultipleCursorsJumpNextMatch<CR>", mode = { "n", "x" }, desc = "Jump to next cword" },
			{ "<Leader>l", "<Cmd>MultipleCursorsLock<CR>", mode = { "n", "x" }, desc = "Lock virtual cursors" },
		},
	},
	{
		"kylechui/nvim-surround",
		version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
	{"norcalli/nvim-colorizer.lua", version = "*" },
	{"NickvanDyke/opencode.nvim",
		config = function()
			-- `opencode.nvim` passes options via a global variable instead of `setup()` for faster startup
			---@type opencode.Opts
			vim.g.opencode_opts = {
				-- Your configuration, if any — see `lua/opencode/config.lua`
			}

			-- Required for `opts.auto_reload`
			vim.opt.autoread = true

			-- Recommended keymaps
			vim.keymap.set("n", "<leader>ot", function()
				require("opencode").toggle()
			end, { desc = "Toggle opencode" })
			vim.keymap.set("n", "<leader>oA", function()
				require("opencode").ask()
			end, { desc = "Ask opencode" })
			vim.keymap.set("n", "<leader>oa", function()
				require("opencode").ask("@cursor: ")
			end, { desc = "Ask opencode about this" })
			vim.keymap.set("v", "<leader>oa", function()
				require("opencode").ask("@selection: ")
			end, { desc = "Ask opencode about selection" })
			vim.keymap.set("n", "<leader>on", function()
				require("opencode").command("session_new")
			end, { desc = "New opencode session" })
			vim.keymap.set("n", "<leader>oy", function()
				require("opencode").command("messages_copy")
			end, { desc = "Copy last opencode response" })
			vim.keymap.set("n", "<S-C-u>", function()
				require("opencode").command("messages_half_page_up")
			end, { desc = "Messages half page up" })
			vim.keymap.set("n", "<S-C-d>", function()
				require("opencode").command("messages_half_page_down")
			end, { desc = "Messages half page down" })
			vim.keymap.set({ "n", "v" }, "<leader>os", function()
				require("opencode").select()
			end, { desc = "Select opencode prompt" })

			-- Example: keymap for custom prompt
			vim.keymap.set("n", "<leader>oe", function()
				require("opencode").prompt("Explain @cursor and its context")
			end, { desc = "Explain this code" })
		end,
	},

	----------------- MISC

	{"chentoast/marks.nvim", event = "VeryLazy", opts = {} },
	{"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
	},
	{"antosha417/nvim-lsp-file-operations",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-neo-tree/neo-tree.nvim", "nvim-tree/nvim-tree.lua", "simonmclean/triptych.nvim" },
		config = function() require("lsp-file-operations").setup() end,
	},
	{'simonmclean/triptych.nvim',
		dependencies = {'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'antosha417/nvim-lsp-file-operations' },
		opts = {}, -- config options here
		keys = {
			{ '<leader>-', ':Triptych<CR>' },
		},
	},
	{"mikavilpas/yazi.nvim",
		version = "*", -- use the latest stable version
		event = "VeryLazy",
		dependencies = { { "nvim-lua/plenary.nvim", "antosha417/nvim-lsp-file-operations", lazy = true }, },
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
		keymaps = {		
			open_file_in_horizontal_split = "<c-x>",
			open_file_in_vertical_split = "<c-v>",			
		},
		---@type YaziConfig | {}
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = false,
			--keymaps = { show_help = "<f1>", },
		},
		-- 👇 if you use `open_for_directories=true`, this is recommended
		init = function()
			-- mark netrw as loaded so it's not loaded at all.
			--
			-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
			vim.g.loaded_netrwPlugin = 1
		end,
	},
	{"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		--dependencies = {"nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons", },
		lazy = false, -- neo-tree will lazily load itself
	},
	{"lewis6991/gitsigns.nvim" },
	{"nvim-lualine/lualine.nvim" },
	{"MunifTanjim/nui.nvim" },
	{"rafamadriz/friendly-snippets" },
	{"norcalli/snippets.nvim" },

	{"lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	{"stevearc/conform.nvim", },
	{"alfaix/nvim-zoxide",
		--dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- will define Z[!], Zt[!], Zw[!] for :cd, :tcd, :lcd respectively
			-- set to false if you want to define different ones
			define_commands = true,
			-- path to zoxide executable; by default must be in $PATH
			path = "zoxide",
		},
	},
	-- Causes some autocmd errors at start unless lazy
	{"coffebar/neovim-project",		
		opts = {
			projects = { -- define project roots
				user.app_paths.coffebar_projectsdir1,
				user.app_paths.coffebar_projectsdir2,
			},
			picker = {
				type = "telescope", -- one of "telescope", "fzf-lua", or "snacks"
			},
		},
		init = function()
			-- enable saving the state of plugins in the session
			vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
		end,
		--dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-telescope/telescope.nvim", tag = "0.1.4" }, { "ibhagwan/fzf-lua" }, { "folke/snacks.nvim" }, { "Shatur/neovim-session-manager" }, },
		lazy = true,
		priority = 1,
	},


	{"AdeAttwood/ivy.nvim", build = "cargo build --release" },

	-- https://github.com/Mgenuit/nvim-dap-kotlin/
	{ "Mgenuit/nvim-dap-kotlin", config = true },
	{
		"tamton-aquib/keys.nvim",
		config = function()
			require("keys").setup({
				enable_on_startup = false,
				win_opts = {
					width = 25,
				},
			})
		end,
	},
	-- https://github.com/nvim-orgmode/orgmode
	--[[
	{'nvim-orgmode/orgmode',
	  event = 'VeryLazy',
	  ft = {'org'},
	  config = function()
		-- Setup orgmode
		require('orgmode').setup({
			org_agenda_files = user.app_paths.org.ws.agenda_files	,
			org_default_notes_file = user.app_paths.org.ws.notesfile',
		})
	  end,
	},--]]

	{ "pysan3/pathlib.nvim" },
	{ "nvim-neotest/nvim-nio" },
	{ "nvim-neorg/lua-utils.nvim" },

	-- https://github.com/nvim-neorg/neorg
	{"nvim-neorg/neorg",
		lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
		--dependencies = { "nvim-neorg/lua-utils.nvim", "nvim-neotest/nvim-nio", "pysan3/pathlib.nvim" },
		version = "*", -- Pin Neorg to the latest stable release
		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {},
					["core.dirman"] = {
						config = {
							workspaces = {
								-- :Neorg workspace notes
								Main = user.app_paths.neorg.ws.Main,									
								Alt = user.app_paths.neorg.ws.Alt															
							},
							index = "index.norg", -- The name of the main (root) .norg file
							default_workspace = "Main",
						},
					},
				},
			})
		end,
	},

	{"pvsfair/reactivex.nvim"},
	{"dgrbrady/nvim-docker",
		--dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "pvsfair/reactivex.nvim",	},
		config = function()
			local nvim_docker = require("nvim-docker")
			vim.keymap.set("n", "<leader>lc", nvim_docker.containers.list_containers)
		end,
	},

	{"akinsho/toggleterm.nvim", version = "*", opts = {} },

	{"crnvl96/lazydocker.nvim",
		version = "*",
		event = "VeryLazy",
		opts = {
			window = {
				settings = {
					width = 0.618, -- Percentage of screen width (0 to 1)
					height = 0.618, -- Percentage of screen height (0 to 1)
					border = "rounded", -- See ':h nvim_open_win' border options
					relative = "editor", -- See ':h nvim_open_win' relative options
				},
			},
		},
		--dependencies = {"MunifTanjim/nui.nvim", },
		config = function(_, opts) -- 1st change is here
			local map = function(keys, func, desc)
				vim.keymap.set("n", keys, func, { desc = "LazyDocker: " .. desc, silent = true })
			end
			require("lazydocker").setup(opts) -- 2nd change is here
			map("<leader>ld", ":lua LazyDocker.toggle()<CR>", "[L]azy [D]ocker interface")
		end,
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		version = "*",
		opts = { enable = true },
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},
	{"numToStr/Comment.nvim" },
	{"abecodes/tabout.nvim",
		lazy = false,
		config = function()
			require("tabout").setup({
				tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
				backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
				act_as_tab = true, -- shift content if tab out is not possible
				act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
				default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
				default_shift_tab = "<C-d>", -- reverse shift default action,
				enable_backwards = true, -- well ...
				completion = false, -- if the tabkey is used in a completion pum
				tabouts = {
					{ open = "'", close = "'" },
					{ open = '"', close = '"' },
					{ open = "`", close = "`" },
					{ open = "(", close = ")" },
					{ open = "[", close = "]" },
					{ open = "{", close = "}" },
				},
				ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
				exclude = {}, -- tabout will ignore these filetypes
			})
		end,
		--dependencies = {"nvim-treesitter/nvim-treesitter", "L3MON4D3/LuaSnip", "hrsh7th/nvim-cmp", },
		opt = true, -- Set this to true if the plugin is optional
		event = "InsertCharPre", -- Set the event to 'InsertCharPre' for better compatibility
		priority = 1000,
	},
	{"Wansmer/treesj",
		keys = { "<space>m", "<space>j", "<space>s" },
		--dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesj").setup({})
		end,
	},
	{'kevinhwang91/promise-async'},
	{'kevinhwang91/nvim-ufo'},
	{"ibhagwan/fzf-lua", opts = {}, },
	{"junegunn/fzf" },
	{"junegunn/fzf.vim" },

	{"stevearc/conform.nvim", opts = {} },
	{"SirVer/ultisnips" },
	{"NlGHT/vim-reasyntax", --[[dependencies = { "SirVer/ultisnips" }--]] },
	--{"ahmedkhalf/project.nvim", -- old
	{"DrKJeff16/project.nvim", -- https://github.com/DrKJeff16/project.nvim
		cmd = { -- Lazy-load by commands
			'Project',
			'ProjectAdd',
			'ProjectConfig',
			'ProjectDelete',
			'ProjectExportJSON',
			'ProjectImportJSON',
			'ProjectHealth',
			'ProjectHistory',
			'ProjectRecents',
			'ProjectRoot',
			'ProjectSession',
        },
		config = function()
			require("project").setup({
				manual_mode = false,
				exclude_dirs = {},
				show_hidden = true,
				silent_chdir = true,
				scope_chdir = "tab",
				datapath = vim.fn.stdpath("state"),
			})
		end,
	},
	--{"tami5/sqlite.lua" }, -- breaks telescope
	{"kkharji/sqlite.lua"},
	{"bfredl/nvim-luadev",
		-- optionally lazy-load
		keys = {
			{ "<leader>ll", "<Plug>(Luadev-RunLine)", desc = "Toggle LuaDev REPL Run-Line" },
			{ "<leader>lr", "<Plug>(Luadev-Run)", desc = "Toggle LuaDev REPL Run" },
			{ "<leader>lw", "<Plug>(Luadev-RunWord)", desc = "Toggle LuaDev REPL Run-Word" },
			{ "<leader>ls", "<cmd>Luadev<cr>", desc = "Toggle LuaDev REPL" },
		},
	},
	{"jake-stewart/multicursor.nvim",
		branch = "1.0",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			local set = vim.keymap.set

			-- Add or skip cursor above/below the main cursor.
			set({ "n", "x" }, "<up>", function()
				mc.lineAddCursor(-1)
			end)
			set({ "n", "x" }, "<down>", function()
				mc.lineAddCursor(1)
			end)
			set({ "n", "x" }, "<leader><up>", function()
				mc.lineSkipCursor(-1)
			end)
			set({ "n", "x" }, "<leader><down>", function()
				mc.lineSkipCursor(1)
			end)

			-- Add or skip adding a new cursor by matching word/selection
			set({ "n", "x" }, "<leader>n", function()
				mc.matchAddCursor(1)
			end)
			set({ "n", "x" }, "<leader>s", function()
				mc.matchSkipCursor(1)
			end)
			set({ "n", "x" }, "<leader>N", function()
				mc.matchAddCursor(-1)
			end)
			set({ "n", "x" }, "<leader>S", function()
				mc.matchSkipCursor(-1)
			end)

			-- Add and remove cursors with control + left click.
			set("n", "<c-leftmouse>", mc.handleMouse)
			set("n", "<c-leftdrag>", mc.handleMouseDrag)
			set("n", "<c-leftrelease>", mc.handleMouseRelease)

			-- Disable and enable cursors.
			set({ "n", "x" }, "<c-q>", mc.toggleCursor)

			-- Mappings defined in a keymap layer only apply when there are
			-- multiple cursors. This lets you have overlapping mappings.
			mc.addKeymapLayer(function(layerSet)
				-- Select a different cursor as the main one.
				layerSet({ "n", "x" }, "<left>", mc.prevCursor)
				layerSet({ "n", "x" }, "<right>", mc.nextCursor)

				-- Delete the main cursor.
				layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

				-- Enable and clear cursors using escape.
				layerSet("n", "<esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end)
			end)

			-- Customize how cursors look.
			local hl = vim.api.nvim_set_hl
			hl(0, "MultiCursorCursor", { reverse = true })
			hl(0, "MultiCursorVisual", { link = "Visual" })
			hl(0, "MultiCursorSign", { link = "SignColumn" })
			hl(0, "MultiCursorMatchPreview", { link = "Search" })
			hl(0, "MultiCursorDisabledCursor", { reverse = true })
			hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
			hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
		end,
	},
	{'romgrk/barbar.nvim',
		init = function() vim.g.barbar_auto_setup = false end,
		opts = {
		  -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
		  -- animation = true,
		  -- insert_at_start = true,
		  -- …etc.
		},
		version = '^1.0.0', -- optional: only update when a new 1.x version is released
	},
	{'nanozuki/tabby.nvim',
		config = function()
			-- configs...
		end,
	},
	{"vigoux/architext.nvim",
		requires = {
			-- Not required, only used to refine the language resolution
			"nvim-treesitter/nvim-treesitter"
		}
	},
	{"pwntester/octo.nvim",
	  cmd = "Octo",
	  opts = {
		-- or "fzf-lua" or "snacks" or "default"
		picker = "telescope",
		-- bare Octo command opens picker of commands
		enable_builtin = true,
	  },
	  keys = {
		{
		  "<leader>oi",
		  "<CMD>Octo issue list<CR>",
		  desc = "List GitHub Issues",
		},
		{
		  "<leader>op",
		  "<CMD>Octo pr list<CR>",
		  desc = "List GitHub PullRequests",
		},
		{
		  "<leader>od",
		  "<CMD>Octo discussion list<CR>",
		  desc = "List GitHub Discussions",
		},
		{
		  "<leader>on",
		  "<CMD>Octo notification list<CR>",
		  desc = "List GitHub Notifications",
		},
		{
		  "<leader>os",
		  function()
			require("octo.utils").create_base_search_command { include_current_repo = true }
		  end,
		  desc = "Search GitHub",
		},
	  },	
	},
} -- spec
