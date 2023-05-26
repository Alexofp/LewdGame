extends PerkBase

func _init():
	id = Perk.PregnancyBetterOvulation
	skillGroup = Skill.Pregnancy

func getVisibleName():
	return "Better ovulation"

func getVisibleDescription():
	return "Your body is adapting to produce more offspring. Amount of the egg cells you release during each ovulation phase is increased."

func getSkillTier():
	return 0

func getPicture():
	return "res://Images/Perks/Skill_Icon_PregnancyBetterOvulation.png"

#func getBuffs():
#
#	return [
#		buff(Buff.OvulationEggsAmountBuff, [150]),
#		buff(Buff.MinOvulationEggsAmountBuff, [3])
#	]

