
g_time = 1
g_delta_time = 1

local apiTestNumber = typesys.def.apiTestNumber{__super = IAPISample,
    num = 0,
}
function apiTestNumber:__ctor( n )
    self.num = n
end
function apiTestNumber:execute()
    print("[apiTestNumber]: ", self.num)
end

function apiTestNumber:getReturn()
    return string.format("testNumber(%d) ok", self.num)
end

local apiTestString = typesys.def.apiTestString{__super = IAPISample,
    str = "",
}
function apiTestString:__ctor( s )
    self.str = s
end
function apiTestString:execute()
    print("[apiTestString]: ", self.str)
end

function apiTestString:getReturn()
    return string.format("testString(%d) ok", self.str)
end

APIMapSample = {
    testNumber = apiTestNumber,
    testString = apiTestString,
}

AssistAPIMapSample = {}
function AssistAPIMapSample.print( ... )
    print("[script-log]: ", ...)
end
function AssistAPIMapSample.getCurrentTime()
    return g_time
end

