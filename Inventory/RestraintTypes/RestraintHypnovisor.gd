extends "res://Inventory/RestraintTypes/RestraintBlindfold.gd"
class_name RestraintHypnovisor

func _init():
	npcDodgeDifficultyMod = 0.8
	restraintType = RestraintType.HypnoVisor

func calcStruggleDamage(_pc, mult = 1.0):
		if HypnokinkUtil.isHypnotized(_pc):
			return .calcStruggleDamage(_pc, mult) * 0.2
		return .calcStruggleDamage(_pc, mult)


func shouldDoStruggleMinigame(_pc):
	if HypnokinkUtil.isInTrance(_pc) && !_pc.hasPerk(Perk.HypnosisGoodAtVisors):
		return false #cannot succeed
	if HypnokinkUtil.isHypnotized(_pc):
		return true
	return .shouldDoStruggleMinigame(_pc)
	
func defaultStruggle(_pc, _minigame, response):
	if HypnokinkUtil.isInTrance(_pc) && !_pc.hasPerk(Perk.HypnosisGoodAtVisors):
		response.text.append("{user.name} tries to... to... \n\nDo what? Must have not been important.")
		response.damage = 0.0
		response.skipRest()
		return response
	
	if !HypnokinkUtil.isHypnotized(_pc):
		return .defaultStruggle(_pc, _minigame, response)
		
	if !_pc.hasBoundArms():
		response.text.append("Hypnotized {user.name} reaches up, trying to focus on removing {user.his} {item.name}.")
	else:
		response.text.append("Hypnotized {user.name} shakes {user.his} head, trying to dislodge {user.his} {item.name}.")
	return response

func getResistAnimation():
	return "struggle_gag"

func processStruggleTurn(_pc, _isActivelyStruggling):
	var response = .processStruggleTurn(_pc, _isActivelyStruggling)
	if failChance(_pc, 30) || _isActivelyStruggling:
		if getItem().id == "HypnovisorMk0":
			response.text.append(RNG.pick([
				"Pretty spiral..",
				"Need to be useful..",
				"{user.name} should keep {user.his} visor on, for {user.his} own safety..",
				"{user.name} wants to be a good {user.boy}..",
				"Must.. Obey?",
				"{user.name} struggles to look away from the flashing images.",
				"{user.name} struggles to look away from the spinning spiral.",
			]))
		else:
			response.text.append(RNG.pick([
				"The lights are so colorful..",
				"Toy.. pet.. Toy.. pet..",
				"{user.name} wants to be a good pet..",
				"{user.name} wants to be a good toy..",
				"Colorful lights are so hypnotizing..",
				"Must.. Obey?",
				"{user.name} struggles to look away from the colorful lights.",
			]))
		response.lust += calcStruggleLust(_pc, 1)
		if _isActivelyStruggling:
			response.lust += calcStruggleLust(_pc, 1)

	return response
