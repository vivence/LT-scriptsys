
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
end

function Script:dtor()
	self._proc = nil
end

function Script:run()
	local thread = self._thread
	if nil == thread then
		thread = new(ScriptThread)
		self._thread = thread
	end

	local sleep_args = thread:start(self._proc)
	if not thread:isRunning() then
		self._thread = nil
	end
end

function Script:isRunning()
	return nil ~= self._thread and self._thread:isRunning()
end