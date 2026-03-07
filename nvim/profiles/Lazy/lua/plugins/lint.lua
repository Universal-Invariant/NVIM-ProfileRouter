return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
	  
		-- https://github.com/LazyVim/LazyVim/discussions/2268
		--:lua print(vim.inspect(require('lint').linters_by_ft[vim.bo.filetype]))
	     ["markdownlint-cli2"] = {
			args = { "--disable", "MD013", "MD012", "--" },
		},
        markdownlint = {
          args = { "--disable", "MD013", "MD012", "--" },
        },
      },
    },
  },
}