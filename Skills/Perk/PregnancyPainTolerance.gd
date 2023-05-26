extends PerkBase

func _init():
	id = Perk.PregnancyPainTolerance
	skillGroup = Skill.Pregnancy

func getVisibleName():
	return "Pain tolerance"

func getVisibleDescription():
	return "Life in prison is tough especially if you are constantly being pregnant, all the challenges that you have overcome made you much sturdier. \n" \
			+ "Resistance to physical damage +15% \n" \
			+ "Maximum stamina +30" #maybe add some percentage total, like +10% total stamina
	
func getSkillTier():
	return 2

func getPicture():
	return "res://Images/Perks/Skill_Icon_PregnancyPainTolerance.png"

#func getBuffs():
#	return [
#		buff(Buff.ReceivedPhysicalDamageBuff, [-15]),
#		buff(Buff.MaxStaminaBuff, [30.0])
#	]
