
local INVALID_TOKEN = typesys.INVALID_ID

--[[
脚本对象的管理器，管理脚本对象的生命周期
--]]
ScriptManager = typesys.ScriptManager {
	__pool_capacity = -1,
	__strong_pool = true,
	script_map = typesys.map,
	active_script_token = INVALID_TOKEN,
}

function ScriptManager:ctor()
	self.script_map = typesys.new(typesys.map, type(0), Script)
end

function ScriptManager:dtor()
	
end

-- 通过token获取脚本对象
function ScriptManager:getScript(script_token)
	return self.script_map:get(script_token)
end

-- 添加一个脚本对象，返回token
function ScriptManager:addScript(script)
	local script_token = self:getScriptToken(script)
	self.script_map:set(script_token, script)
	return script_token
end

-- 通过token移除一个脚本对象
function ScriptManager:removeScript(script_token)
	self.script_map:set(script_token, nil)
end

-- 获取脚本的token
function ScriptManager:getScriptToken(script)
	return script._id
end

-- 设置脚本对象为激活状态
function ScriptManager:registerActiveScript(script)
	self.active_script_token = self:getScriptToken(script)
end

-- 移除脚本对象的激活状态
function ScriptManager:unregisterActiveScript(script)
	assert(self:getScriptToken(script) == self.active_script_token)
	self.active_script_token = INVALID_TOKEN
end

-- 判断脚本对象是否是激活状态
function ScriptManager:isActiveScript(script)
	return self:getScriptToken(script) == self.active_script_token
end

