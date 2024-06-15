extends RestraintData
class_name RestraintChastityCage

func _init():
	restraintType = RestraintType.ChastityCage

func defaultStruggle(_pc, _minigame, response):
	if !_pc.hasBlockedHands() && !_pc.hasBoundArms():
		response.text.append("{user.name} tugs on {user.his} chastity cage, trying to take it off.")
	else:
		response.text.append("{user.name} desperately tries to wiggle {user.his} chastity cage off but makes almost no progress.")
	response.stamina += calcStruggleStamina(_pc, 1)
	return response

func afterStruggle(_pc, _minigame, response):
	if !_pc.hasBlockedHands() && !_pc.hasBoundArms() && failChance(_pc, 30):
		response.text.append("Touching {user.his} caged cock made {user.him} quite aroused.")
		response.lust += calcStruggleLust(_pc, 1)
	elif failChance(_pc, 30) || response.flow.has("fatal"):
		response.text.append("{user.He} accidentally pinched {user.his} balls. Ow.")
		response.pain += calcStrugglePain(_pc, 1)
	return response

func afterPick(_pc, _minigame, response):
	if !_pc.hasBlockedHands() && !_pc.hasBoundArms() && failChance(_pc, 20):
		response.text.append("Touching {user.his} caged cock made {user.him} quite aroused.")
		response.lust += calcPickLust(_pc, 1)
	elif failChance(_pc, 20):
		response.text.append("{user.He} accidentally pinched {user.his} balls. Ow.")
		response.pain += calcPickPain(_pc, 1)
	return response
