extends PerkBase

func _init():
	id = Perk.BDSMPerfectStreak
	skillGroup = Skill.BDSM

func getVisibleName():
	return "Perfect streak"

func getVisibleDescription():
	return "You learned how to find weak points of restraints, your struggling is more efficient."

func getSkillTier():
	return 1

func getPicture():
	return "res://Images/Perks/breaking-chain.png"

