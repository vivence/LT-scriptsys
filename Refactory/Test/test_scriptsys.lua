
package.path = package.path ..';../?.lua;../../../lua-typesys/?.lua'

require("TypeSystemHeader")
require("ScriptSystemHeader")
require("APIDispatcherSample")

local new = typesys.new
local delete = typesys.delete

-----------

local apiTest1 = typesys.apiTest1{}
function apiTest1:ctor( ... )end

local apiTest2 = typesys.apiTest2{}
function apiTest2:ctor( ... )end

local API = {
    test1 = apiTest1,
    test2 = apiTest2,
}

local AssistAPI = {}
function AssistAPI.print( ... )
    print("[script-log]: ", ...)
end

-- 初始化
local api_dispatcher = new(APIDispatcherSample)
local script_sys = new(ScriptSystem, api_dispatcher)
script_sys:registerAPI(API)
script_sys:registerAssistAPI(AssistAPI)

-- 加载
local script_token = script_sys:loadScript("ScriptSample")

-- 执行
script_sys:runScript(script_token)

local frame_count = 1
while script_sys:scriptIsRunning(script_token) do
	script_sys:tick(frame_count, 1)
	print(frame_count)
	frame_count = frame_count + 1
end

-- 释放
delete(script_sys)
script_sys = nil