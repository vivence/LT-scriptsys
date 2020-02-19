
local function proc()

	print("step1")
	apiWait(testNumber(100))
	print("step2")
	delay(5)
	print("step3")
	apiWait(testString("hello"))
	print("step4")

	return "proc finished"
end

return proc