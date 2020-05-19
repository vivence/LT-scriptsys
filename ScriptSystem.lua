

local new = typesys.new

local function _friendCall(self, func_name, ...)
	return self[func_name](self, ...)
end

--[[
脚本系统，外部只需要使用此类型对象的接口即可
--]]
ScriptSystem = typesys.def.ScriptSystem {
	__pool_capacity = -1,
	__strong_pool = true,
	_api_dispatcher = IScriptAPIDispatcher,
	_script_manager = ScriptManager,
	_sig_factory = ScriptSigFactory,
	_api_manager = ScriptAPIManager,
	_sig_dispatcher = ScriptSigDispatcher,
}

function ScriptSystem:__ctor(api_dispatcher_class)
	self._api_dispatcher = new(api_dispatcher_class, self)
	self._script_manager = new(ScriptManager)
	self._sig_factory = new(ScriptSigFactory)
	self._sig_dispatcher = new(ScriptSigDispatcher)
	self._api_manager = new(ScriptAPIManager, self._api_dispatcher, self._script_manager, self._sig_factory)

	_friendCall(self._script_manager, "_setSigDispatcher", self._sig_dispatcher)
	_friendCall(self._sig_dispatcher, "_setScriptManager", self._script_manager)
end

function ScriptSystem:__dtor()
	
end

function ScriptSystem:tick(time, delta_time)
	self._api_dispatcher:tick(time, delta_time)
	self._sig_dispatcher:tick(time, delta_time)
end

-- 通过此接口注册的API，将通过API调度器进行调度管理
function ScriptSystem:registerAPI(api_map)
	self._api_manager:registerAPI(api_map)
end

-- 通过此接口注册的API，将被直接调用，请慎用
function ScriptSystem:registerAssistAPI(api_map)
	self._api_manager:registerAssistAPI(api_map)
end

-- 加载一个脚本，返回一个token
function ScriptSystem:loadScript(script_name)
	return self._script_manager:loadScript(script_name, self._api_manager:getAPISpace())
end

-- 运行指定的token所表示的脚本
function ScriptSystem:runScript(script_token)
	return self._script_manager:runScript(script_token)
end

-- 强制中断指定的token所表示的脚本
function ScriptSystem:abortScript(script_token)
	return self._script_manager:abortScript(script_token)
end

function ScriptSystem:scriptIsRunning(script_token)
	return self._script_manager:scriptIsRunning(script_token)
end

function ScriptSystem:sendSig_API(api_token)
	local sig = self._sig_factory:createSig_API(api_token)
	self._sig_dispatcher:sendSig(sig)
end

function ScriptSystem:sendSig_Event(event_name)
	local sig = self._sig_factory:createSig_Event(event_name)
	self._sig_dispatcher:sendSig(sig)
end





