
local function subProc1()
	delay(5)
	print("sub1-step1")
	apiWait(testString("hello"))
	print("sub1-step2")
	if not waitCondition(function()
		return 10 <= getCurrentTime()
	end, -1) then
		-- timed out
		print("condition timed out!")
	end
	print("sub1-step3")
end

local function subProc2()
	print("sub2-step1")
	if not waitEvent("$event_1 or $event_2", 3) then
		-- timed out
		print("event timed out!")
	end
	print("sub2-step2")
end

local function proc( ... )
	print("step1")
	apiWait(testNumber(100))
	print("step2")
	subProc1()
	print("step3")
	subProc2()
	print("step4")

	return "proc finished"
end

-- 第一个为入口主函数
return {proc, subProc1, subProc2}