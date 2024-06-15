extends RestraintData
class_name RestraintRopeHarness

func _init():
	restraintType = RestraintType.Harness

func canUnlockWithKey():
	return false
	
func canBeCut():
	return true

func defaultStruggle(_pc, _minigame, response):
	if (!_pc.hasBoundArms() || !_pc.hasBlockedHands()) && _pc.isBlindfolded():
		response.text.append("{user.name} tries to blindly find the knot to tug on.")
	else:
		response.text.append("{user.name} tries to wiggle the rope harness off.")
	response.stamina += calcStruggleStamina(_pc, 1)
	return response

func processStruggleTurn(_pc, _isActivelyStruggling):
	var response = .processStruggleTurn(_pc, _isActivelyStruggling)
	if failChance(_pc, 10) || _isActivelyStruggling:
		response.text.append(RNG.pick(["{user.nameS} rope harness rubs against one of {user.his} nips", "{user.nameS} rope harness digs into {user.his} crotch"]))
		response.lust += calcStruggleLust(_pc, 1)
	return response
