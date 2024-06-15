extends RestraintData
class_name RestraintLegCuffs

func _init():
	npcDodgeDifficultyMod = 1.1
	restraintType = RestraintType.AnkleCuffs

func defaultStruggle(_pc, _minigame, response):
	response = .defaultStruggle(_pc, _minigame, response)
	if !_pc.hasBlockedHands() && !_pc.hasBoundArms():
		response.text.append("{user.name} uses {user.his} hands to try and take off the {item.name}.")
	else:
		response.use.append("roll")
		response.text.append("{user.name} rolls around and tries to helplessly wiggle {user.his} {item.name} off.")
	return response


func failStruggle(_pc, _minigame, response):
	if failChance(_pc, 20):
		response.text.append("Ow! {user.name} accidently smashed them against "+RNG.pick(["the wall", "the ground", "something"])+".")
		response.pain += calcStrugglePain(_pc, RNG.randi_range(1, 3))
	else:
		response = .failStruggle(_pc, _minigame, response)
	return response

func getResistAnimation():
	return "struggle_legs"
