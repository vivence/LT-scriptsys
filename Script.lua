
local _log = nil
if typesys.DEBUG_ON then 
	_log = function(id, ...) print(string.format("Script[%d]", id), ...) end 
else
	_log = function() end
end

--[[
脚本类，使用脚本函数构建此类对象，并指定其信号调度器
--]]
Script = typesys.Script {
	__pool_capacity = -1,
	__strong_pool = true,
	co = typesys.unmanaged,   -- 协程
	proc = typesys.unmanaged, -- 脚本函数
	weak_script_manager = ScriptManager,
	weak_sig_dispatcher = ScriptSigDispatcher,
}

-- 协程proc
local function _threadProc(self)
	self:_threadProc()
end

function Script:ctor(proc, script_manager, sig_dispatcher)
	assert(nil ~= proc and "function" == type(proc))
	assert(nil ~= sig_dispatcher)
	self.proc = proc
	self.script_manager = script_manager
	self.sig_dispatcher = sig_dispatcher
end

function Script:dtor()
	self.proc = nil
	self.sig_dispatcher = nil
end

-- 脚本是否处于运行状态，注意运行状态中可能是激活状态，也可能是非激活状态（等待信号）
function Script:isRunning()
	return nil ~= self.co
end

-- 脚本是否处于激活状态
function Script:isActive()
	local script_manager = self.script_manager
	assert(nil ~= script_manager)
	return script_manager:isActiveScript(self)
end

-- 脚本启动的入口函数
function Script:run()
	self:_startRunning()
end

-- 由信号调度器调用，用于触发信号
function Script:onSig(on_sig_logic)
	-- in sig thread
	assert(self:isRunning() and not self:isActive()) -- 确保不在自身脚本运行的协程内
	self:_awake(on_sig_logic)
end

-- 由脚本调用的等待型API调用
function Script:waitSig(wait_sig_logic)
	-- in self thread
	assert(nil ~= wait_sig_logic)
	assert(self:isActive()) -- 确保在自身脚本运行的协程内
	return self:_sleep(wait_sig_logic)
end

------- [代码区段开始] 私有函数 --------->

function Script:_startRunning()
	if self:isRunning() then
		return
	end
	-- 初始化并运行协程
	self.co = coroutine.create(_threadProc)
	self:_awake(self)
end

function Script:_endRunning()
	self.co = nil
end

function Script:_setActive()
	local script_manager = self.script_manager
	assert(nil ~= script_manager)
	script_manager:registerActiveScript(self)
end

function Script:_setInactive()
	local script_manager = self.script_manager
	assert(nil ~= script_manager)
	script_manager:unregisterActiveScript(self)
end

function Script:_awake(self_or_on_sig_logic)
	local no_error, ret = coroutine.resume(self.co, self_or_on_sig_logic)
	if no_error then
		if nil ~= ret then
			-- in sig thread
			-- ret就是wait_sig_logic，向信号调度器注册
			local sig_dispatcher = self.sig_dispatcher
			assert(nil ~= sig_dispatcher)
			sig_dispatcher:register(self, ret)
		else
			-- 脚本执行完毕
			_log(self._id, "finished")
		end
	else
		_log(self._id, ret)
	end
end

function Script:_sleep(wait_sig_logic)
	-- in self thread
	local on_sig_logic = coroutine.yield(wait_sig_logic) -- 用yield将等待的信号逻辑转发到信号调度器协程空间
	if on_sig_logic:isAbort() then
		-- 收到中断信号，通过error强制返回
		error("abort")
	end
	return sig
end

function Script:_threadProc()
	self:_setActive()

	self.proc()

	self:_setInactive()
	self:_endRunning()
end

------- [代码区段开始] 私有函数 ---------<

