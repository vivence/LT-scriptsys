
local delay_time = 0.3

local space_size = 20
local goal_bonus = 9527
local chance = 3

local function _waitReturn(api_token)
	apiWait(api_token)
	return apiGetReturn(api_token)
end

local function tryOpen()
	local bonus, open_times, ex_chance = _waitReturn(post_openBox())
	if 1 < open_times then
		-- 重复开箱
		delay(delay_time)
		print(s_format("\n这好像是我之前开过的宝箱，%d这个数字我有印象", bonus))
		local rest_chance = getPlayerRestChance()
		if 0 < rest_chance then
			if 1 == rest_chance then
				delay(delay_time)
				print("啊啊啊！！！我简直愚蠢！")
				delay(delay_time)
				print("这下只剩最后一次机会了！")
			else
				delay(delay_time)
				print(s_format("哎~ 浪费了一次机会，还剩%d次！", rest_chance))
			end
		end
		delay(delay_time)
		print("\n让我检查一下之前开过哪些宝箱吧：")
		local opened_pos_map = getPlayerOpenedPosMap()
		for pos, bonus in pairs(opened_pos_map) do
			delay(delay_time)
			print(s_format("放在%d号位置的宝箱，宝物编号是：%d", pos, bonus))
		end
		return false
	end

	if bonus == goal_bonus then
		-- 找到宝物，游戏结束
		delay(delay_time)
		print("\n恭喜你，勇敢的冒险者")
		delay(delay_time)
		print(s_format("你不辱使命，找到了宝物%d", bonus))
		delay(delay_time)
        print("获得了荣耀！")
        delay(delay_time)
        print("\n请登录网站 https://edu.uwa4d.com 查收")
        return true
    else
    	-- 没找到宝物
    	local rest_chance = getPlayerRestChance()
    	delay(delay_time)
        print(s_format("\n很遗憾，%d并不是你要找的宝物%d", bonus, goal_bonus))
        if nil ~= ex_chance and 0 < ex_chance then
        	-- 意外收获，开到彩蛋宝箱
        	delay(delay_time)
            print("\n。。。。。。")
            delay(delay_time)
            print("等等，宝箱中里还藏有另外一个东西")
            delay(delay_time)
            print("。。。。。。")
            delay(delay_time)
            print("\n哇！！！意外收获")
            delay(delay_time)
            print(s_format("你获得了额外的%d次机会！", ex_chance))
            delay(delay_time)
            print(s_format("还可以再开%d个宝箱！", rest_chance))
        elseif 0 < rest_chance then
            if 1 == rest_chance then
            	delay(delay_time)
                print("\n小心为上，你只剩下最后一次机会了！")
            else
            	delay(delay_time)
                print(s_format("\n别气馁，你还有%d次机会呢~", rest_chance))
            end
        end
    end
    return false
end

local function move()
	delay(delay_time)
	print(s_format("\n你当前所处位置是%d，你要往前还是往后移动？", getPlayerPos()))
	delay(delay_time)
	print("\n1：勇往直前！")
	delay(delay_time)
	print("2：以退为进！")

	local dir = readOpt()
	if 1 == dir then
		-- 向前移动
		delay(delay_time)
		print("移动几步？")

		local steps = readSteps()
		local moved_steps = _waitReturn(post_moveForward(steps))
		if moved_steps ~= steps then
			if 0 < moved_steps then
				delay(delay_time)
				print(s_format("\n<<<一股神秘的力量只让你前进了%d步>>>\n", moved_steps))
			else
				delay(delay_time)
				print("\n<<<一股神秘的力量导致你原地不动>>>\n")
			end
		end
		return true
	elseif 2 == dir then
		-- 向后移动
		delay(delay_time)
		print("移动几步？")

		local steps = readSteps()
		local moved_steps = _waitReturn(post_moveBack(steps))
		if moved_steps ~= steps then
			if 0 < moved_steps then
				delay(delay_time)
				print(s_format("\n<<<一股神秘的力量只让你退后了%d步>>>\n", moved_steps))
			else
				delay(delay_time)
				print("\n<<<一股神秘的力量导致你原地不动>>>\n")
			end
		end
		return true
	else
		return false
	end
end

local function entrance1()
	print("\n哈哈，我果然没有看走眼，你是一位真正的勇士！")
	delay(delay_time)
	print("\n那么，让我来祝你一臂之力吧。。。")
	delay(delay_time)
	print("\n<<<一股神秘的力量将宝箱按照宝物编号从小到大排列起来了！>>>")

	-- 初始化游戏
	_waitReturn(post_initGame(space_size, goal_bonus, chance))

	-- 循环
	while true do
		delay(delay_time)
		print(s_format("\n你当前所处位置是%d", getPlayerPos()))
		delay(delay_time)
		print(s_format("还有%d次机会打开宝箱", getPlayerRestChance()))
		delay(delay_time)
		print("你要用掉1次机会打开当前位置的宝箱吗？")

		delay(delay_time)
		print("\n1：当然，逢宝必开才是冒险者！（大无畏）")
		delay(delay_time)
		print("2：不了，我还想到处逛逛！（有点怂）")

		local opt = readOpt()
		if 1 == opt then
			-- 尝试开箱
			if tryOpen() then
				return true
			end

			-- 没开中，检查剩余机会
			if 0 >= getPlayerRestChance() then
				delay(delay_time)
				print("\n可怜的冒险者啊~")
				delay(delay_time)
				print("你已经没有机会了！")
				delay(delay_time)
				print("这一路的艰辛终究还是一无所获！")
				delay(delay_time)
				print("\n「可能，这就是人生吧！」")
				delay(delay_time)
				print("\n再见！")
				return true
			elseif not move() then -- 没开中，直接开始移动
				return false
			end
		elseif 2 == opt then
			-- 移动
			if not move() then
				return false
			end
		else
			return false
		end

	end

	return true
end

local function entrance2()
	print("\n伟大的懦夫，你好！")
	delay(delay_time)
	print(s_format("在你的面前有%d个宝箱", space_size))
	delay(delay_time)
	print("每个宝箱里都有带编号的<高清无码小视频>")
	delay(delay_time)
	print(s_format("尤其是编号为%d的最为出色哦~", goal_bonus))
	delay(delay_time)
	print("要不要去找找看？")
	delay(delay_time)
	print("\n1：当然，高清无码，太良心了！")
	delay(delay_time)
	print("2：不了，虽然猜中更精彩，但是我是个蠢驴啊！直接看！！")

	local opt = readOpt()
	if 1 == opt then
		-- 回到第一种游戏模式
		delay(delay_time)
		entrance1()
		return true
	elseif 2 == opt then
		-- 第二种模式结束
		delay(delay_time)
		print("\n原来您是最为尊贵的蠢驴呀，失敬失敬。。。")
		delay(delay_time)
		print("请允许在下双手将链接奉上：<https://edu.uwa4d.com>")
		delay(delay_time)
		print("里面有好多优秀的小哥哥小姐姐在等您光临哦~")
		return true
	end
	return false
end

local function gameMain()
	print("勇敢的冒险者，你好！")
	delay(delay_time)
	print(s_format("在你的面前有%d个宝箱，每个宝箱里都有带编号的宝物", space_size))
	delay(delay_time)
	print(s_format("你的国王请求你帮他找到编号为%d的宝物", goal_bonus))
	delay(delay_time)
	print("你要接受这份委托，获得荣耀吗？")
	delay(delay_time)
	print("\n1：当然，作为一个冒险者，荣耀之于我就是生命！")
	delay(delay_time)
	print("2：不了，我是懦夫，不想冒险！")

	local opt = readOpt()
	if 1 == opt then
		-- 进入第一种游戏模式
		delay(delay_time)
		return entrance1(space_size, goal_bonus)
	elseif 2 == opt then
		-- 进入第二种游戏模式
		delay(delay_time)
		return entrance2(space_size, goal_bonus)
	end
	return false
end

local function proc( ... )
	print("\n<Game Start>\n")
	delay(1)

	-- 进入游戏
	gameMain()
	
	delay(1)
	print("\n<Game End>\n")
	delay(1)
end

-- 第一个为入口主函数
return {proc, gameMain, entrance1, entrance2, tryOpen, move, _waitReturn}



