

--[[
此文件中定义IScriptSigLogic的各个具体实现类
这些实现类以SSL_作为前缀
--]]

------- [代码区段开始] API信号逻辑 --------->
SSL_API = typesys.def.SSL_API {__super = IScriptSigLogic,
	__pool_capacity = -1,
	__strong_pool = true,
	weak__api_dispatcher = IScriptAPIDispatcher,
	_api_token = 0,
	_time_out = -1,
	_sig = "",
}

function SSL_API:__ctor(sig_factory, api_dispatcher, api_token, time_out)
	self._api_dispatcher = api_dispatcher
	self._api_token = api_token
	self._time_out = time_out or self._time_out
	self._sig = sig_factory:createSig_API(api_token)
end

function SSL_API:__dtor()
	
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
SSL_Timing = typesys.def.SSL_Timing {__super = IScriptSigLogic,
	__pool_capacity = -1,
	__strong_pool = true,
	_time = 0,
	_time_spent = 0,
}

function SSL_Timing:__ctor(sig_factory, time)
	self._time = time
end

function SSL_Timing:__dtor()
	
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function SSL_Timing:check(sigs_set)
	return self._time_spent >= self._time
end

function SSL_Timing:checkTimeOut(time, delta_time)
	self._time_spent = self._time_spent + delta_time
end
------- [代码区段结束] 计时信号逻辑 ---------<




------- [代码区段开始] 条件信号逻辑 --------->
--[[
条件信号逻辑是可以结合api查询接口来实现带有逻辑的或者多api的条件达成
如果将事件逻辑的构建接口也提供给脚本使用者，还能将事件逻辑判断也一并融合进来，实现复杂的条件逻辑
但是其难点是：是否要将sigs_set传入condition，如果是这样，那么APi预判中也要构造个空的sigs_set，避免nil访问错误
同时也有被篡改的风险
--]]
SSL_Condition = typesys.def.SSL_Condition {__super = IScriptSigLogic,
	__pool_capacity = -1,
	__strong_pool = true,
	_condition = typesys.__unmanaged,
	_time_out = -1,
	_time_spent = 0,
}

function SSL_Condition:__ctor(sig_factory, condition, time_out)
	self._condition = condition
	self._time_out = time_out or self._time_out
end

function SSL_Condition:__dtor()
	
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function SSL_Condition:check(sigs_set)
	return self._condition()
end

function SSL_Condition:checkTimeOut(time, delta_time)
	self._time_spent = self._time_spent + delta_time
	if 0 < self._time_out then
		return self._time_out < self._time_spent
	end
	return false
end
------- [代码区段结束] 条件信号逻辑 ---------<




------- [代码区段开始] 事件信号逻辑 --------->
--[[
关于事件逻辑，考虑直接用lua语法中的 and or not以及小括号()，配合事件名来构造
解析时将事件名转换成sigs_set:containKey(sig)，其中sig是由sig_factory通过事件名创建出来的
将转换后的代码块构建成一个check函数（参数为sigs_set），在check时进行调用并返回事件是否达成
--]]
SSL_Event = typesys.def.SSL_Event {__super = IScriptSigLogic,
	__pool_capacity = -1,
	__strong_pool = true,
	_event_logic_func = typesys.__unmanaged,
	_time_out = -1,
	_time_spent = 0,
}

function SSL_Event:__ctor(sig_factory, event_logic_func, time_out)
	self._event_logic_func = event_logic_func
	self._time_out = time_out or self._time_out
end

function SSL_Event:__dtor()
	
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function SSL_Event:check(sigs_set)
	return self._event_logic_func(sigs_set)
end

function SSL_Event:checkTimeOut(time, delta_time)
	self._time_spent = self._time_spent + delta_time
	if 0 < self._time_out then
		return self._time_out < self._time_spent
	end
	return false
end
------- [代码区段结束] 条件信号逻辑 ---------<