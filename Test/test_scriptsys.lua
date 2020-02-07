package.path = package.path ..';../?.lua;../../lua-typesys/?.lua'

require("TypeSystemHeader")
require("ScriptSystemHeader")

------------

Script = typesys.Script {
	__pool_capacity = -1,
	__strong_pool = true,
	running = false,
	proc = typesys.unmanaged,
}

function Script:ctor(proc)
	assert(nil ~= proc and "function" == type(proc))
	self.proc = proc
end

function Script:dtor()
	self.proc = nil
end

function Script:start()
	if self.running then
		return
	end

	self.running = true
	self.proc()
	self.running = false
end

function Script:abort()
	if not self.running then
		return
	end

	-- todo

	self.running = false
end

-------------

local new = typesys.new
local delete = typesys.delete

API = {
	world = require("ScriptAPISample"),
}

local script = new(Script, require("ScriptSample"))

script:start()
while script.running do
	-- todo
end

delete(script)
script = nil

