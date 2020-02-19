
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
	__super = IScriptManager,
	weak__sig_dispatcher = IScriptSigDispatcher,
	_script_map = typesys.map, -- key:script_token, value:script
	weak__active_script = Script,
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
	self:_setActiveScript(script)
	self:_handleScriptTickResult(script, script:run(...))
end

function ScriptManager:_awakeScript(script, ...)
	self:_setActiveScript(script)
	self:_handleScriptTickResult(script, script:awake(...))
end

function ScriptManager:_sleepScript(script, ...)
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
	if self._active_script == script then
		self:_unsetActiveScript(script)
	end

	if script:isRunning() then
		-- 监听信号
		self._sig_dispatcher:_listenSig(_getScriptToken(script), ...)
	else
		-- todo: 如果有必要，则记录脚本运行结果...
	end
end

function ScriptManager:_handleScriptAwakeArgs(script, ...)
	if self._active_script ~= script then
		self:_setActiveScript(script)
	end
	return ...
end

-- 为了不增加逻辑复杂深度，_setActiveScript与_unsetActiveScript只能是成对逻辑，不支持嵌套
function ScriptManager:_setActiveScript(script)
	assert(nil == self._active_script and nil ~= script)
	self._active_script = script
end

function ScriptManager:_unsetActiveScript(script)
	assert(self._active_script == script)
	self._active_script = nil
end
------- [代码区段结束] 私有函数 ---------<


