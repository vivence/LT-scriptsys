
local function _setfenv(fn, env)
    local i = 1
    while true do
        local name = debug.getupvalue(fn, i)
        if name == "_ENV" then
            debug.upvaluejoin(fn, i, (function()
                return env
            end), 1)
            break
        elseif not name then
            break
        end
        i = i + 1
    end
    return fn
end

local function _getScriptToken(script)
	return script._id
end

local new = typesys.new

--[[
管理脚本对象
--]]
ScriptManager = typesys.ScriptManager {
	__pool_capacity = -1,
	__strong_pool = true,
	_script_map = typesys.map, -- key:script_token, value:script
}

function ScriptManager:ctor()
	self._script_map = new(typesys.map, type(0), Script)
end

function ScriptManager:dtor()
	
end

-- 加载制定名字（lua文件名）的脚本，并指定其API空间
function ScriptManager:loadScript(script_name, api_space)
	local script_proc = require(script_name)
	_setfenv(script_proc, api_space)
	local script = new(Script, script_name, script_proc)
	local script_token = _getScriptToken(script)
	self._script_map:set(script_token, script)
	return script_token
end

-- 运行指定的脚本
function ScriptManager:runScript(script_token)
	local script = self._script_map:get(script_token)
	if nil == script then
		return false
	end
	script:run()
	return true
end

-- 判断脚本是否在运行中
function ScriptManager:scriptIsRunning(script_token)
	local script = self._script_map:get(script_token)
	if nil == script then
		return false
	end

	return script:isRunning()
end




