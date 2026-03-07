------------------- TELESCOPE
-- https://github.com/orgs/nvim-telescope/repositories

local res = 
{
	{'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim', "norcalli/snippets.nvim", },
		opts = {
			["zoxide"] = {}
		},		
		config = function(_, opts)
			local t = require("telescope")
			local z_utils = require("telescope._extensions.zoxide.utils")
			local lga_actions = require("telescope-live-grep-args.actions")

			-- Configure the extension
			t.setup({
				extensions = {
					file_browser = {
						theme = "ivy",
						-- disables netrw and use telescope-file-browser in its place
						hijack_netrw = true,
						mappings = {
							["i"] = {
							-- your custom insert mode mappings
							},
							["n"] = {
							-- your custom normal mode mappings
							},
						},
					},
					zoxide = {
					  prompt_title = "[ ZOXIDE ]",
					  mappings = {
						default = {
						  after_action = function(selection)
							print("Update to (" .. selection.z_score .. ") " .. selection.path)
						  end
						},
						["<C-s>"] = {
						  before_action = function(selection) print("before C-s") end,
						  action = function(selection)
							vim.cmd.edit(selection.path)
						  end
						},
						["<C-q>"] = { action = z_utils.create_basic_command("split") },
					  },
					},
					live_grep_args = {
						auto_quoting = true, -- enable/disable auto-quoting
						-- define mappings, e.g.
						mappings = { -- extend mappings
							i = {
								["<C-k>"] = lga_actions.quote_prompt(),
								["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
								-- freeze the current list and start a fuzzy search in the frozen list
								["<C-space>"] = lga_actions.to_fuzzy_refine,
							},
						},
					},
					["ui-select"] = {
						require("telescope.themes").get_dropdown {
							-- even more opts
						}
					},
					media_files = {
						-- filetypes whitelist
						filetypes = { "png", "webp", "jpg", "jpeg", "webm", "pdf", "gif", "djvu" },
						-- find command (defaults to `fd`)
						find_cmd = "rg"
					},
				}, -- extensions
			}) -- setup

			-- Load extensions
			t.load_extension('zoxide')
			t.load_extension('project')
			t.load_extension('dap')
			t.load_extension('fzf')
			t.load_extension("frecency")
			t.load_extension("ui-select")
			t.load_extension("live_grep_args")
			t.load_extension('media_files')
			t.load_extension('gh')
			t.load_extension('smart_history') -- BUG: https://github.com/nvim-telescope/telescope-smart-history.nvim/issues/4 (make sure :lua require("sqlite.tbl") works)
			t.load_extension('snippets')
			t.load_extension("arecibo")
			t.load_extension("vimspector")

			-- Add mappings
			vim.keymap.set("n", "<leader>cd", t.extensions.zoxide.list)
			vim.keymap.set("n", "<space>fb", ":Telescope file_browser<CR>")
		end,
	},
	{"nvim-telescope/telescope-file-browser.nvim", dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }},
	{'jvgrootveld/telescope-zoxide', dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }, config = function() end, },
	{"nvim-telescope/telescope-frecency.nvim", version = "*", config = function() end, },
	{"nvim-telescope/telescope-dap.nvim"},
	{'nvim-telescope/telescope-ui-select.nvim'},
	{"nvim-telescope/telescope-live-grep-args.nvim"},
	{'nvim-telescope/telescope-symbols.nvim'},
	{"nvim-telescope/telescope-github.nvim"},
	{"nvim-telescope/telescope-smart-history.nvim"},
	{"nvim-telescope/telescope-snippets.nvim"},
	{"nvim-telescope/telescope-media-files.nvim"},
	{"nvim-telescope/telescope-arecibo.nvim"},
	{"nvim-telescope/telescope-vimspector.nvim"},



}


if user.is_windows then
	table.insert(res, {'nvim-telescope/telescope-fzf-native.nvim', build = "make", dependencies = {'nvim-telescope/telescope.nvim', "nvim-tree/nvim-web-devicons"}, config = function() end, })
	table.insert(res, {'nvim-telescope/telescope-project.nvim', build = "make", dependencies = { 'nvim-telescope/telescope.nvim' }, config = function() end, })
else
	table.insert(res, {'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install' })
	table.insert(res, {'nvim-telescope/telescope-project.nvim', dependencies = { 'nvim-telescope/telescope.nvim' }, config = function() end, })
end


return res
