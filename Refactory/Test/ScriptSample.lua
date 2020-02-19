
local function proc()

	print("step1")
	apiWait(testNumber(100))
	print("step2")
	apiWait(testString("hello"))
	print("step3")

	return "proc finished"
end

return proc