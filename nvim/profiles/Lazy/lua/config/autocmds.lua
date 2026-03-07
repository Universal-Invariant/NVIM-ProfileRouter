if require("mnvimutils").auto_guard() then return end
local current_file = debug.getinfo(1).source:sub(2) 
user.log("\n6 Loading "..user.profile.name .." profile plugin *autocmds* config("..current_file..")...")



-- Remove trailing whitespace on write
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    command = [[%s/\s\+$//e]],
})


local diff_augroup = vim.api.nvim_create_augroup("DiffShortcuts", { clear = true })

vim.api.nvim_create_autocmd("WinEnter", {
  group = diff_augroup,
  callback = function()
    -- Check if the current window has 'diff' mode enabled
    if vim.wo.diff then
	    
      -- Save original foldmethod if not already saved
      if not vim.w.diff_original_foldmethod then
        vim.w.diff_original_foldmethod = vim.wo.foldmethod
      end

     -- Enable diff-specific settings
      vim.wo.foldmethod = "diff"
      vim.wo.foldlevel = 0
      vim.wo.scrollbind = true
      vim.wo.cursorbind = true
      vim.wo.wrap = false
      vim.wo.number = true
      vim.wo.relativenumber = false

      -- F1: Next change
      vim.keymap.set("n", "<F1>", function()
        if vim.wo.diff then vim.cmd("normal! ]c") end
      end, { buffer = 0, desc = "Next Diff Change" })

      -- F2: Previous change
      vim.keymap.set("n", "<F2>", function()
        if vim.wo.diff then vim.cmd("normal! [c") end
      end, { buffer = 0, desc = "Prev Diff Change" })

      -- F3: diffput (with confirmation)
      vim.keymap.set("n", "<F3>", function()
        if vim.wo.diff then
          local confirm = vim.fn.confirm("Push changes to other buffer?", "&Yes\n&No", 2)
          if confirm == 1 then
            vim.cmd.diffput()
            vim.cmd.diffupdate()
          end
        end
      end, { buffer = 0, desc = "Diff Put" })

      -- F4: diffget
      vim.keymap.set("n", "<F4>", function()
        if vim.wo.diff then
          vim.cmd.diffget()
          vim.cmd.diffupdate()
        end
      end, { buffer = 0, desc = "Diff Get" })

      -- F5: Refresh diff
      vim.keymap.set("n", "<F5>", function()
        if vim.wo.diff then vim.cmd.diffupdate() end
      end, { buffer = 0, desc = "Refresh Diff" })

      -- F6: Toggle all folds
      vim.keymap.set("n", "<F6>", function()
        if vim.wo.diff then
          vim.wo.foldlevel = (vim.wo.foldlevel == 0) and 99 or 0
        end
      end, { buffer = 0, desc = "Toggle All Folds" })

      -- F7: Close all other windows (focus mode)
      vim.keymap.set("n", "<F7>", function()
        if vim.wo.diff then
          vim.cmd("only")
          vim.cmd("diffthis")
        end
      end, { buffer = 0, desc = "Focus Current Diff" })

      -- F8: Turn off diff mode
      vim.keymap.set("n", "<F8>", function()
        vim.cmd("diffoff")
      end, { buffer = 0, desc = "Turn Off Diff" })


    else
      -- 4. Restore original foldmethod if leaving diff mode
      if vim.w.diff_original_foldmethod then
        vim.wo.foldmethod = vim.w.diff_original_foldmethod
        vim.w.diff_original_foldmethod = nil
      end
    end
  end,
})