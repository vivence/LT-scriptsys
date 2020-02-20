package.path = package.path ..';../?.lua;../../lua-typesys/?.lua'

require("TypeSystemHeader")
require("ScriptThread")

local new = typesys.new
local delete = typesys.delete

local t = new(ScriptThread)

delete(t)
t = nil