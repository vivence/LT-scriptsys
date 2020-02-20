
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
require("APISample")

local new = typesys.new
local delete = typesys.delete

-- 初始化
local script_sys = new(ScriptSystem, APIDispatcherSample)
script_sys:registerAPI(APIMapSample)
script_sys:registerAssistAPI(AssistAPIMapSample)

-- 加载
local script_token = script_sys:loadScript("ScriptSample")

-- 执行
script_sys:runScript(script_token)

-- 帧循环
repeat
    print("time: ", g_time)
    -- script_sys:abortScript(script_token)
    script_sys:tick(g_time, g_delta_time)
    -- script_sys:abortScript(script_token)
    g_time = g_time + g_delta_time
    _sleep(1)
until not script_sys:scriptIsRunning(script_token)

-- 释放
delete(script_sys)
script_sys = nil



