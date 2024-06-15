extends RestraintData
class_name RestraintBlindfold

func _init():
	npcDodgeDifficultyMod = 0.8
	restraintType = RestraintType.Blindfold

func canInspectWhileBlindfolded():
	return true

func canUnlockWithKey():
	return false

func canBeCut():
	return true
	
func alwaysSavedWhenStruggledOutOf():
	return true

func shouldDoStruggleMinigame(_pc):
	if(!_pc.hasBoundArms()):
		return false
	return .shouldDoStruggleMinigame(_pc)


func defaultStruggle(_pc, _minigame, response):
	if !_pc.hasBoundArms() && !_pc.hasBlockedHands():
		response.text.append("Because {user.name}'s hands are free {user.he} manages to just untie {user.his} {item.name}.")
		response.damage = 1.0
		response.stamina = 0
		response.skipRest()
	elif !_pc.hasBoundArms():
		response.text.append("{user.name}'s hands are free but they are bound together so {user.name} has to awkwardly bend to reach {user.his} {item.name}.")
		response.damage = 1.0
		response.stamina = calcStruggleStamina(_pc, 0.5)
		response.skipRest()
	else:
		response.text.append("{user.name} shakes {user.his} head, trying to make the {item.name} slip off.")
		response.stamina += calcStruggleStamina(_pc, 1)
	return response
		
func fatalFailStruggle(_pc, _minigame, response):
	response.text.clear()
	response.text.append("{user.name} shakes {user.his} head, but the {item.name} unfortunately slip back.")
	response.damage = -1.0
	response.stamina += calcStruggleStamina(_pc, 1)
	return response

func getResistAnimation():
	return "struggle_gag"
