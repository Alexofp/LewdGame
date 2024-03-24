extends "res://Inventory/RestraintTypes/RestraintBallGag.gd"
class_name RestraintRingGag

func _init():
	restraintType = RestraintType.Gag

func calcCutDamage(_pc, mult = 1.0):
	return .calcCutDamage(_pc, mult) / 1.1

func defaultStruggle(_pc, _minigame, response):
	if !_pc.hasBoundArms() && !_pc.hasBlockedHands():
		response.use.append("hands")
		response.text.append("{user.name} tugs on the straps of {user.his} head harness, trying to take it off.")
		response.stamina += calcStruggleStamina(_pc, 1)
	else:
		response.text.append("{user.name} tries to bite down on the ring in {user.his} mouth although the rubber makes it very tough.")
		response.stamina += calcStruggleStamina(_pc, 0.5) 
	return response

func fatalFailStruggle(_pc, _minigame, response):
	if response.use.has("hands"):
		response.text.append(" but it seems like {user.youHe} just tightened it up more.")
		response.damage += calcStruggleDamage(_pc, _minigame / 4.0)
		response.stamina += calcStruggleStamina(_pc, 1)
	else:
		response.text.append(" but the ring just stuck in {user.his} mouth.")
		response.pain += calcStrugglePain(_pc, 0.3)
	return response

func failStruggle(_pc, _minigame, response):
	response.text.append(" but it seems kind of stuck.")
	return response

func afterStruggle(_pc, _minigame, response):
	if(failChance(_pc, 25)):
		response.text.append("The ring in {user.his} mouth makes {user.him} drool a lot.")
		response.lust += calcStruggleLust(_pc, 1)
	return response
