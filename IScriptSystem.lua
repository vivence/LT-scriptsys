
local assert = assert

local function _notImplemented()
	assert(false, "接口未实现")
end

--[[
此文件中定义一些信号系统的接口类，让依赖信号系统的类能够相互协作
--]]



------- [代码区段开始] 脚本API调度器接口类 --------->
-- 作为API实现的访问入口，负责隐藏API实现和执行的细节
IScriptAPIDispatcher = typesys.def.IScriptAPIDispatcher {
	__pool_capacity = -1,
	__strong_pool = true,
}

function IScriptAPIDispatcher:__ctor(script_sys)
	_notImplemented()
end

function IScriptAPIDispatcher:tick(time, delta_time)
	_notImplemented()
end

function IScriptAPIDispatcher:postAPI(api_name, api_info, ...)
	_notImplemented()
end

function IScriptAPIDispatcher:apiIsPending(api_token)
	_notImplemented()
end
function IScriptAPIDispatcher:apiIsExecuting(api_token)
	_notImplemented()
end
function IScriptAPIDispatcher:apiIsDead(api_token)
	_notImplemented()
end
function IScriptAPIDispatcher:apiDiedOfInterruption(api_token)
	_notImplemented()
end
function IScriptAPIDispatcher:apiGetReturn(api_token)
	_notImplemented()
end
function IScriptAPIDispatcher:apiGetTimeSpent(api_token)
	_notImplemented()
end
function IScriptAPIDispatcher:apiAbort(api_token)
	_notImplemented()
end
------- [代码区段结束] 脚本API调度器接口类 ---------<





------- [代码区段开始] 信号逻辑基类 --------->
IScriptSigLogic = typesys.def.IScriptSigLogic {
	__pool_capacity = -1,
	__strong_pool = true,
	is_time_out = false,
}

function IScriptSigLogic:__ctor(sig_factory)
	_notImplemented()
end

-- sigs_set是一个typesys.map，key是string，value是boolean
function IScriptSigLogic:check(sigs_set)
	_notImplemented()
end

function IScriptSigLogic:checkTimeOut(time, delta_time)
	_notImplemented()
end
------- [代码区段结束] 信号逻辑基类 ---------<





------- [代码区段开始] 脚本管理器接口类 --------->
IScriptManager = typesys.def.IScriptManager {
	__pool_capacity = -1,
	__strong_pool = true,
}

function IScriptManager:__ctor()
	_notImplemented()
end

------- [代码区段开始] 提供给ScriptAPIManager使用的函数 --------->
function IScriptManager:_scriptWait(sig_logic)
	_notImplemented()
end
------- [代码区段结束] 提供给ScriptAPIManager使用的函数 ---------<

------- [代码区段开始] 提供给ScriptSigDispatcher使用的函数，减少运行开销 --------->
function IScriptManager:_setSigDispatcher(sig_dispatcher)
	_notImplemented()
end
-- 获取正在监听信号的脚本
function IScriptManager:_getScriptListeningSig(script_token)
	_notImplemented()
end
-- 脚本相应信号
function IScriptManager:_scriptOnSig(script, ...)
	_notImplemented()
end
------- [代码区段结束] 提供给ScriptSigDispatcher使用的函数，减少运行开销 ---------<

------- [代码区段结束] 脚本管理器接口类 ---------<





------- [代码区段开始] 脚本管理器接口类 --------->
IScriptSigDispatcher = typesys.def.IScriptSigDispatcher {
	__pool_capacity = -1,
	__strong_pool = true,
}

function IScriptSigDispatcher:__ctor()
	_notImplemented()
end

------- [代码区段开始] 提供给ScriptManager使用的函数 --------->
function IScriptSigDispatcher:_setScriptManager(script_manager)
	_notImplemented()
end
-- 监听信号
function IScriptSigDispatcher:_listenSig(script_token, sig_logic)
	_notImplemented()
end
-- 取消监听
function IScriptSigDispatcher:_unlistenSig(script_token)
	_notImplemented()
end
------- [代码区段结束] 提供给ScriptManager使用的函数 ---------<

------- [代码区段结束] 脚本管理器接口类 ---------<