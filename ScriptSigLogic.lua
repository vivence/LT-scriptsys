
--[[
信号逻辑可以是单个信号，或者多个信号之间的逻辑关系
--]] 
ScriptSigLogic = typesys.ScriptSigLogic {
	__pool_capacity = -1,
	__strong_pool = true,
}

function ScriptSigLogic:ctor()
	
end

function ScriptSigLogic:dtor()
	
end

function ScriptSigLogic:isAbort()
	return false
end

function ScriptSigLogic:checkSigs(sigs_set)
	return true
end