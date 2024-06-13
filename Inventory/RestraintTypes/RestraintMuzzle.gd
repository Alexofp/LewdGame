extends RestraintData
class_name RestraintMuzzle

func _init():
	restraintType = RestraintType.Muzzle

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
	var lockDamage = 0.0
	
	if(_handsFree && _armsFree):
		text = "{user.name} tugs on the straps of {user.his} head harness, trying to take it off."
		damage = calcDamage(_pc)
		stamina = 10
	else:
		text = "{user.name} desperately tries to wiggle the harness off {user.his} head."
		damage = calcDamage(_pc, 0.1)
		stamina = 5
	
		if(failChance(_pc, 40)):
			text += " Shaking {user.his} head so much makes {user.him} disoriented."
			pain = scaleDamage(5)
	
	if isLocked():
		lockDamage = RNG.randf_rangeDis(0, damage / 5) 
	
	return {"text": text, "damage": damage, "lockDamage": lockDamage, "lust": lust, "pain": pain, "stamina": stamina}

func getResistAnimation():
	return "struggle_gag"
