

--[[
此文件中定义IScriptSigLogic的各个具体实现类
这些实现类以SSL_作为前缀
--]]

------- [代码区段开始] API信号逻辑 --------->
SSL_API = typesys.SSL_API {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = ScriptSigLogic,
	weak__api_dispatcher = IScriptAPIDispatcher,
	_api_token = 0,
	_time_out = -1,
	_sig = "",
}

function SSL_API:ctor(sig_factory, api_dispatcher, api_token, time_out)
	self._api_dispatcher = api_dispatcher
	self._api_token = api_token
	self._time_out = time_out or self._time_out
	self._sig = sig_factory:createSig_API(api_token)
end

function SSL_API:dtor()
	
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function SSL_API:check(sigs_set)
	-- return sigs_set:containKey(self._sig)
	return self._api_dispatcher:apiIsDead(self._api_token)
end

function SSL_API:checkTimeOut(time, delta_time)
	if 0 < self._time_out then
		local api_time_spent = self._api_dispatcher:apiGetTimeSpent(self._api_token)
		return self._time_out < api_time_spent
	end
	return false
end
------- [代码区段结束] API信号逻辑 ---------<




------- [代码区段开始] 计时信号逻辑 --------->
SSL_Timing = typesys.SSL_Timing {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = ScriptSigLogic,
	_time = 0,
	_passed_time = 0,
}

function SSL_Timing:ctor(sig_factory, time)
	self._time = time
end

function SSL_Timing:dtor()
	
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function SSL_Timing:check(sigs_set)
	return self._passed_time >= self._time
end

function SSL_Timing:checkTimeOut(time, delta_time)
	self._passed_time = self._passed_time + delta_time
end
------- [代码区段结束] 计时信号逻辑 ---------<




------- [代码区段开始] 条件信号逻辑 --------->
SSL_Condition = typesys.SSL_Condition {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = ScriptSigLogic,
}

function SSL_Condition:ctor(sig_factory, condition, time_out)
	assert(false)
end

function SSL_Condition:dtor()
	assert(false)
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function SSL_Condition:check(sigs_set)
	assert(false)
end

function SSL_Condition:checkTimeOut(time, delta_time)
	assert(false)
end
------- [代码区段结束] 条件信号逻辑 ---------<




------- [代码区段开始] 事件信号逻辑 --------->
SSL_Event = typesys.SSL_Event {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = ScriptSigLogic,
}

function SSL_Event:ctor(sig_factory, event_logic, time_out)
	assert(false)
end

function SSL_Event:dtor()
	assert(false)
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function SSL_Event:check(sigs_set)
	assert(false)
end

function SSL_Event:checkTimeOut(time, delta_time)
	assert(false)
end
------- [代码区段结束] 条件信号逻辑 ---------<