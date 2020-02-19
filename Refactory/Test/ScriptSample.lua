
local function proc()

	print("step1")
	apiWait(testNumber(100))
	print("step2")
	delay(5)
	print("step3")
	apiWait(testString("hello"))
	print("step4")
	if not waitCondition(function()
		return 10 <= getCurrentTime()
	end, -1) then
		-- timed out
		print("condition timed out!")
	end
	print("step5")

	return "proc finished"
end

return proc