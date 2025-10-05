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
	local log_requires = false

    -- Use a consistent logger (assuming user.log exists)
    local pr = user.log

    -- State for the debugger
    local require_depth = 0
    local failed_cache = {}
    local lua_jit_builtins = {ffi = true, bit = true, jit = true}

    ---
    -- Gets formatted information about the calling location.
    -- @return string The formatted caller location (e.g., "path/to/file.lua:42").
    ---
    local function get_caller_info()
        -- Level 3 is correct: 1=getinfo, 2=our wrapper, 3=the actual caller
        local info = debug.getinfo(3, "Sl")
        if not info or not info.source then
            return "unknown"
        end

        local src, line = info.source, info.currentline
        if src == "=[C]" then
            return "[C]"
        elseif src:sub(1, 1) == "@" then
            return src:sub(2) .. ":" .. line
        end
        return src .. ":" .. line
    end

    -- Overwrite the global require function
    function require(mod)
        require_depth = require_depth + 1
        local indent = string.rep("  ", require_depth - 1)

        -- ✅ 1. Validate input type
        if type(mod) ~= "string" then
            pr(indent .. "⚠️  require() called with non-string:", vim.inspect(mod))
            require_depth = require_depth - 1
            return original_require(mod) -- Let the original function handle the error
        end

        -- ✅ 2. Check if the module is already loaded (fast path)
        if package.loaded[mod] then
            --pr(string.format("%s✅ USING CACHE for '%s'", indent, mod))
            require_depth = require_depth - 1
            return package.loaded[mod]
        end

		if log_requires then
			pr(string.format("%s📥 require('%s') ← from %s%s", indent, mod, get_caller_info(), ((lua_jit_builtins[mod] or false) and jit) and " ⚙️ BUILT-IN (LuaJIT)" or ""))
		end

        -- ✅ 4. Check our cache for previously failed modules to avoid repeated disk I/O
        if failed_cache[mod] then
            pr(indent .. "❌ CACHED FAIL: Previously failed to load '" .. mod .. "'. Re-throwing original error.")
            require_depth = require_depth - 1
            error(failed_cache[mod], 2)
        end

        -- ✅ 5. Attempt to load using the original `require`
        local ok, result =
            xpcall(
            function()
                return original_require(mod)
            end,
            debug.traceback
        )

        if ok then
            --pr(string.format("%s✔️ SUCCESS: '%s' loaded", indent, mod))
            require_depth = require_depth - 1
            return result
        end

        -- ❌ If we're here, the original require failed. Let's diagnose.
        pr(string.format("%s❌ FAILED to load '%s'. Starting diagnosis...", indent, mod))
        failed_cache[mod] = result -- Cache the error to speed up subsequent failures

        -- ✅ 6. [NEW] Display the most critical information: what Lua actually searched for
        pr(indent .. "  │")
        pr(indent .. "  ├─ Original error: " .. tostring(result):gsub("\n", "\n" .. indent .. "  │ "))
        pr(indent .. "  ├─ Lua Search Path (`package.path`):")
        for path in string.gmatch(package.path, "([^;]+)") do
            pr(indent .. "  │   " .. path)
        end
        pr(indent .. "  ├─ C Search Path (`package.cpath`):")
        for path in string.gmatch(package.cpath, "([^;]+)") do
            pr(indent .. "  │   " .. path)
        end
        pr(indent .. "  └────────────────")

        -- ✅ 7. [IMPROVED] Search common locations to provide a helpful hint
        local mod_as_path = mod:gsub("%.", "\\")
        local candidate_file = nil
        local seen_roots = {}
        local possible_roots = {
            vim.fn.stdpath("config"),
            vim.fn.stdpath("data"),
            _jp(vim.fn.stdpath("data"),"lazy") -- For lazy.nvim
        }

        for _, root_path in ipairs(possible_roots) do
            if not seen_roots[root_path] then
                local lua_root = _jp(root_path,"lua")
                local try_paths = {
                    _jp(lua_root, mod_as_path, ".lua"), -- Check for file.lua
                    _jp(lua_root, mod_as_path, "init.lua") -- Check for file/init.lua
                }
                for _, p in ipairs(try_paths) do
                    if vim.fn.filereadable(p) == 1 then
                        candidate_file = p
                        break
                    end
                end
                if candidate_file then
                    break
                end
                seen_roots[root_path] = true
            end
        end

        if candidate_file then
            pr(indent .. "💡 HINT: Module file found on disk but not in a searchable path: " .. candidate_file)
            local suggested_path = (candidate_file:match("(.*\\lua)\\.*") or "")

            -- ✅ 8. [IMPROVED] Auto-patch and retry
            if vim.g.debug_require_auto_patch then
                local dir_to_add = candidate_file:match("(.+)\\[^\\]+$")
                pr(indent .. "🔧 AUTO-PATCH: Temporarily adding path and retrying...")
                pr(indent .. "  > " .. dir_to_add)

                local pre_patch_path = package.path
                package.path = _jp(dir_to_add,"?.lua;",dir_to_add,"?","init.lua;")..pre_patch_path

                local ok2, result2 =
                    xpcall(
                    function()
                        return original_require(mod)
                    end,
                    debug.traceback
                )

                package.path = pre_patch_path -- CRITICAL: Restore path immediately

                if ok2 then
                    pr(string.format("%s✔️ AUTO-FIX SUCCESS: '%s' loaded after patching path.", indent, mod))
                    failed_cache[mod] = nil -- It's no longer a failed module
                    require_depth = require_depth - 1
                    return result2
                else
                    pr(indent .. "❌ AUTO-FIX FAILED. The issue may be a syntax error inside the module.")
                end
            else
                pr(
                    string.format(
                        "%s💡 SUGGESTION: Add `package.path = package.path .. ';%s\\?.lua;%s\\?\\init.lua'` to your config.",
                        indent,
                        suggested_path,
                        suggested_path
                    )
                )
            end
        else
            pr(indent .. "❌ NOT FOUND: Module " .. mod .. " file could not be located in common Neovim directories.")
        end

        -- ✅ 9. Re-throw the original error to maintain normal program flow and stack trace
        require_depth = require_depth - 1
        error(result, 2)
    end

    ---
    -- Restores the original global require function and paths.
    ---
    function _G.disable_require_debugger()
        if _G.require == require then
            _G.require = original_require
            package.path = original_package_path
            package.cpath = original_package_cpath
            pr("🐞 Custom `require` debugger disabled. Originals restored.")
        else
            pr("⚠️  Could not disable `require` debugger: another script may have overwritten it.")
        end
    end

    pr("🐞 Custom `require` debugger is active.")
    if vim.g.debug_require_auto_patch then
        pr("⚡ Auto-patching of `package.path` is enabled.")
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
	--print("Gaurding "..guard_name)
	
    if vim.g[guard_name] then
        return true -- already loaded
    end
    vim.g[guard_name] = true
    return false
end

return M
