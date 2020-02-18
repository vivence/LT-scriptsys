
require("ScriptThread")
require("IScriptSystem")

require("ScriptAPIManager") -- 依赖IScriptSystem
require("Script") -- 依赖ScriptThread
require("ScriptManager") -- 依赖Script和IScriptSystem
require("ScriptSigDispatcher") -- 依赖IScriptSystem

require("ScriptSystem")