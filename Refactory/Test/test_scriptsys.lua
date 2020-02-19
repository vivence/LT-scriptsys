
require('io')

local sleep_map = {}
local function _sleep(seconds)
    local str = sleep_map[seconds]
    if nil == str then
        str = 'sleep '..seconds
        sleep_map[seconds] = str
    end
    os.execute(str)
end

package.path = package.path ..';../?.lua;../../../lua-typesys/?.lua'

require("TypeSystemHeader")
require("ScriptSystemHeader")
require("APIDispatcherSample")

local new = typesys.new
local delete = typesys.delete

-----------

local apiTestNumber = typesys.apiTestNumber{
    __super = IAPISample,
    num = 0,
}
function apiTestNumber:ctor( n )
    self.num = n
end
function apiTestNumber:execute()
    print("[apiTestNumber]: ", self.num)
end

function apiTestNumber:getReturn()
    return string.format("testNumber(%d) ok", self.num)
end

local apiTestString = typesys.apiTestString{
    __super = IAPISample,
    str = "",
}
function apiTestString:ctor( s )
    self.str = s
end
function apiTestString:execute()
    print("[apiTestString]: ", self.str)
end

function apiTestString:getReturn()
    return string.format("testString(%d) ok", self.str)
end

local API = {
    testNumber = apiTestNumber,
    testString = apiTestString,
}

local AssistAPI = {}
function AssistAPI.print( ... )
    print("[script-log]: ", ...)
end

-- 初始化
local script_sys = new(ScriptSystem, APIDispatcherSample)
script_sys:registerAPI(API)
script_sys:registerAssistAPI(AssistAPI)

-- 加载
local script_token = script_sys:loadScript("ScriptSample")

-- 执行
script_sys:runScript(script_token)

-- 帧循环
local time = 1
local delta_time = 1
repeat
    print("time: ", time)
    -- script_sys:abortScript(script_token)
    script_sys:tick(time, delta_time)
    -- script_sys:abortScript(script_token)
    time = time + delta_time
    _sleep(1)
until not script_sys:scriptIsRunning(script_token)

-- 释放
delete(script_sys)
script_sys = nil