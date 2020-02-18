
require("ScriptSigLogic")
require("ScriptManager")
require("ScriptSigDispatcher")
require("Script")
require("ScriptSystem")


--[[
脚本诉求：
1. 获取游戏运行环境各种数据
2. 调用并等待API执行结果（完成、被迫中断、超时）
3. 等待一个条件达成（难点是如何保证条件脚本的灵活性，同时又防止其调用API：可以先执行一次，并判断其未调用过API）

如果把所有等待（包括等待API执行结果）都抽象到等待一个条件达成里的话
那么需要找到一种方式告诉系统，这个API的调用结果需要被跟踪，避免跟踪不需要等待关心的API执行结果，造成浪费

xxxAPI() -- 调用API，不做跟踪，也不等待返回结果
post.xxxAPI() -- 调用API，返回API调用跟踪者，不等待返回结果
wait.xxxAPI() -- 调用API，并等待返回结果
waitCondition(condition) -- 等待条件达成，条件里不允许调用任何API
]]