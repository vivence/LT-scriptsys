
local function _log(...) print("[ScriptAPIManager]", ...) end
local assert = assert

local new = typesys.new
local delete = typesys.delete

------- [代码区段开始] API代理 --------->

local _api_proxy_mt = {
	__call = function(proxy, ...)
		-- return api_token
		return proxy.api_manager:_callAPI(proxy.api_name, proxy.api_info, ...)
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
	6. 查询调用经过了多少时间：					apiGetTimeSpent(api_token)  		-- return time spent
	7. 等待完成（time_out不为正数则无限等待）：	apiWait(api_token, time_out) 		-- return not_time_out
	8. 强制打断：								apiAbort(api_token) 				-- return nil
3. 延迟时间：									delay(time)							-- return nil
4. 等待条件：									waitCondition(condition, time_out)	-- return not_time_out
5. 等待事件逻辑：								waitEvent(event_logic, time_out)	-- return not_time_out

组合使用方式举例：
apiWait(xxx(...), time_out)
--]]
ScriptAPIManager = typesys.ScriptAPIManager{
	__pool_capacity = -1,
	__strong_pool = true,
	_api_proxy_map = typesys.unmanaged,
	_script_api_space = typesys.unmanaged,
	weak__api_dispatcher = IScriptAPIDispatcher,
	weak__script_manager = IScriptManager,
}

function ScriptAPIManager:ctor(api_dispatcher, script_manager)
	self._api_proxy_map = {}
	self._script_api_space = setmetatable({
		-- 如果想要为script提供一些算法或系统函数支持，在此处添加
	}, {__index = self._api_proxy_map, __newindex = function() error("read only") end})

	self._api_dispatcher = api_dispatcher
	self._script_manager = script_manager

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
	return self:_waitSig(SSL_API, time)
end
function ScriptAPIManager:_built_in_apiAbort(api_token)
	self._api_dispatcher:apiAbort(api_token)
end
function ScriptAPIManager:_built_in_delay(time)
	-- 使脚本等待计时信号
	return self:_waitSig(SSL_Timing, time)
end
function ScriptAPIManager:_built_in_waitCondition(condition, time_out)
	-- 检查条件，todo同时还要验证条件里没有调用过API
	if condition() then
		return true -- not_time_out
	end
	-- 使脚本等待条件信号
	return self:_waitSig(SSL_Condition, condition, time_out)
end
function ScriptAPIManager:_built_in_waitEvent(event_logic, time_out)
	-- 使脚本等待事件信号
	return self:_waitSig(SSL_Event, event_logic, time_out)
end

-- 注册内建API
for k, v in pairs(ScriptAPIManager) do
	if "function" == type(v) then
		local api_name = k:match("^_built_in_(.+)")
		if api_name then
			_log("built in api:", api_name)
			_built_in_apis[api_name] = v
		end
	end
end
------- [代码区段结束] 内建API ---------<

function ScriptAPIManager:_waitSig(sig_logic_class, ...)
	local sig_logic = new(sig_logic_class, ...)
	self._script_manager:_scriptWait(sig_logic)

	-- 返回的sig_logic和等待的是同一个
	local is_time_out = sig_logic:isTimeOut()
	delete(sig_logic)
	sig_logic = nil
	return not is_time_out
end

