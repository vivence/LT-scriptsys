

--[[
此文件中定义一些信号系统的接口类，让依赖信号系统的类能够相互协作
--]]



------- [代码区段开始] 脚本API调度器接口类 --------->
-- 作为API实现的访问入口，负责隐藏API实现和执行的细节
IScriptAPIDispatcher = typesys.IScriptAPIDispatcher {
	__pool_capacity = -1,
	__strong_pool = true,
}

function IScriptAPIDispatcher:ctor(script_sys)
	assert(false)
end

function IScriptAPIDispatcher:dtor()
	assert(false)
end

function IScriptAPIDispatcher:tick(time, delta_time)
	assert(false)
end

function IScriptAPIDispatcher:postAPI(api_name, api_info, ...)
	assert(false)
end

function IScriptAPIDispatcher:apiIsPending(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiIsExecuting(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiIsDead(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiDiedOfInterruption(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiGetReturn(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiGetTimeSpent(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiAbort(api_token)
	assert(false)
end
------- [代码区段结束] 脚本API调度器接口类 ---------<





------- [代码区段开始] 信号逻辑接口类 --------->
IScriptSigLogic = typesys.IScriptSigLogic {
	__pool_capacity = -1,
	__strong_pool = true,
	is_time_out = false,
}

function IScriptSigLogic:ctor()
end

function IScriptSigLogic:dtor()
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function IScriptSigLogic:check(sigs_set)
	assert(false)
end

function IScriptSigLogic:checkTimeOut(time, delta_time)
	assert(false)
end
------- [代码区段结束] 信号逻辑接口类 ---------<





------- [代码区段开始] 脚本管理器接口类 --------->
IScriptManager = typesys.IScriptManager {
	__pool_capacity = -1,
	__strong_pool = true,
}

function IScriptManager:ctor()
	assert(false)
end

function IScriptManager:dtor()
	assert(false)
end

------- [代码区段开始] 提供给ScriptAPIManager使用的函数 --------->
function IScriptManager:_scriptWait(sig_logic)
	assert(false)
end
------- [代码区段结束] 提供给ScriptAPIManager使用的函数 ---------<

------- [代码区段开始] 提供给ScriptSigDispatcher使用的函数，减少运行开销 --------->
function IScriptManager:_setSigDispatcher(sig_dispatcher)
	assert(false)
end
-- 获取正在监听信号的脚本
function IScriptManager:_getScriptListeningSig(script_token)
	assert(false)
end
-- 脚本相应信号
function IScriptManager:_scriptOnSig(script, ...)
	assert(false)
end
------- [代码区段结束] 提供给ScriptSigDispatcher使用的函数，减少运行开销 ---------<

------- [代码区段结束] 脚本管理器接口类 ---------<





------- [代码区段开始] 脚本管理器接口类 --------->
IScriptSigDispatcher = typesys.IScriptSigDispatcher {
	__pool_capacity = -1,
	__strong_pool = true,
}

function IScriptSigDispatcher:ctor()
	assert(false)
end

function IScriptSigDispatcher:dtor()
	assert(false)
end

------- [代码区段开始] 提供给ScriptManager使用的函数 --------->
function IScriptSigDispatcher:_setScriptManager(script_manager)
	assert(false)
end
-- 监听信号
function IScriptSigDispatcher:_listenSig(script_token, sig_logic)
	assert(false)
end
-- 取消监听
function IScriptSigDispatcher:_unlistenSig(script_token)
	assert(false)
end
------- [代码区段结束] 提供给ScriptManager使用的函数 ---------<

------- [代码区段结束] 脚本管理器接口类 ---------<