
BonusBox = typesys.def.BonusBox {
	_bonus = 0,
	_open_times = 0,
}

function BonusBox:__ctor(bonus)
	self._bonus = bonus
end

function BonusBox:open()
	self._open_times = self._open_times + 1
	return self._bonus, self._open_times
end

function BonusBox:getChance()
	return 0
end