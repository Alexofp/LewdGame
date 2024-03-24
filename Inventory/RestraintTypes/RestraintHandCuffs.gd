extends RestraintData
class_name RestraintHandCuffs

func _init():
	restraintType = RestraintType.WristCuffs

func calcRestrainMult(_pc, _minigame):
	var mult = 1.0
	if _pc.isBlindfolded():
		if _pc.hasPerk(Perk.BDSMBlindfold):
			mult = 0.9
		mult = 0.7

	if _pc.isBitingBlocked() && _pc.hasBlockedHands():
		if _pc.hasPerk(Perk.BDSMPerfectStreak):
			mult *= 0.6
		else:
			mult *= 0.3
	elif _pc.isBitingBlocked() || _pc.hasBlockedHands():
		if _pc.hasPerk(Perk.BDSMPerfectStreak):
			mult *= 0.8
		else:
			mult *= 0.6
	return mult


func defaultStruggle(_pc, _minigame, response):
	response = .defaultStruggle(_pc, _minigame, response)
	if !_pc.hasBlockedHands() && !_pc.isBitingBlocked():
		response.use.append("mouth")
		response.text.append("{user.name} uses {user.his} hands and mouth to try and take off the {item.name}.")
	elif !_pc.hasBlockedHands():
		response.text.append("{user.name} can't use {user.his} mouth but {user.he} can just about reach the {item.name} with {user.his} hands. {user.name} is tugging on the restrant, trying to slip it off.")
	elif !_pc.isBitingBlocked():
		response.use.append("mouth")
		response.text.append("{user.name} is trying to wiggle the {item.name} off. Not being able to use hands really sucks but using {user.his} mouth instead helps {user.him} to keep them still.")
	return response

func failStruggle(_pc, _minigame, response):
	if failChance(_pc, 20):
		response.text.append("Ow! {user.name} accidently smashed them against "+RNG.pick(["the wall", "the ground", "something"])+".")
		response.pain += calcStrugglePain(_pc, RNG.randi_range(1, 3))
	else:
		response = .failStruggle(_pc, _minigame, response)
	return response

func afterStruggle(_pc, _minigame, response):
	if failChance(_pc, 20) && response.use.has("mouth"):
		response.text.append("{user.name} finds {user.himself} drooling a lot.")
		response.lust += calcStruggleLust(_pc, 2)
	return response
