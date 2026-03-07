--Global Keymaps: 
-- https://neovim.io/doc/user/map.html
-- https://www.lazyvim.org/configuration/keymaps
-- https://the-pi-guy.com/blog/neovims_key_mappings_and_customizations/
--if require("mnvimutils").auto_guard() then return end
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n7 Loading "..user.profile.name .." profile plugin *keymaps* config("..current_file..")...")

local vim = vim
local o = vim.opt
local c = vim.cmd
local g = vim.g
local s = vim.keymap.set


-- Leader key
g.mapleader = ' ' -- Space as the leader key
--vim.api.nvim_set_keys('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })
--s('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })


-- Used with a batch file that allows :cq to quit and restart neovim immediately(Loops over runing nvim unless it exists normally)
--vim.api.nvim_set_keys('n', '<leader>rr', ':cq<CR>', { noremap = true, silent = true })
--s('n', '<leader>rr', ':cq<CR>', { desc = "Restart Neovim", noremap = true, silent = true })



-- remap keys
s('n', '<C-F3>', 'q', { noremap = true }) -- macros recording to Ctrl-F3
s('n', 'q', '', { noremap = true }) -- remove q


-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
s('n', 'zR', require('ufo').openAllFolds)
s('n', 'zM', require('ufo').closeAllFolds)



local status_ok, tsbuiltin = require("telescope.builtin")
if status_ok then
--s('n', '<C-p>', tsbuiltin.find_file, {})
--s('n', '<leader>fg', tsbuiltin.live_grep, {})
end



-- Glance
s('n', 'gD', '<CMD>Glance definitions<CR>')
s('n', 'gR', '<CMD>Glance references<CR>')
s('n', 'gY', '<CMD>Glance type_definitions<CR>')
s('n', 'gM', '<CMD>Glance implementations<CR>')





vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "*.lua" },
	callback = function()
		s("n", "<f5>", "<cmd><,>lua <cr><cmd>", { desc = "Run in Reaper" })
	end,
})




-- jk in insert mode is mapped to esc to go back to normal mode since jk almost never occur together
s('i', 'jk', "<ESC>")


--------------------------------------------------------------------- Dashboard
s("n", "<leader><tab>d", function() require("snacks.dashboard").open() end, { desc = "Open Dashboard" })

--------------------------------------------------------------------- Persistance
local status_ok, per = pcall(require, "persistence")
if status_ok then
	-- load the session for the current directory
	s("n", "<leader>qs", function() per.load() end)
	-- select a session to load
	s("n", "<leader>qS", function() per.select() end)
	-- load the last session
	s("n", "<leader>ql", function() per.load({ last = true }) end)
	-- stop Persistence => session won't be saved on exit
	s("n", "<leader>qd", function() pers.stop() end)
end
------------------------------------------------------------------------------------------------------------------------


vim.api.nvim_create_autocmd("TabNewEntered", {
  callback = function()
    Snacks.dashboard({ buf = 0, win = 0 })
  end,
})

s('n', '<leader>mm', function()
    Snacks.dashboard({ buf = 0, win = 0 })
  end)






-- Define the function that will be executed
local function replace_word_or_selection()
	local target_text = ""
	local mode = vim.fn.mode()

	if mode == "v" or mode == "V" or mode == "\x16" then -- '\x16' is <C-v>
		-- Get start and end positions while in visual mode
		local start_pos = vim.fn.getpos("v") -- The "other end" of the selection
		local end_pos = vim.fn.getpos(".") -- The cursor position (active end)

		-- getpos returns {bufnum, lnum, col, off}
		-- lnum is 1-based, col is 0-based byte offset
		local start_line = start_pos[2] - 1
		local start_col = start_pos[3] - 1
		local end_line = end_pos[2] - 1
		local end_col = end_pos[3] - 1

		-- Ensure indices are not negative
		start_line = math.max(0, start_line)
		start_col = math.max(0, start_col)
		end_line = math.max(0, end_line)
		end_col = math.max(0, end_col)

		-- Swap if necessary (selection made backwards - start_pos might be the end if cursor moved)
		-- getpos('v') might be the actual end if you moved cursor towards the beginning of the selection
		if start_line > end_line or (start_line == end_line and start_col > end_col) then
			local temp_line = start_line
			local temp_col = start_col
			start_line = end_line
			start_col = end_col
			end_line = temp_line
			end_col = temp_col
		end

		-- For nvim_buf_get_text, end_col should be exclusive.
		-- The selection ends *at* the character indicated by end_col.
		-- To include this character, we need the index *after* it.
		end_col = end_col + 1

		-- Use nvim_buf_get_text to get the precise text
		local lines = vim.api.nvim_buf_get_text(0, start_line, start_col, end_line, end_col, {})
		target_text = table.concat(lines, "\n")
	else
		target_text = vim.fn.expand("<cword>")
		if target_text == "" then
			print("No word under cursor")
			return
		end
	end

	if target_text == "" then
		print("No text selected")
		return
	end

	local replacement = vim.fn.input('Replace "' .. target_text .. '" with: ')
	if replacement == "" then
		print("Replacement string is empty. Cancelling replacement.")
		return
	end

	local escaped_target = vim.fn.escape(target_text, "/\\")
	local escaped_replacement = vim.fn.escape(replacement, "/\\")

	if string.find(target_text, "\n") then
		print("Warning: Multi-line replacement might not work as expected with standard :substitute.")
	end

	local cmd = string.format("%%substitute/%s/%s/g", escaped_target, escaped_replacement)
	vim.cmd(cmd)
end

s(
	"n",
	"<leader>fs",
	"",
	{ noremap = true, callback = replace_word_or_selection, desc = "Replace word under cursor or selected text" }
)
s(
	"v",
	"<leader>fs",
	"",
	{ noremap = true, callback = replace_word_or_selection, desc = "Replace selected text (from visual mode)" }
)


-- Create a Term command to be able to open buffer in terminal with ansi
-- https://github.com/neovim/neovim/issues/30415
vim.api.nvim_create_user_command("Term", function(args)
    local buf = vim.api.nvim_get_current_buf()
    local b = vim.api.nvim_create_buf(false, true)
    local chan = vim.api.nvim_open_term(b, {})
    vim.api.nvim_chan_send(chan, table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
    vim.api.nvim_win_set_buf(0, b)
end, {})





--------------------------------------------------------------------------------- haskell tools
-- ~/.config/nvim/after/ftplugin/haskell.lua
local status_ok, ht = pcall(require, "haskell-tools")
if status_ok then
	local bufnr = vim.api.nvim_get_current_buf()
	local opts = { noremap = true, silent = true, buffer = bufnr, }
	-- haskell-language-server relies heavily on codeLenses,
	-- so auto-refresh (see advanced configuration) is enabled by default
	s('n', '<space>cl', vim.lsp.codelens.run, opts)
	-- Hoogle search for the type signature of the definition under the cursor
	s('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
	-- Evaluate all code snippets
	s('n', '<space>ea', ht.lsp.buf_eval_all, opts)
	-- Toggle a GHCi repl for the current package
	s('n', '<leader>rr', ht.repl.toggle, opts)
	-- Toggle a GHCi repl for the current buffer
	s('n', '<leader>rf', function()
	  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
	end, opts)
	s('n', '<leader>rq', ht.repl.quit, opts)
end
------------------------------------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------- DAP
local status_ok, dap = pcall(require, "dap")
if status_ok then
	local dapui = require("dapui") -- Assume dapui is installed with dap
	-- Visual Studio Style Keybindings
	local opts = { noremap = true, silent = true }
	local m = {'n', 'i'}
	local open = dapui.open
	local close = dapui.close
	dap.listeners.before.attach.dapui_config = open
	dap.listeners.before.launch.dapui_config = open
	--dap.listeners.before.event_terminated.dapui_config = close
	dap.listeners.before.event_exited.dapui_config = close
	
	-- F5: Start/Continue
	s(m, '<F5>', function() open(); dap.continue() end, opts)
	-- F10: Step Over
	s(m, '<F10>', function() open();dap.step_over() end, opts)
	-- F11: Step Into
	s(m, '<F11>', function() open(); dap.step_into() end, opts)
	-- Shift + F11: Step Out
	s(m, '<S-F11>', function() open(); dap.step_out() end, opts)
	-- F9: Toggle Breakpoint
	s(m, '<F9>', function() open(); dap.toggle_breakpoint() end, opts)
	-- Ctrl + Shift + F5: Restart
	s(m, '<C-S-F5>', function() open(); dap.restart() end, opts)
	-- Shift + F5: Terminate
	s(m, '<S-F5>', function() dap.terminate() end, opts)

	s('n', '<leader>db', require("dap").toggle_breakpoint, { noremap = true })
	s('n', '<leader>dc', require("dap").continue, { noremap = true })
	s('n', '<leader>do', require("dap").step_over, { noremap = true })
	s('n', '<leader>di', require("dap").step_into, { noremap = true })

	s('n', '<leader>dl', function() require("osv").launch({port = 8086}) end, { noremap = true })
	s('n', '<leader>dw', function() local widgets = require("dap.ui.widgets") widgets.hover() end)
	s('n', '<leader>df', function() local widgets = require("dap.ui.widgets") widgets.centered_float(widgets.frames) end)
	
	
	-- Eval var under cursor
	s(m, '<space>?', function() dapui.eval(nil, {enter = true}) end)
end






------------------------------------------------------------------------------------------------------------------------




------------------ Stacks 
Snacks.toggle
	.new({
		id = "Format on Save",
		name = "Format on Save",
		get = function()
			return vim.g.autoformat
		end,
		set = function(_)
			vim.g.autoformat = not vim.g.autoformat
		end,
	})
	:map("<leader>uf")





-- Set the keymap
s("n", "<leader>gss", "<cmd>lua require('gh-fork-search').search()<cr>", { desc = "Search Fork Commits" })
s("n", "<leader>gsc", "<cmd>lua require('gh-fork-search').clear_db()<cr>", { desc = "Clear Fork Commit Cache" })