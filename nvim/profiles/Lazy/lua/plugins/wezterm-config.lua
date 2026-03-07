return {
	{
		-- https://github.com/willothy/wezterm.nvim/
		-- Switch tab by index using vim.v.count
		--vim.keymap.set("n", "<leader>wt", require('wezterm').switch_tab.index)		
		'willothy/wezterm.nvim',
		config = true
	},
	{
		-- https://github.com/winter-again/wezterm-config.nvim
		'winter-again/wezterm-config.nvim',
		config = function()
			-- changing this to true means the plugin will try to append
			-- $HOME/.config/wezterm' to your RTP, meaning you can more conveniently
			-- access modules in $HOME/.config/wezterm/lua/ for using with this plugin
			-- otherwise, store data where you want
			require('wezterm_config').setup({
				-- defaults:
				append_wezterm_to_rtp = false,
			})
		end
		}
	}