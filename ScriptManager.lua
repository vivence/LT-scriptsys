
local function _setfenv(fn, env)
	if nil ~= _G.setfenv then
		return _G.setfenv(fn, env)
	end
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
	return script.__id
end

local function _friendCall(self, func_name, ...)
	return self[func_name](self, ...)
end

local new = typesys.new

--[[
管理脚本对象
--]]
ScriptManager = typesys.def.ScriptManager {__super = IScriptManager,
	__pool_capacity = -1,
	__strong_pool = true,
	weak__sig_dispatcher = IScriptSigDispatcher,
	_script_map = typesys.map, -- key:script_token, value:script
	weak__active_script = Script,
}

function ScriptManager:__ctor()
	self._script_map = new(typesys.map, type(0), Script)
end

function ScriptManager:__dtor()
	
end

-- 加载制定名字（lua文件名）的脚本，并指定其API空间
function ScriptManager:loadScript(script_name, api_space)
	local script_proc_list = require(script_name)
	for i=1, #script_proc_list do
		_setfenv(script_proc_list[i], api_space)
	end
	
	local main_proc = script_proc_list[1]
	local script = new(Script, script_name, main_proc)
	local script_token = _getScriptToken(script)
	self._script_map:set(script_token, script)
	return script_token
end

-- 运行指定的脚本
function ScriptManager:runScript(script_token, ...)
	local script = self._script_map:get(script_token)
	if nil == script then
		return false
	end

	self:_runScript(script, ...)
	return true
end

-- 强制中断指定的脚本
function ScriptManager:abortScript(script_token)
	local script = self._script_map:get(script_token)
	if nil == script then
		return false
	end

	self:_abortScript(script)
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

-- 判断脚本是否在激活状态
function ScriptManager:scriptIsActive(script_token)
	local script = self._script_map:get(script_token)
	if nil == script then
		return false
	end

	return script:isActive()
end

------- [代码区段开始] 提供给ScriptAPIManager使用的函数 --------->
--[[
使指定的脚本等待信号，返回被唤醒的信号
此函数处于脚本线程运行空间内，如果因为abort被唤醒，则会触发error
导致这个函数会直接弹出调用堆栈，而_handleScriptAwakeArgs将不被调用
弹出调用堆栈时，不会执行_setActiveScript，这个逻辑是正确的
--]]
function ScriptManager:_scriptWait(sig_logic)
	return self:_sleepScript(self._active_script, sig_logic)
end
------- [代码区段结束] 提供给ScriptAPIManager使用的函数 ---------<

------- [代码区段开始] 提供给ScriptSigDispatcher使用的函数，减少运行开销 --------->
function ScriptManager:_setSigDispatcher(sig_dispatcher)
	self._sig_dispatcher = sig_dispatcher
end
function ScriptManager:_getScriptListeningSig(script_token)
	local script = self._script_map:get(script_token)
	if nil == script or not script:isRunning() then
		return nil
	end

	return script
end

function ScriptManager:_scriptOnSig(script, ...)
	self:_awakeScript(script, ...)
end
------- [代码区段结束] 提供给ScriptSigDispatcher使用的函数，减少运行开销 ---------<

------- [代码区段开始] 私有函数 --------->
function ScriptManager:_runScript(script, ...)
	assert(nil == self._active_script and nil ~= script) -- 为了不增加逻辑复杂深度，不支持嵌套

	-- 进入脚本执行环境
	self:_setActiveScript(script)
	self:_handleScriptTickResult(script, script:run(...))
end

function ScriptManager:_awakeScript(script, ...)
	assert(nil == self._active_script and nil ~= script) -- 为了不增加逻辑复杂深度，不支持嵌套

	-- 进入脚本执行环境
	self:_setActiveScript(script)
	self:_handleScriptTickResult(script, script:awake(...))
end

function ScriptManager:_sleepScript(script, ...)
	assert(self._active_script == script) -- 为了不增加逻辑复杂深度，不支持嵌套

	-- 退出脚本执行环境
	self:_unsetActiveScript(script)
	return self:_handleScriptAwakeArgs(script, script:sleep(...))
end

function ScriptManager:_abortScript(script)
	if self._active_script == script then
		self:_unsetActiveScript(script)
	end
	script:abort()
	-- 取消监听信号
	self._sig_dispatcher:_unlistenSig(_getScriptToken(script))
end

function ScriptManager:_handleScriptTickResult(script, ...)
	-- 退出脚本执行环境
	self:_unsetActiveScript(script)

	if script:isRunning() then
		-- 监听信号
		_friendCall(self._sig_dispatcher, "_listenSig", _getScriptToken(script), ...)
	else
		-- todo: 如果有必要，则记录脚本运行结果table.pack(...)
	end
end

function ScriptManager:_handleScriptAwakeArgs(script, ...)
	-- 进入脚本执行环境
	self:_setActiveScript(script)
	return ...
end

function ScriptManager:_setActiveScript(script)
	self._active_script = script
end

function ScriptManager:_unsetActiveScript(script)
	self._active_script = nil
end
------- [代码区段结束] 私有函数 ---------<


