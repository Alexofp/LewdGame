extends PerkBase

func _init():
	id = Perk.BDSMInstantEscape
	skillGroup = Skill.BDSM

func getVisibleName():
	return "Instant gratification"

func getVisibleDescription():
	return "You've fought in restraints so many times that you can escape from the simpler ones almost instantly."

func getSkillTier():
	return 2

func getPicture():
	return "res://Images/Perks/slavery.png"

