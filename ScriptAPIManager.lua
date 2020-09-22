
local _LOG_ON = false

local print = print
local assert = assert

local new = typesys.new

local function _friendCall(self, func_name, ...)
	return self[func_name](self, ...)
end

------- [代码区段开始] API代理 --------->

local _api_proxy_mt = {
	__call = function(proxy, ...)
		-- return api_token
		return _friendCall(proxy.api_manager, "_callAPI", proxy.api_name, proxy.api_info, ...)
	end
}

local _built_in_api_proxy_mt = {
	__call = function(proxy, ...)
		return proxy.api(proxy.api_manager, ...)
	end
}

------- [代码区段结束] API代理 ---------<

local _built_in_apis = {} -- 在代码最后面会填充此表格

--[[
管理注册的api接口，负责对其调用进行包装

脚本使用的方式有：
1. 调用API，返回API访问器：						xxx(...) 							-- return api_token
2. API访问器的使用：	 
	1. 查询是否在未执行状态：					apiIsPending(api_token)				-- return true or false
	2. 查询是否在执行状态：						apiIsExecuting(api_token)			-- return true or false
	3. 查询是否在结束状态：						apiIsDead(api_token)				-- return true or false
	4. 查询是否因打断而结束：					apiDiedOfInterruption(api_token)	-- return true or false
	5. 获取调用结果：							apiGetReturn(api_token)  			-- return result or nil
	6. 查询调用经过了多少时间：					apiGetTimeSpent(api_token)  		-- return time_spent or -1
	7. 等待完成（time_out不为正数则无限等待）：	apiWait(api_token, time_out) 		-- return not_time_out
	8. 强制打断：								apiAbort(api_token) 				-- return nil
3. 延迟时间：									delay(time)							-- return nil
4. 等待条件：									waitCondition(condition, time_out)	-- return not_time_out
5. 等待事件逻辑：								waitEvent(expression, time_out)	-- return not_time_out

组合使用方式举例：
apiWait(xxx(...), time_out)
--]]
ScriptAPIManager = typesys.def.ScriptAPIManager{
	__pool_capacity = -1,
	__strong_pool = true,
	_api_proxy_map = typesys.__unmanaged,
	_script_api_space = typesys.__unmanaged,
	weak__api_dispatcher = IScriptAPIDispatcher,
	weak__script_manager = IScriptManager,
	weak__sig_factory = ScriptSigFactory,
	_forbid_post_api = false,
	_waiting_sig_logic_map = typesys.map,
}

function ScriptAPIManager:__ctor(api_dispatcher, script_manager, sig_factory)
	self._api_proxy_map = {}
	self._script_api_space = setmetatable({}, 
		{__index = self._api_proxy_map, __newindex = function() error("read only") end})

	self._api_dispatcher = api_dispatcher
	self._script_manager = script_manager
	self._sig_factory = sig_factory
	self._waiting_sig_logic_map = new(typesys.map, type(0), IScriptSigLogic)

	self:_registerBuiltInAPI()
end

function ScriptAPIManager:getAPISpace()
	return self._script_api_space
end

-- 通过此接口注册的API，将通过API调度器进行调度管理
function ScriptAPIManager:registerAPI(api_map)
	local api_proxy_map = self._api_proxy_map

	for api_name, api_info in pairs(api_map) do
		assert(nil == _built_in_apis[api_name]) -- 禁止使用内建api名
		api_proxy_map[api_name] = setmetatable({api_manager = self, api_name = api_name, api_info = api_info}, _api_proxy_mt)
	end
end

-- 通过此接口注册的API，将被直接调用，请慎用
--[[
api_map创建方式示例：
local AssistAPI = {}
function AssistAPI.xxx()

end
function AssistAPI.yyy()
	
end
--]]
function ScriptAPIManager:registerAssistAPI(api_map)
	local api_proxy_map = self._api_proxy_map

	for api_name, api in pairs(api_map) do
		assert(nil == _built_in_apis[api_name]) -- 禁止使用内建api名
		if "function" == type(api) then
			api_proxy_map[api_name] = api
		end
	end
end

function ScriptAPIManager:_registerBuiltInAPI()
	local api_proxy_map = self._api_proxy_map

	for api_name, api in pairs(_built_in_apis) do
		api_proxy_map[api_name] = setmetatable({api_manager = self, api = api}, _built_in_api_proxy_mt)
	end
end

-- return api_token
function ScriptAPIManager:_callAPI(api_name, api_info, ... )
	assert(not self._forbid_post_api)
	return self._api_dispatcher:postAPI(api_name, api_info, ...)
end

------- [代码区段开始] 内建API --------->
-- 内建API必须要以_built_in_作为前缀，以便注册时能够遍历到
function ScriptAPIManager:_built_in_apiIsPending(api_token)
	return self._api_dispatcher:apiIsPending(api_token)
end
function ScriptAPIManager:_built_in_apiIsExecuting(api_token)
	return self._api_dispatcher:apiIsExecuting(api_token)
end
function ScriptAPIManager:_built_in_apiIsDead(api_token)
	return self._api_dispatcher:apiIsDead(api_token)
end
function ScriptAPIManager:_built_in_apiDiedOfInterruption(api_token)
	return self._api_dispatcher:apiDiedOfInterruption(api_token)
end
function ScriptAPIManager:_built_in_apiGetReturn(api_token)
	return self._api_dispatcher:apiGetReturn(api_token)
end
function ScriptAPIManager:_built_in_apiGetTimeSpent(api_token)
	return self._api_dispatcher:apiGetTimeSpent(api_token)
end
function ScriptAPIManager:_built_in_apiWait(api_token, time_out)
	-- 检查api状态
	if self._api_dispatcher:apiIsDead(api_token) then
		return true -- not_time_out
	end

	-- 使脚本等待api信号
	return self:_waitSig(SSL_API, self._api_dispatcher, api_token, time_out)
end
function ScriptAPIManager:_built_in_apiAbort(api_token)
	self._api_dispatcher:apiAbort(api_token)
end
function ScriptAPIManager:_built_in_delay(time)
	-- 使脚本等待计时信号
	return self:_waitSig(SSL_Timing, time)
end
function ScriptAPIManager:_built_in_waitCondition(condition, time_out)
	-- 检查条件，同时还要验证条件里没有调用过“投递式API”（postAPI）
	self._forbid_post_api = true
	local condition_ret = condition()
	self._forbid_post_api = false

	if condition_ret then
		return true -- not_time_out
	end

	-- 使脚本等待条件信号
	return self:_waitSig(SSL_Condition, condition, time_out)
end

local function _transExp(sig_factory, expression)
	return string.gsub(expression, "%$([%w_]+)", function (event_name)
		return string.format("sigs_set:containKey('%s')", sig_factory:createSig_Event(event_name))
	end)
end
--[[
构建事件逻辑（expression为字符串）return event_logic_func
事件名在expression中必须以‘$’字符作为起始，后面只能跟字母、数字和下划线，匹配模式为"%$([%w_]+)"
--]]
function _createEventLogic(sig_factory, expression)
	return loadstring(string.format("local sigs_set=...; return (%s)", _transExp(sig_factory, expression)))
end
function ScriptAPIManager:_built_in_waitEvent(expression, time_out)
	-- 使脚本等待事件信号
	local event_logic_func = _createEventLogic(self._sig_factory, expression)
	return self:_waitSig(SSL_Event, event_logic_func, time_out)
end

-- 注册内建API
for k, v in pairs(ScriptAPIManager) do
	if "function" == type(v) then
		local api_name = k:match("^_built_in_(.+)")
		if api_name then
			if _LOG_ON then
				print("[ScriptAPIManager] 内建API:", api_name)
			end
			_built_in_apis[api_name] = v
		end
	end
end
------- [代码区段结束] 内建API ---------<

function ScriptAPIManager:_waitSig(sig_logic_class, ...)
	local waiting_sig_logic = new(sig_logic_class, self._sig_factory, ...)
	self._waiting_sig_logic_map:set(waiting_sig_logic.__id, waiting_sig_logic)
	_friendCall(self._script_manager, "_scriptWait", waiting_sig_logic)

	-- 返回的sig_logic和等待的是同一个
	local is_time_out = waiting_sig_logic.is_time_out
	self._waiting_sig_logic_map:set(waiting_sig_logic.__id, nil)
	return not is_time_out
end

