
-- 未解决问题：如果定义多个函数来组织脚本代码，怎么为每个函数都设置API空间

local function subProc()
	delay(5)
	print("sub-step1")
	apiWait(testString("hello"))
	print("sub-step2")
	if not waitCondition(function()
		return 10 <= getCurrentTime()
	end, -1) then
		-- timed out
		print("condition timed out!")
	end
	print("sub-step3")
end

local function proc( ... )
	print("step1")
	apiWait(testNumber(100))
	print("step2")
	subProc()
	print("step3")

	return "proc finished"
end

return {proc, subProc}