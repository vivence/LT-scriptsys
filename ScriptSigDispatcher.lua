

--[[
脚本信号调度器，负责存储脚本所关注的信号逻辑，执行派发信号的逻辑
--]]
ScriptSigDispatcher = typesys.ScriptSigDispatcher {
	__pool_capacity = -1,
	__strong_pool = true,
	_script_sig_logic = typesys.map,
	_sigs_cache = typesys.map,
	weak__script_manager = ScriptManager,
}

function ScriptSigDispatcher:ctor(script_manager)
	self._script_sig_logic = typesys.new(typesys.map, type(0), ScriptSigLogic)
	self._sigs_cache = typesys.new(typesys.map, type(0), type(true))
	self._script_manager = script_manager
end

function ScriptSigDispatcher:dtor()
	
end

-- 注册脚本及其关注的信号逻辑
function ScriptSigDispatcher:register(script, sig_logic)
	local script_manager = self._script_manager
	assert(nil ~= script_manager)
	local script_token = script_manager:getScriptToken(script)
	self._script_sig_logic:set(script_token, sig_logic)
end

-- 发送信号
function ScriptSigDispatcher:sendSig(sig)
	-- 先缓存信号，信号通过tick来派发
	self._sigs_cache:set(sig, true)
end

local temp_script_sig_logic = {} -- 临时table
function ScriptSigDispatcher:tick(time, delta_time)
	local sigs_set = self._sigs_cache
	if not sigs_set:isEmpty() then
		assert(nil == next(temp_script_sig_logic)) -- 确保临时table为空
		local script_manager = self._script_manager
		local script_sig_logic = self._script_sig_logic

		-- 找到需要触发信号的脚本
		for script_token, sig_logic in script_sig_logic:pairs() do
			local script = script_manager:getScript(script_token)
			if nil ~= script then
				if sig_logic:checkSigs(sigs_set) then
					-- 信号逻辑触发成功，先将脚本移除
					script_sig_logic:set(script_token, nil)
					-- 将需要触发信号的脚本记录到临时table中
					temp_script_sig_logic[script] = sig_logic
				end
			else
				-- 脚本已经不存在了
				script_sig_logic:set(script_token, nil)
			end
		end

		-- 触发信号
		for script, sig_logic in pairs(temp_script_sig_logic) do
			temp_script_sig_logic[script] = nil
			script:onSig(sig_logic)
		end
	end

	-- 清空信号缓存
	self._sigs_cache:clear()
end