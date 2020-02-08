package.path = package.path ..';../?.lua;../../lua-typesys/?.lua'

require("TypeSystemHeader")
require("ScriptSystemHeader")

local new = typesys.new
local delete = typesys.delete

API = {
	world = require("ScriptAPISample"),
}

local script_sys = new(ScriptSystem)
local script_token = script_sys:registerScript(require("ScriptSample"))

script_sys:runScript(script_token)
while script_sys:isScriptRunning(script_token) do
	-- todo
end

delete(script_sys)
script_sys = nil