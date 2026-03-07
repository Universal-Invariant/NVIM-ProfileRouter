return {
	-- https://github.com/mfussenegger/nvim-dap
	{
		"mfussenegger/nvim-dap",
		dependencies = { "jbyuki/one-small-step-for-vimkind" },
		lazy = false,
		config = function() end,
	},

	-- https://github.com/igorlfs/nvim-dap-view
	{
		"igorlfs/nvim-dap-view",
		---@module 'dap-view'
		---@type dapview.Config
		opts = {},
	},
	
	--https://github.com/folke/lazydev.nvim
	{"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
		  library = {
			-- See the configuration section for more details
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		  },
		},
	},
	{"hrsh7th/nvim-cmp",
		opts = function(_, opts)
		  opts.sources = opts.sources or {}
		  table.insert(opts.sources, {
			name = "lazydev",
			group_index = 0, -- set group index to 0 to skip loading LuaLS completions
		  })
		end,
		},
	{"saghen/blink.cmp",
		opts = {
		  sources = {
			-- add lazydev to your completion providers
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
			  lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				-- make lazydev completions top priority (see `:h blink.cmp`)
				score_offset = 100,
			  },
			},
		  },
		},
	},
	--{ "folke/neodev.nvim", enabled = false },

	{ "nvim-neotest/nvim-nio" },
	{"ChristianChiarulli/neovim-codicons"},
	--https://github.com/rcarriga/nvim-dap-ui?tab=readme-ov-file
	{ "rcarriga/nvim-dap-ui", 
		dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
		keys = {
		  {
			"<leader>du",
			function()
			  require("dapui").toggle()
			end,
			silent = true,
			desc = "Toggle DapUI"
		  },
		},
		opts = {
		  icons = { expanded = "∩â¥", collapsed = "∩âÜ", circular = "∩äÉ" },
		  mappings = {
			expand = { "<CR>", "<2-LeftMouse>" },
			open = "o",
			remove = "d",
			edit = "e",
			repl = "r",
			toggle = "t",
		  },
		  layouts = {
			{
			  elements = {
				{ id = "repl", size = 0.30 },
				{ id = "console", size = 0.70 },
			  },
			  size = 0.19,
			  position = "bottom",
			},
			{
			  elements = {
				{ id = "scopes", size = 0.30 },
				{ id = "breakpoints", size = 0.20 },
				{ id = "stacks", size = 0.10 },
				{ id = "watches", size = 0.30 },
			  },
			  size = 0.20,
			  position = "right",
			},
		  },
		  controls = {
			enabled = true,
			element = "repl",
			icons = {
			  pause = "ε½æ",
			  play = "ε½ô",
			  step_into = "ε½ö",
			  step_over = "ε½û ",
			  step_out = "ε½ò",
			  step_back = "ε«Å ",
			  run_last = "ε¼╖ ",
			  terminate = "ε½ù ",
			},
		  },
		  floating = {
			max_height = 0.9,
			max_width = 0.5,
			border = vim.g.border_chars,
			mappings = {
			  close = { "q", "<Esc>" },
			},
		  },
		},
		config = function(_, opts)
		--[[
		  local icons = require("core.icons").dap
		  for name, sign in pairs(icons) do
			---@diagnostic disable-next-line: cast-local-type
			sign = type(sign) == "table" and sign or { sign }
			vim.fn.sign_define("Dap" .. name, { text = sign[1] })
		  end
		  --]]
		  require("dapui").setup(opts)
		end,
    },
	{"xubury/emmylua.nvim",
		build = "npm install && npm run compile && node ./build/prepare-version.js && node ./build/prepare.js",
	},

}

