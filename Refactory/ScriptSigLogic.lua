

--[[
此文件中定义IScriptSigLogic的各个具体实现类
这些实现类以SSL_作为前缀
--]]

------- [代码区段开始] API信号逻辑 --------->
SSL_API = typesys.SSL_API {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = IScriptSigLogic,
}

function SSL_API:ctor(api_token, time_out)
	assert(false)
end

function SSL_API:dtor()
	assert(false)
end

function SSL_API:check(sigs_set)
	assert(false)
end

function SSL_API:checkTimeOut(time, delta_time)
	assert(false)
end

function SSL_API:markTimeOut()
	assert(false)
end

function SSL_API:isTimeOut()
	assert(false)
end
------- [代码区段结束] API信号逻辑 ---------<




------- [代码区段开始] 计时信号逻辑 --------->
SSL_Timing = typesys.SSL_Timing {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = IScriptSigLogic,
}

function SSL_Timing:ctor(time)
	assert(false)
end

function SSL_Timing:dtor()
	assert(false)
end

function SSL_Timing:check(sigs_set)
	assert(false)
end

function SSL_Timing:checkTimeOut(time, delta_time)
	assert(false)
end

function SSL_Timing:markTimeOut()
	assert(false)
end

function SSL_Timing:isTimeOut()
	assert(false)
end
------- [代码区段结束] 计时信号逻辑 ---------<




------- [代码区段开始] 条件信号逻辑 --------->
SSL_Condition = typesys.SSL_Condition {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = IScriptSigLogic,
}

function SSL_Condition:ctor(condition, time_out)
	assert(false)
end

function SSL_Condition:dtor()
	assert(false)
end

function SSL_Condition:check(sigs_set)
	assert(false)
end

function SSL_Condition:checkTimeOut(time, delta_time)
	assert(false)
end

function SSL_Condition:markTimeOut()
	assert(false)
end

function SSL_Condition:isTimeOut()
	assert(false)
end
------- [代码区段结束] 条件信号逻辑 ---------<




------- [代码区段开始] 事件信号逻辑 --------->
SSL_Event = typesys.SSL_Event {
	__pool_capacity = -1,
	__strong_pool = true,
	__super = IScriptSigLogic,
}

function SSL_Event:ctor(event_logic, time_out)
	assert(false)
end

function SSL_Event:dtor()
	assert(false)
end

function SSL_Event:check(sigs_set)
	assert(false)
end

function SSL_Event:checkTimeOut(time, delta_time)
	assert(false)
end

function SSL_Event:markTimeOut()
	assert(false)
end

function SSL_Event:isTimeOut()
	assert(false)
end
------- [代码区段结束] 条件信号逻辑 ---------<