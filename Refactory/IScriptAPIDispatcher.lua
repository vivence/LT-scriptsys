
local new = typesys.new

local function _getAPIToken(api_obj)
	return api_obj._id
end

--[[
API调度器接口描述，作为API实现的访问入口，负责隐藏API实现和执行的细节
--]]
IScriptAPIDispatcher = typesys.IScriptAPIDispatcher {
	__pool_capacity = -1,
	__strong_pool = true,
}

function IScriptAPIDispatcher:ctor()
	assert(false)
end

function IScriptAPIDispatcher:dtor()
	assert(false)
end

function IScriptAPIDispatcher:tick(time, delta_time)
	assert(false)
end

function IScriptAPIDispatcher:postAPI(api_name, api_info, ...)
	assert(false)
end

function IScriptAPIDispatcher:apiIsPending(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiIsExecuting(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiIsDead(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiIsInterrupted(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiGetReturn(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiGetTimeSpent(api_token)
	assert(false)
end
function IScriptAPIDispatcher:apiAbort(api_token)
	assert(false)
end