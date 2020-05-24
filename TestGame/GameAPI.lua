

require("io")
require("os")
local io_read = io.read
local os_time = os.time
local randomseed = math.randomseed
local random = math.random
local floor = math.floor

require("BonusBox")
require("SpecialBonusBox")

local new = typesys.new

-- GameEnviroment
GameEnviroment = typesys.def.GameEnviroment{
    space = typesys.array,
    pos = 1,
    goal_bonus = 0,
    rest_chance = 0,
    opened_pos_map = typesys.map, -- pos -> bonus
}

function GameEnviroment:__ctor(space_size, goal_bonus, chance)
    local seed = tostring(os_time()):reverse():sub(1, 7)
    randomseed(seed)

    local start_pos = random(space_size)
    local goal_pos = random(space_size)
    local special_num = random(space_size)

    local bonus_block = floor(goal_bonus / goal_pos)

    local space = new(typesys.array, BonusBox)
    for i=1, space_size do
        local bonus
        if goal_pos == i then
            bonus = goal_bonus
        else
            bonus = random((i-1)*bonus_block, i*bonus_block)
        end
        if i == special_num then
            space[i] = new(SpecialBonusBox, bonus, random(chance))
        else
            space[i] = new(BonusBox, bonus)
        end
    end

    self.space = space
    self.pos = start_pos
    self.goal_bonus = goal_bonus
    self.rest_chance = chance
    self.opened_pos_map = new(typesys.map, type(0), type(0))
end

function GameEnviroment:openBox()
    self.rest_chance = self.rest_chance - 1
    local box = self.space[self.pos]
    local bonus, open_times = box:open()

    local ex_chance = 0
    if 1 >= open_times then
        self.opened_pos_map:set(self.pos, bonus)
        ex_chance = box:getChance()
        self.rest_chance = self.rest_chance + ex_chance
    end

    return bonus, open_times, ex_chance
end

function GameEnviroment:moveForward(steps)
    local max_steps = #self.space - self.pos
    if max_steps < steps then
        steps = max_steps
        self.pos = #self.space
    else
        self.pos = self.pos + steps
    end
    return steps
end

function GameEnviroment:moveBack(steps)
    if self.pos <= steps then
        steps = self.pos - 1
        self.pos = 1
    else
        self.pos = self.pos - steps
    end
    return steps
end

-- API: post_initGame
local apiInitGame = typesys.def.apiInitGame{__super = IGameAPI,
    space_size = 0,
    goal_bonus = 0,
    chance = 0,
}
function apiInitGame:__ctor(space_size, goal_bonus, chance)
    self.space_size = space_size
    self.goal_bonus = goal_bonus
    self.chance = chance
end
function apiInitGame:execute()
    g_game.enviroment = new(GameEnviroment, self.space_size, self.goal_bonus, self.chance)
end
function apiInitGame:getReturn()
    return true
end

-- API: post_openBox
local apiOpenBox = typesys.def.apiOpenBox{__super = IGameAPI,
    bonus = 0,
    open_times = 0,
    ex_chance = 0,
}
function apiOpenBox:execute()
    self.bonus, self.open_times, self.ex_chance = g_game.enviroment:openBox()
end
function apiOpenBox:getReturn()
    return self.bonus, self.open_times, self.ex_chance
end

-- API: post_moveForward
local apiMoveForward = typesys.def.apiMoveForward{__super = IGameAPI,
    steps = 0,
    moved_steps = 0,
}
function apiMoveForward:__ctor(steps)
    self.steps = steps
end
function apiMoveForward:execute()
    self.moved_steps = g_game.enviroment:moveForward(self.steps)
end
function apiMoveForward:getReturn()
    return self.moved_steps
end

-- API: post_moveBack
local apiMoveBack = typesys.def.apiMoveBack{__super = IGameAPI,
    steps = 0,
    moved_steps = 0,
}
function apiMoveBack:__ctor(steps)
    self.steps = steps
end
function apiMoveBack:execute()
    self.moved_steps = g_game.enviroment:moveBack(self.steps)
end
function apiMoveBack:getReturn()
    return self.moved_steps
end

-- APIMap
GameAPIMap = {
    post_initGame = apiInitGame,
    post_openBox = apiOpenBox,
    post_moveForward = apiMoveForward,
    post_moveBack = apiMoveBack,
}

-- AssistAPIMap
GameAssistAPIMap = {}
function GameAssistAPIMap.getPlayerPos()
    return g_game.enviroment.pos
end
function GameAssistAPIMap.getPlayerRestChance()
    return g_game.enviroment.rest_chance
end
function GameAssistAPIMap.getPlayerOpenedPosMap()
    return g_game.enviroment.opened_pos_map
end

--------

function GameAssistAPIMap.pairs(t)
    return pairs(t)
end
function GameAssistAPIMap.print( ... )
    return print(...)
end
function GameAssistAPIMap.s_format( ... )
    return string.format(...)
end
function GameAssistAPIMap.readOpt(try_max_count)
    try_max_count = try_max_count or 10
    local try_count = 0
    while try_count < try_max_count do
        local opt = io_read("*line")
        opt = tonumber(opt)
        if 1 == opt or 2 == opt then
            return opt
        end
        print("没有这个选项哦，请重新选择")
        try_count = try_count + 1
    end
    print("\n轰轰轰轰轰轰……\n")
    return 0
end
function GameAssistAPIMap.readSteps(try_max_count)
    try_max_count = try_max_count or 10
    local try_count = 0
    while try_count < try_max_count do
        local n = io_read("*line")
        n = tonumber(n)
        if nil ~= n and 0 < n then
            return n
        end
        print("你得给出一个合理的步数！比0大的那种")
        try_count = try_count + 1
    end
    print("\n轰轰轰轰轰轰……\n")
    return 0
end

