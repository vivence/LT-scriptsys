
SpecialBonusBox = typesys.def.SpectialBonusBox {
	__super = BonusBox,
	_chance = 0,
}

function SpecialBonusBox:__ctor(bonus, chance)
	SpecialBonusBox.__super.__ctor(self, bonus)
	self._chance = chance
end

function SpecialBonusBox:getChance()
	return self._chance
end