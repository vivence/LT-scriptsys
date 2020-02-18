
--[[
生产信号的工厂，所有的信号都必须从工厂里生产出，以便统一管理
--]] 
ScriptSigFactory = typesys.ScriptSigFactory {
	__pool_capacity = -1,
	__strong_pool = true,
}

function ScriptSigFactory:ctor()
	
end

function ScriptSigFactory:dtor()
	
end