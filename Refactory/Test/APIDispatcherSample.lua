
local new = typesys.new

IAPISample = typesys.IAPISample {
    __pool_capacity = -1,
    __strong_pool = true,
}

local function _getAPIToken(api_obj)
    return api_obj._id
end

--[[
API调度器接口描述，作为API实现的访问入口，负责隐藏API实现和执行的细节
--]]
APIDispatcherSample = typesys.APIDispatcherSample {
    __pool_capacity = -1,
    __strong_pool = true,
    __super = IScriptAPIDispatcher,
    _api_list = typesys.array,
}

function APIDispatcherSample:ctor()
    self._api_list = new(typesys.array, IAPISample)
end

function APIDispatcherSample:dtor()
end

function APIDispatcherSample:tick(time, delta_time)
    -- todo
end

function APIDispatcherSample:postAPI(api_name, api_class, ...)
    -- 先缓存api，api通过tick来按顺序执行
    local api_obj = new(api_class, ...)
    self._api_list:pushBack(api_obj)
    local api_token = _getAPIToken(api_obj)
    return api_token
end

function APIDispatcherSample:apiIsPending(api_token)
	-- todo
end
function APIDispatcherSample:apiIsExecuting(api_token)
	-- todo
end
function APIDispatcherSample:apiIsDead(api_token)
	-- todo
end
function APIDispatcherSample:apiIsInterrupted(api_token)
	-- todo
end
function APIDispatcherSample:apiGetReturn(api_token)
	-- todo
end
function APIDispatcherSample:apiGetTimeSpent(api_token)
	-- todo
end
function APIDispatcherSample:apiAbort(api_token)
	-- todo
end


