extends RestraintData
class_name RestraintRopeHarness

func _init():
	restraintType = RestraintType.Harness

func canUnlockWithKey():
	return false
	
func canBeCut():
	return true

func doFailingStruggle(_pc, _minigame):
	return doStruggle(_pc, _minigame)

func doStruggle(_pc, _minigame):
	var _handsFree = !_pc.hasBlockedHands()
	var _armsFree = !_pc.hasBoundArms()
	var _legsFree = !_pc.hasBoundLegs()
	var _canSee = !_pc.isBlindfolded()
	var _canBite = !_pc.isBitingBlocked()
	
	var text = "error?"
	var lust = 0
	var pain = 0
	var damage = 0
	var stamina = 0
	
	if(_armsFree && _handsFree):
		text = "{user.name} tries to blindly find the knot to tug on"
		damage = calcDamage(_pc)
		stamina = 10
		lust = scaleDamage(5)
	else:
		text = "{user.name} tries to wiggle the rope harness off"
		damage = calcDamage(_pc, 0.5)
		stamina = 10
		lust = scaleDamage(5)
	if fatalFail(_minigame):
		text += " but it seems like {user.youHe} just tightened it up more"
		damage = -damage/2
	return {"text": text, "damage": damage, "lust": lust, "pain": pain, "stamina": stamina}

func processStruggleTurn(_pc, _isActivelyStruggling):
	if(failChance(_pc, 10) || _isActivelyStruggling):
		return {"text": RNG.pick(["{user.nameS} rope harness rubs against one of {user.his} nips", "{user.nameS} rope harness digs into {user.his} crotch"]), "lust": scaleDamage(5)}
