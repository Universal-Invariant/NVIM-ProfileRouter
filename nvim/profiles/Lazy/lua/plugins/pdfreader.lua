--https://github.com/r-pletnev/pdfreader.nvim
return {
	{"r-pletnev/pdfreader.nvim",
	  lazy   = false,
	  dependencies = {
		"folke/snacks.nvim", -- image rendering
		"nvim-telescope/telescope.nvim", -- pickers
	  },
	  config = function()
		require("pdfreader").setup()
	  end,
	},
}
--https://github.com/franco-ruggeri/pdf-preview.nvim
--[[
return { 
    "franco-ruggeri/pdf-preview.nvim", 
    opts = {
        -- Override defaults here
    }
    config = function(_, opts)
        require("pdf-preview").setup(opts)

        -- Add your keymaps here
    end
}--]]