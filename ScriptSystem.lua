

local new = typesys.new

--[[
脚本系统，外部只需要使用此类型对象的接口即可
--]]
ScriptSystem = typesys.ScriptSystem {
	__pool_capacity = -1,
	__strong_pool = true,
	script_manager = ScriptManager,
	sig_dispatcher = ScriptSigDispatcher,
}

function ScriptSystem:ctor()
	self.script_manager = new(ScriptManager)
	self.sig_dispatcher = new(ScriptSigDispatcher, self.script_manager)
end

function ScriptSystem:dtor()
	
end

function ScriptSystem:tick(time, delta_time)
	self.sig_dispatcher:tick(time, delta_time)
end

-- 注册一个脚本函数，返回一个token
function ScriptSystem:registerScript(script_func)
	local script = new(Script, script_func, self.script_manager, self.sig_dispatcher)
	local script_token = self.script_manager:addScript(script)
	return script_token
end

-- 运行指定的token所表示的脚本
function ScriptSystem:runScript(script_token)
	local script = self.script_manager:getScript(script_token)
	if nil ~= script then
		script:run()
		return true
	else
		return false
	end
end

-- 判断指定的token所表示的脚本是否正在运行
function ScriptSystem:isScriptRunning(script_token)
	local script = self.script_manager:getScript(script_token)
	return nil ~= script and script:isRunning()
end

-- 向脚本系统发送信号
function ScriptSystem:sendSig(sig)
	self.sig_dispatcher:sendSig(sig)
end


