extends RestraintData
class_name RestraintMittens

func _init():
	npcDodgeDifficultyMod = 1.2
	restraintType = RestraintType.Mittens

func canBeCut():
	return tightness < 0.9
	
func calcCutDamage(_pc, mult = 1.0):
	return .calcCutDamage(_pc, mult) / 1.4
	
func defaultStruggle(_pc, _minigame, response):
	if !_pc.hasBoundArms() && !_pc.hasBoundLegs():
		response.use.append("step")
		response.text.append("{user.name} steps on the mittens and tries to pull {user.his} arms out of them.")
	elif !_pc.hasBoundArms() && !_pc.isBitingBlocked():
		response.use.append("bite")
		response.text.append("{user.name} bites on one of the mittens and tries to free {user.his} arm. Not very effective but better than nothing.")
	else:
		response.use.append("smash")
		response.text.append("{user.name} tries to helplessly wiggle the mittens off.")
	response.stamina += calcStruggleStamina(_pc, 1)
	return response
	
