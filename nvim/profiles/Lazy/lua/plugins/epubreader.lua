return {
	{"CrystalDime/epub.nvim",
		opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		auto_open = false, -- Enable automatic opening of EPUBs
		output_dir = vim.fn.stdpath("cache") .. "/epub_reader", -- Default output directory (where epubs are unziped)
		data_dir = vim.fn.stdpath("data") .. "/epub_reader", -- Persistent data directory
	  },
	  config = true,
	},
}