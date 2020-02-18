package.path = package.path ..';../?.lua;../../../lua-typesys/?.lua'

local function setfenv(fn, env)
    local i = 1
    while true do
        local name = debug.getupvalue(fn, i)
        if name == "_ENV" then
            debug.upvaluejoin(fn, i, (function()
                return env
            end), 1)
            break
        elseif not name then
            break
        end
        i = i + 1
    end
    return fn
end

require("TypeSystemHeader")
require("IScriptAPIDispatcher")
require("ScriptAPIManager")
require("APIDispatcherSample")

local apiTest1 = typesys.apiTest1{__super = IAPISample}
function apiTest1:ctor( ... )end

local apiTest2 = typesys.apiTest2{__super = IAPISample}
function apiTest2:ctor( ... )end

local API = {
    test1 = apiTest1,
    test2 = apiTest2,
}

local AssistAPI = {}
function AssistAPI.print( ... )
    print("[ScriptLog]: ", ...)
end

-----------

local new = typesys.new
local delete = typesys.delete

local api_dispatcher = new(APIDispatcherSample)
local api_mamager = new(ScriptAPIManager, api_dispatcher)
api_mamager:registerAPI(API)
api_mamager:registerAssistAPI(AssistAPI)

local script = require("ScriptSample")
setfenv(script, api_mamager:getAPISpace())

print()
script()
print()

delete(api_mamager)
api_mamager = nil

