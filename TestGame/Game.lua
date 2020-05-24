
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

package.path = package.path ..';../?.lua;../../lua-typesys/Refactory/?.lua'

require("TypeSystemHeader")
require("ScriptSystemHeader")
require("GameAPIDispatcher")
require("GameAPI")

local new = typesys.new
local gc = typesys.gc
local setRootObject = typesys.setRootObject

Game = typesys.def.Game {
    script_sys = ScriptSystem,
    enviroment = GameEnviroment,
}

function Game:__ctor()
    local script_sys = new(ScriptSystem, GameAPIDispatcher)
    -- 初始化API
    script_sys:registerAPI(GameAPIMap)
    script_sys:registerAssistAPI(GameAssistAPIMap)

    self.script_sys = script_sys
end

function Game:run()
    local script_sys = self.script_sys

    -- 加载脚本
    local script_token = script_sys:loadScript("GameScript")

    -- 执行脚本
    script_sys:runScript(script_token)

    -- 脚本帧循环
    local time = 1
    local delta_time = 0.1
    repeat
        -- print("[main] time: ", g_time)
        -- script_sys:abortScript(script_token)
        script_sys:tick(time, delta_time)
        -- script_sys:abortScript(script_token)
        time = time + delta_time
        _sleep(delta_time)

        gc()
    until not script_sys:scriptIsRunning(script_token)
end

g_game = new(Game)
setRootObject(g_game)

g_game:run()

setRootObject(nil)
g_game = nil