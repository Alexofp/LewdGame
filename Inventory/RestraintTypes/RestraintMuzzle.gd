extends RestraintData
class_name RestraintMuzzle

func _init():
	restraintType = RestraintType.Muzzle
	
func canBeCut():
	return tightness < 0.9
	
func calcCutDamage(_pc, mult = 1.0):
	return .calcCutDamage(_pc, mult) / 1.3

func defaultStruggle(_pc, _minigame, response):
	if !_pc.hasBoundArms() && !_pc.hasBlockedHands():
		response.use.append("hands")
		response.text.append("{user.name} tugs on the straps of {user.his} head harness, trying to take it off.")
		response.stamina += calcStruggleStamina(_pc, 1)
	else: 
		response.text.append("{user.name} desperately tries to wiggle the harness off {user.his} head.")
		response.stamina += calcStruggleStamina(_pc, 0.3) 
	return response

func fatalFailStruggle(_pc, _minigame, response):
	if response.use.has("hands"):
		response.text.append(" but it seems like {user.youHe} just tightened it up more.")
		response.damage += calcStruggleDamage(_pc, _minigame / 3.0)
		response.stamina += calcStruggleStamina(_pc, 1)
	else:
		response.stamina += calcStruggleStamina(_pc, 0.5)
		response.pain += calcStrugglePain(_pc, 1)
	return response

func failStruggle(_pc, _minigame, response):
	response.text.append(" but it seems kind of stuck.")
	return response

func afterStruggle(_pc, _minigame, response):
	if !response.use.has("hands") && (failChance(_pc, 30) || response.flow.has("fatal")):
		response.text.append("Shaking {user.his} head so much makes {user.him} disoriented.")
		response.pain += calcStrugglePain(_pc, 1)
	return response

func getResistAnimation():
	return "struggle_gag"
