
local new = typesys.new

Script = typesys.Script {
	__pool_capacity = -1,
	__strong_pool = true,
	_name = "",
	_proc = typesys.unmanaged,
	_thread = ScriptThread,
}

function Script:ctor(name, proc)
	self._name = name
	self._proc = proc
	self._thread = new(ScriptThread)
end

function Script:dtor()
	self._proc = nil
end

-- 返回一帧执行后的结果，isRunning()为true，则是sleep参数，否则是proc的返回值
function Script:run(...)
	return self._thread:start(self._proc, ...)
end

-- 返回一帧执行后的结果，isRunning()为true，则是sleep参数，否则是proc的返回值
function Script:awake( ... )
	return self._thread:awake(...)
end

-- 返回awake参数
function Script:sleep( ... )
	return self._thread:sleep(...)
end

function Script:abort()
	return self._thread:abort()
end

function Script:isRunning()
	return nil ~= self._thread and self._thread:isRunning()
end

function Script:isActive()
	return nil ~= self._thread and self._thread:isActive()
end




