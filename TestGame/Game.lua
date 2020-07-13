
require("io")

local OS_Win = false -- 设置操作系统是否是Windows

local _sleep = nil
if OS_Win then
    _sleep = function(seconds)
        local start_t = os.clock()
        while os.clock() - start_t <= seconds do end
    end
else
    local sleep_map = {}
    _sleep = function(seconds)
        local str = sleep_map[seconds]
        if nil == str then
            str = "sleep "..seconds
            sleep_map[seconds] = str
        end
        os.execute(str)
    end
end

package.path = package.path ..';../?.lua;../../lua-typesys/?.lua'

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

-- true：生成puml脚本
local generate_puml = false

if not generate_puml then
    g_game = new(Game)
    setRootObject(g_game)

    g_game:run()

    setRootObject(nil)
    g_game = nil
else
    package.path = package.path ..';../../lua-typesys/PlantUML/?.lua'
    require("TypesysPlantUML")
    local toPlantUMLSucceed = typesys.tools.toPlantUML("Game.puml")
    print("to plantuml: "..tostring(toPlantUMLSucceed).."\n")
end
