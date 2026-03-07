-- Guard the entire debugger setup
if vim.g.debug_require_mnvimutils then
    return
end
vim.g.debug_require_mnvimutils = true

-- wrap require to track them
if vim.g.debug_require then

    -- Store original functions and paths for restoration
    local original_require = require
    local original_package_path = package.path
    local original_package_cpath = package.cpath
    local log_requires = false -- Set to true to see successful requires too

    -- Use a consistent logger
    local pr = user.log

    -- State for the debugger
    local require_depth = 0
    local failed_cache = {}
    local lua_jit_builtins = {ffi = true, bit = true, jit = true}

    ---
    -- Gets formatted information about the calling location.
    ---
    local function get_caller_info()
        -- iterate up the stack to find the first function that isn't this debugger
        for i = 3, 10 do
            local info = debug.getinfo(i, "Sl")
            if not info then break end
            -- Skip C functions and our own debugger file (optional refinement)
            if info.source ~= "=[C]" and info.source:sub(1,1) == "@" then
                return info.source:sub(2), info.currentline
            end
        end
        return "unknown", 0
    end

    -- Overwrite the global require function
    function require(mod)
        require_depth = require_depth + 1
        local indent = string.rep("  ", require_depth - 1)

        -- Capture caller info IMMEDIATELY so we have it for errors
        local caller_file, caller_line = get_caller_info()
        local caller_desc = caller_file .. ":" .. caller_line

        -- ✅ 1. Validate input type
        if type(mod) ~= "string" then
            pr(indent .. "⚠️  require() called with non-string: " .. vim.inspect(mod))
            require_depth = require_depth - 1
            return original_require(mod)
        end

        -- ✅ 2. Check cache (Fast Path)
        if package.loaded[mod] then
            require_depth = require_depth - 1
            return package.loaded[mod]
        end

        if log_requires then
            pr(string.format("%s📥 require('%s') ← %s", indent, mod, caller_desc))
        end

        -- ✅ 3. Check failed cache
        if failed_cache[mod] then
            pr(indent .. "❌ CACHED FAIL: '" .. mod .. "' previously failed.")
            require_depth = require_depth - 1
            error(failed_cache[mod], 2)
        end

        -- ✅ 4. Attempt Load
        local ok, result = xpcall(
            function() return original_require(mod) end,
            debug.traceback
        )


        if ok then
            require_depth = require_depth - 1
            return result
        end
		
		-- Ignore certain libs that are generally not installed and clutter logs
		if string.match(tostring(mod), "mason[-]lspconfig.lsp") ~= nil then		
			--print("IGNORING "..tostring(mod))
			require_depth = require_depth - 1
			return {}
		end
		
	
        -- ❌ 5. DIAGNOSIS
        pr(string.format("%s❌ FAILED to load '%s'", indent, mod))
        failed_cache[mod] = result

        pr(indent .. "  │")
        pr(indent .. "  ├─ REQUESTED BY: " .. caller_desc)
        pr(indent .. "  ├─ Original error: " .. tostring(result):gsub("\n", "\n" .. indent .. "  │ "))

        -- ✅ 6. [NEW] Check for "Sibling/Relative" File Trap
        -- This detects if 'struct.lua' sits right next to 'serializer.lua'
        local sibling_candidate = nil
        if caller_file ~= "unknown" then
            -- Get directory of the caller
            local caller_dir = caller_file:match("(.*" .. user.path_sep .. ")") or ""
            
            -- Check for sibling file.lua or sibling/init.lua
            local check_paths = {
                caller_dir .. mod .. ".lua",
                caller_dir .. mod .. user.path_sep .. "init.lua"
            }
            
            for _, p in ipairs(check_paths) do
                if vim.fn.filereadable(p) == 1 then
                    sibling_candidate = p
                    break
                end
            end
        end

        if sibling_candidate then
            pr(indent .. "  │")
            pr(indent .. "  ├─ 🕵️ DIAGNOSIS: RELATIVE PATH ISSUE DETECTED")
            pr(indent .. "  │  The file exists at: " .. sibling_candidate)
            pr(indent .. "  │  BUT Lua does not search the caller's directory by default.")
            pr(indent .. "  │  The caller ("..caller_file:match("[^"..user.path_sep.."]+$")..") is trying to require sibling '"..mod.."'.")
            
            -- AUTO PATCH FOR SIBLINGS
            if vim.g.debug_require_auto_patch then
                pr(indent .. "  └─ 🔧 AUTO-PATCH: Adding caller directory to path and retrying...")
                local caller_dir = sibling_candidate:match("(.*" .. user.path_sep .. ")")
                
                local pre_patch_path = package.path
                package.path = caller_dir .. "?.lua;" .. caller_dir .. "?" .. user.path_sep .. "init.lua;" .. pre_patch_path
                
                local ok2, result2 = xpcall(
                    function() return original_require(mod) end,
                    debug.traceback
                )
                
                package.path = pre_patch_path -- Restore immediately

                if ok2 then
                    pr(string.format("%s✔️ AUTO-FIX SUCCESS: '%s' loaded from sibling dir.", indent, mod))
                    failed_cache[mod] = nil
                    require_depth = require_depth - 1
                    return result2
                else
                     pr(indent .. "  ❌ AUTO-FIX FAILED (Syntax error in sibling file?)")
                end
            end
        else
            -- Standard search (existing logic)
            -- ... (Include your existing search loop here if desired)
             pr(indent .. "  └─ Not found in standard paths or sibling directories.")
        end

        require_depth = require_depth - 1
        error(result, 2)
    end
end





--[[


if vim.loop.os_uname().sysname:find("Windows") then
    function user.shellPath(path)
        path = path:gsub("/", "\\")        
        if path:find(" ") then path = '"' .. path .. '"' end
        return path
    end

    function user.shellPath(path)
        -- Only sanitize if it looks like a real filesystem path
        if vim.loop.os_uname().sysname:find("Windows") then
            -- Else: leave as-is — likely a flag or non-path argument
            -- Heuristic: only convert if it's an absolute path or clearly a file path
            if path:find("^%a:[/\\]") or path:find("^[/\\]") or path:find("%.%.?[/\\]") then
                path = path:gsub("/", "\\")
                if path:find(" ") then
                    path = '"' .. path .. '"'
                end
            end
        else
            -- Unix: quote if has spaces
            if path:find(" ") then
                path = "'" .. path:gsub("'", "'\\''") .. "'"
            end
        end
        return path
    end

    -- 🛡️ Override vim.fn.system to auto-fix Windows paths in shell commands
    local original_system = vim.fn.system

    vim.fn.system = function(cmd, ...)
		user.log("vim.fn.system = "..vim.inspect(cmd))
        -- Handle both string and list forms of cmd
        if type(cmd) == "string" then
            cmd = user.shellPath(cmd) -- Fix paths in string command
        elseif type(cmd) == "table" then
            for i, arg in ipairs(cmd) do
                if type(arg) == "string" then
                    cmd[i] = user.shellPath(arg)
                end
            end
        end

        -- Execute with original system
        return original_system(cmd, ...)
    end
    user.log("✅ Overrode vim.fn.system for Windows path compatibility")


    if vim.system then
        local original_vim_system = vim.system

        vim.system = function(opts)
			user.log("vim.system = "..opts)
            if opts and opts.args and type(opts.args) == "table" then
                for i, arg in ipairs(opts.args) do
                    if type(arg) == "string" then
                        opts.args[i] = user.shellPath(arg)
                    end
                end
            end
            return original_vim_system(opts)
        end

        user.log("✅ Overrode vim.system for Windows path compatibility")
    end

    local original_spawn = vim.loop.spawn

    vim.loop.spawn = function(file, options, ...)
		user.log("vim.loop.spawn = "..vim.inspect(options))
        if type(options) == "table" and options.args then
            for i, arg in ipairs(options.args) do
                if type(arg) == "string" then
                    options.args[i] = user.shellPath(arg)
                end
            end
        end
        return original_spawn(file, options, ...)
    end

    user.log("✅ Overrode vim.loop.spawn for Windows path compatibility")
end




--]]






local M = {}
-- autoguard: use as if require("mnvimutils").auto_guard() then return end
function M.auto_guard()
    local caller_info = debug.getinfo(2, "S") -- level 2 = caller
    local filepath = caller_info.source:sub(2)

    local lua_idx = filepath:find(_jp("","lua",""))
    if lua_idx then
        filepath = filepath:sub(lua_idx + 5)
    end

    local modname = filepath:gsub("%.lua$", ""):gsub("[/\\]", "_"):gsub("%.", "_"):gsub("[^%w_]", "_")

    local guard_name = "__guard_" .. modname
	--print("Guarding "..guard_name)
	
    if vim.g[guard_name] then
        return true -- already loaded
    end
    vim.g[guard_name] = true
    return false
end

return M
