if require("mnvimutils").auto_guard() then return end
local uv = vim.uv or vim.loop
local current_file = debug.getinfo(1).source:sub(2)  -- Remove leading '@'
user.log("\n2 Loading "..user.profile.name .." profile plugin config("..current_file..")...")

local profile_dir = vim.fn.fnamemodify(current_file, ":p:h")  -- Get full path of parent directory
profile_dir = vim.fn.fnamemodify(profile_dir, ":p")  -- Normalize
local lua_dir = _jp(profile_dir,"lua")


local lazypath = _jp(user.paths.data,"lua")
user.log("lazypath = "..lazypath)
package.path = _jp(lazypath,"?","init.lua;")..package.path
package.path = _jp(lazypath,"?.lua;")..package.path
user.log("package.path = "..package.path)

user.log("Setting up disable/bisection for plugins")
dofile([[L:\gh\vim\bisect-plugins.nvim\lua\prolog.lua]])


-- Bootstrap lazy if it doesn't exist.
xpcall(function()
    require("lazy") -- Note, this will cache the failure preventing future calls from working.
	user.log("Lazy module found!")
end, function()
    user.log("Lazy module not found, trying bootstrap")
	require("bootstrap")	
	-- require("lazy") fails when not found so the bootstrap fails the first time. But it will work the next time it is ran
	package.loaded["lazy"] = nil		
end)


-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {"LazyVim/LazyVim", version = "*", import = "lazyvim.plugins", priority = 10000, lazy = false, opts = { colorscheme = "catppuccin" } },
    --{"folke/lazy.nvim", version = "*" },
	-- Use our custom lazy.nvim. Note that the dir that nvim uses is different then the local repo used to edit files but the lua files are links through a junction on the lua\lazy dir. One should be careful because removing nvim lazy will remove those files too. Making the dir read only may or may not help.
	-- Ideally we wouldn't need to repos but since we also use it on linux and Lazy.nvim stores all the plugins in it's repo it is better to keep things separate.
	{"Universal-Invariant/NVIM-lazy.nvim", 
		version = "*",
	    name = "lazy.nvim",
	}, 		
    { import = "plugins" },  -- This will load plugins/*.lua
  },
  install = { colorscheme = { "tokyonight", "habamax", "gruvbox", "catppuccin", "kanagawa" } },
  checker = {
    enabled = true,
    notify = true,
	--frequency = 86400,
  },
})

local profile_luapath = _jp(user.paths.config,"profiles","Lazy","lua")
package.path = _jp(profile_luapath,"?.lua;")..package.path
package.path = _jp(profile_luapath,"?","init.lua;")..package.path

-- ✅ NOW require LazyVim (after setup)
require("lazyvim")

-- ✅ Manually load colors config (LazyVim does not load it)
require("config.colors")

user.log("✅ LazyVim loaded and auto-loading config/plugins")


---------------------------- Various plugin setups ---------------------------
-- override require locally so we can check for plugin existing and run setup on it if it doesn't
local rrequire = require
local require = function(module_name)
    local status, mod = pcall(rrequire, module_name)	
	local override = false
	if user and user.options and user.options.gobal_setup_override then override = user.options.gobal_setup_override end
    if not override and status then
        return mod
    else
		user.log("Warning: Module '" .. module_name .. "' not found.", vim.log.levels.WARN)        
		-- Create useless routing
		local n = {}
		local nt = {
			__index = function(_, key) return function() end end,
			__call = function(_, ...) return function() end end,
			__newindex = function(_, key, value) end,
		}
		setmetatable(n, nt)			

        local m = {}
		local mt = {
			__index = function(_, key) return n	end,			
			__call = function(_, ...) return n end,
			__newindex = function(_, key, value) end,
		}
		setmetatable(m, mt)
		return m
    end
end

local rexists = function(module_name) local status, _ = pcall(rrequire, module_name) local override = false; if user and user.options and user.options.gobal_setup_override then override = user.options.gobal_setup_override end; return not override and status end

---------------------------------------------------------------
-------


require("noice").setup({
  views = {
    cmdline_popup = {
      position = "center",
      size = {
        width = "60%",
        height = "auto",
      },
    },
  },
  routes = {
    {
      filter = {
        event = "cmdline",
      },
      view = "cmdline_popup",
    },
  },
})



--[[
require('tabnine').setup({
  disable_auto_comment=true,
  accept_keymap="<Tab>",
  dismiss_keymap = "<C-]>",
  debounce_ms = 800,
  suggestion_color = {gui = "#808080", cterm = 244},
  exclude_filetypes = {"TelescopePrompt", "NvimTree"},
  log_file_path = nil, -- absolute path to Tabnine log file
  ignore_certificate_errors = false,
  -- workspace_folders = {
  --   paths = { "/your/project" },
  --   get_paths = function()
  --       return { "/your/project" }
  --   end,
  -- },
})
--]]


require("oil").setup({
	default_file_explorer = true
})

-- note this breaks neovim by causing a huge amount of lag.
--require('mini.animate').setup()


-- NVIM DAP
--https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#lua
local dap = require("dap")
if rexists("dap") then
	require("dapui").setup()
	require("lazydev").setup({library = { "nvim-dap-ui" },})


	dap.set_log_level("DEBUG")

	-- LUA DAP Adapters

	dap.adapters.nlua = function(callback, config)
	  callback({ 
		type = 'server', 
		host = config.host or "127.0.0.1", 
		port = config.port or 8086 
		})
	end

	--local emmylua = require("emmylua")
	--dap.adapters.lua = emmylua.get_attach_adapter() -- should be emmylua?

	dap.adapters.emmylua = {
	  type = 'executable',
	  command = [[L:\programming\lua\bin\emmylua_dap.exe]],  
	  args = {}
	  --args = { [[C:\Apps\XDG\.data\nvim\Lazy\lazy\emmylua.nvim\out\debugger\EmmyDebugAdapter.js]] },  
	   --options = { detached = false }
	}


	dap.adapters.luapanda = {
	  type = 'executable',
	  command = 'node',
	  args = { 
		-- Adjust the version number/path to match your installation
		[[C:\Users\Main\.vscode\extensions\stuartwang.luapanda-3.3.1\out\debug\debugAdapter.js]] 
	  },
	}


	dap.adapters["local-lua"] = {
	  type = "executable",
	  command = "node",  
	  args = { _jp(user.app_paths.local_lua_ext_path, "extension", "debugAdapter.js") },  
	}


	-- LUA DAP Configurations
	dap.configurations.lua = {}

	--[[
	dap.configurations.lua = { 
	  { 
	  name = "Attach to running Neovim instance",
		type = 'nlua', 
		request = 'attach',    
		host = "127.0.0.1", -- Where the server is running
		port = 8086,        -- Standard port for LoadDebug/Tom Blind's adapter: 8086. For LoadDebug: 8818
	  }
	}
	--]]

	--[[
	table.insert(dap.configurations.lua, {
	  name = "Launch(LLD)",
	  type = "local-lua",
	  request = "launch",
	  cwd = "${workspaceFolder}",
	  program = {
		lua = user.app_paths.luabin,
		file = "${file}",
	  },
	  args = {},  
	  extensionPath = user.app_paths.local_lua_ext_path,
	})
	--]]

	--[[
	table.insert(dap.configurations.lua, {
			name = "Attach EmmyLua process",
			type = "emmylua",
			codePaths = { "${workspaceFolder}" },
			cwd = "${workspaceFolder}",
			request = "attach",
			pid = function() return require("dap.utils").pick_process({filter="lua.exe"}) end,
			ext = { ".lua" },    
	})--]]

	--[[
	table.insert(dap.configurations.lua, {
			name = "Attach EmmyLua process",
			type = "emmylua",
			codePaths = { "${workspaceFolder}" },
			request = "launch",
			host = "localhost",
			port = 9966,
			ext = { ".lua" },
			codePaths = { "${workspaceFolder}" },
			cwd = "${workspaceFolder}",
			sourcePaths = {
				--vim.fn.getcwd(), -- Current project root
				"L:\\Programming\\misc_code", -- Explicit path to your test script
			},
	})
	--]]


	--[[
	table.insert(dap.configurations.lua, {
		name = "Attach Lua Script (LLDebug)",
		type = "local-lua",
		request = "attach",	
		host = "127.0.0.1", -- Where the server is running
		--port = 8086,        -- Standard port for LoadDebug/Tom Blind's adapter: 8086. For LoadDebug: 8818
		cwd = "${workspaceFolder}",
	})
	--]]


	table.insert(dap.configurations.lua, {
		type = 'luapanda',
		request = 'launch',
		name = 'LuaPanda Connect',
		cwd = "${workspaceFolder}",
		luaFileExtension = "lua",
		connectionPort = 8818, -- LuaPanda default port
		pathCaseSensitivity = true,
		stopOnEntry = true, -- Very helpful to see if it's working
		useCHook = false,   -- Set to false since you had issues with C symbols  
	})
end






require("ivy").setup()


require('lspconfig').harper_ls.setup({
  settings = {
    ["harper-ls"] = {
		ignore_filetypes = {"lua"},
		userDictPath = "",
		workspaceDictPath = "",
		fileDictPath = "",
		linters = {
			SpellCheck = true,
			SpelledNumbers = false,
			AnA = true,
			SentenceCapitalization = true,
			UnclosedQuotes = true,
			WrongQuotes = false,
			LongSentences = true,
			RepeatedWords = true,
			Spaces = true,
			Matcher = true,
			CorrectNumberSuffix = true
		},
		codeActions = {
			ForceStable = false
		},
		markdown = {
			IgnoreLinkTitle = false
		},
		diagnosticSeverity = "hint",
		isolateEnglish = false,
		dialect = "American",
		maxFileLength = 120000,
		ignoredLintsPath = "",
    }
  }
})




require("toggleterm").setup({})





require('coq-lsp').setup()

require("fzf-lua").setup({
	keymap = {
		fzf = {
			-- use cltr-q to select all items and convert to quickfix list
			["ctrl-q"] = "select-all+accept",
		},
	},
})


-- reaper-nvim setup
-- Settings are in [Common]Settings.lua
require("reaper-nvim").setup()


-- osc and reaper-nvim setup
--[[
local osc = require('osc').new{
  transport = 'udp',
  sendAddr = '127.0.0.1',
  sendPort = 8783,
}

local message = osc.new_message{
  address = '/test',
  types = 'ifs',
  1, 2, 'hello from nvim!'
}

local ok, err = osc:send(message)
if not ok then
  print(err)
end
--]]




require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
})




--require('telescope').load_extension('projects')
--require('telescope').extensions.projects.projects({})




require("telescope").setup {
  defaults = {
    wrap_results = true,
    history = {
      path = _jp(user.paths.databases, 'telescope_history.sqlite3'),
      limit = 1000
    }
  }
}





-- https://github.com/ldelossa/nvim-ide
if rexists("ide") then

	-- default components
	local bufferlist      = require('ide.components.bufferlist')
	local explorer        = require('ide.components.explorer')
	local outline         = require('ide.components.outline')
	local callhierarchy   = require('ide.components.callhierarchy')
	local timeline        = require('ide.components.timeline')
	local terminal        = require('ide.components.terminal')
	local terminalbrowser = require('ide.components.terminal.terminalbrowser')
	local changes         = require('ide.components.changes')
	local commits         = require('ide.components.commits')
	local branches        = require('ide.components.branches')
	local bookmarks       = require('ide.components.bookmarks')

	require('ide').setup({
		-- The global icon set to use.
		-- values: "nerd", "codicon", "default"
		icon_set = "nerd",
		-- Set the log level for nvim-ide's log. Log can be accessed with 
		-- 'Workspace OpenLog'. Values are 'debug', 'warn', 'info', 'error'
		log_level = "error",
		-- Component specific configurations and default config overrides.
		components = {
			-- The global keymap is applied to all Components before construction.
			-- It allows common keymaps such as "hide" to be overridden, without having
			-- to make an override entry for all Components.
			--
			-- If a more specific keymap override is defined for a specific Component
			-- this takes precedence.
			global_keymaps = {
				-- example, change all Component's hide keymap to "h"
				-- hide = h
			},
			-- example, prefer "x" for hide only for Explorer component.
			-- Explorer = {
			--     keymaps = {
			--         hide = "x",
			--     }
			-- }
		},
		-- default panel groups to display on left and right.
		panels = {
			left = "explorer",
			right = "git",
			bottom = "bottom",
		},
		-- panels defined by groups of components, user is free to redefine the defaults
		-- and/or add additional.
		panel_groups = {
			explorer = { outline.Name, bufferlist.Name, explorer.Name, bookmarks.Name, callhierarchy.Name, terminalbrowser.Name },
			terminal = { terminal.Name },
			git = { changes.Name, commits.Name, timeline.Name, branches.Name },
			bottom = { bookmarks.Name },
		},
		-- workspaces config
		workspaces = {
			-- which panels to open by default, one of: 'left', 'right', 'both', 'none'
			auto_open = 'none',
		},
		-- default panel sizes for the different positions
		panel_sizes = {
			left = 40,
			right = 40,
			bottom = 15
		}
	})
end

--require('yazi').config()

require("mason").setup()

-- 2. Initialize Mason-LSPConfig with my servers
require('mason-lspconfig').setup({
    ensure_installed = {
        'lua_ls',
        'tailwindcss',
        'volar',
        'ts_ls',
        'rust_analyzer',
        'gopls',
        'clangd',
        'jdtls',
    },
    automatic_enable = true, -- Mason-LSPConfig v2 auto-enables servers by default
})



require("gh-fork-search").setup({
	cache_results = true, -- Enable caching
	fetch_details = true,
	max_forks = 500,
	total_commits = 1000,
})











----------------- lua line config --------------------

-- Filesize formatter with commas and units
local function filesize()
  local file_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
  if file_size < 0 then return '--' end
  
  local units = { 'B', 'KB', 'MB', 'GB', 'TB' }
  local unit_index = 1
  local size = file_size
  
  while size >= 1024 and unit_index < #units do
    size = size / 1024
    unit_index = unit_index + 1
  end
  
  local formatted
  if unit_index == 1 then
    formatted = string.format('%d', size):reverse():gsub('%d%d%d', '%1,'):reverse():gsub('^,', '')
  else
    local int_part = math.floor(size)
    local dec_part = math.floor((size - int_part) * 10 + 0.5)
    local int_formatted = string.format('%d', int_part):reverse():gsub('%d%d%d', '%1,'):reverse():gsub('^,', '')
    formatted = string.format('%s.%d', int_formatted, dec_part)
  end
  
  return formatted .. ' ' .. units[unit_index]
end

-- LSP Status - Returns STRING only
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  
  if #clients == 0 then
    return '⚙ LSP Off'
  end
  
  local lsp_names = {}
  for _, client in ipairs(clients) do
    table.insert(lsp_names, client.name)
  end
  
  if #lsp_names > 2 then
    return string.format('⚙ LSP (%d)', #lsp_names)
  else
    return '⚙ LSP: ' .. table.concat(lsp_names, ', ')
  end
end

-- Function to show LSP toggle menu
local function show_lsp_menu()
  local bufnr = vim.api.nvim_get_current_buf()
  local active_clients = vim.lsp.get_clients({ bufnr = bufnr })
  local active_names = {}
  for _, client in ipairs(active_clients) do
    active_names[client.name] = true
  end
  
  local all_servers = {}
  local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
  if mason_registry_ok then
    for _, pkg in ipairs(mason_registry.get_installed_packages()) do
      if pkg:is_installed() then
        table.insert(all_servers, pkg.name)
      end
    end
  end
  
  if #all_servers == 0 then
    for name in pairs(active_names) do
      table.insert(all_servers, name)
    end
  end
  
  local menu_items = {}
  for _, server in ipairs(all_servers) do
    local is_active = active_names[server] or false
    local icon = is_active and '✅' or '⚪'
    table.insert(menu_items, {
      server = server,
      active = is_active,
      display = string.format('%s %s', icon, server),
    })
  end
  
  vim.ui.select(menu_items, {
    prompt = 'LSP Servers (Select to Toggle)',
    format_item = function(item)
      return item.display
    end,
  }, function(choice)
    if choice then
      local server_name = choice.server
      local is_active = choice.active
      
      if is_active then
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = server_name })
        for _, client in ipairs(clients) do
          vim.lsp.stop_client(client.id, true)
        end
        vim.notify(string.format('Disabled LSP: %s', server_name), vim.log.levels.INFO)
      else
        local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
        if lspconfig_ok then
          local server_config = lspconfig[server_name]
          if server_config then
            server_config.setup {}
            vim.notify(string.format('Enabled LSP: %s', server_name), vim.log.levels.INFO)
          else
            vim.notify(string.format('No config found for: %s', server_name), vim.log.levels.WARN)
          end
        else
          vim.notify('lspconfig not available.', vim.log.levels.ERROR)
        end
      end
      require('lualine').refresh({ force = true })
    end
  end)
end

-- Vim diff mode indicator - Returns STRING only (no table!)
local function vim_diff_mode()
  if vim.wo.diff then
    return '📊 DIFF'  -- Plain string, NOT a table
  end
  return ''
end

-- Define custom highlights
vim.api.nvim_set_hl(0, 'LualineDiffMode', { fg = '#FF9900', bg = '#2C2C2C', bold = true })
vim.api.nvim_set_hl(0, 'LualineLSP', { fg = '#61AFEF', bold = true })
vim.api.nvim_set_hl(0, 'LualineFilesize', { fg = '#98C379' })


require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'Filetype',
        'CursorMoved',
        'ModeChanged',
      },
    },
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str) return str:sub(1, 1) end,
        padding = { left = 1, right = 1 }
      }
    },
    lualine_b = {
      {
        'branch',
        icon = '📍',
      },
      {
        'diff',
        symbols = { added = '+', modified = '~', removed = '-' },
        diff_color = {
          added = 'DiffAdd',
          modified = 'DiffChange',
          removed = 'DiffDelete',
        },
      },
      { vim_diff_mode, padding = { left = 1, right = 1 }, color = { fg = '#FF9900', gui = 'bold' } },
      {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        symbols = { error = '✗', warn = '⚠', info = 'ℹ', hint = '💡' },
      }
    },
    lualine_c = {
	{ filesize, padding = { left = 1, right = 1 } },
      {
        'filename',
        file_status = true,
        path = 1,
        symbols = {
          modified = '[+]',
          readonly = '[-]',
          unnamed = '[No Name]',
        }
      }
    },
    lualine_x = {
      {
        'encoding',
        fmt = function(str) return str:upper() end
      },
 {
        lsp_status,
        color = { fg = '#61AFEF', gui = 'bold' },
        on_click = function()
          show_lsp_menu()
        end,
      },
      {
        'fileformat',
        symbols = {
         unix = '',
          dos = '',
          mac = '',        
        }
      },
      {
        'filetype',
        icon_only = false,
        colored = true,
      }
    },
    lualine_y = { 'progress' },
    lualine_z = {
      {
        'location',
        padding = { left = 1, right = 1 }
      }
    }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { 
	'aerial',
	'assistant',
	'avante',
	'chadtree',
	'ctrlspace',
	'fern',
	'fugitive',
	'fzf',
	'lazy',
	'man',
	'mason',
	'mundo',
	'neo-tree',
	'nerdtree',
	'nvim-dap-ui',
	'nvim-tree',
	'oil',
	'overseer',
	'quickfix',
	'symbols-outline',
	'toggleterm',
	'trouble',
	},
})
