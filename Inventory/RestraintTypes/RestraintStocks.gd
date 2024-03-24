extends RestraintData
class_name RestraintStocks

func resetOnNewDay():
	pass

func getVisibleTightness():
	if(tightness > 0.9):
		return "very sturdy"
	if(tightness > 0.8):
		return "sturdy"
	if(tightness > 0.7):
		return "sturdy enough"
	if(tightness > 0.6):
		return "gives in a little bit"
	if(tightness > 0.5):
		return "gives some leeway"
	if(tightness > 0.4):
		return "quite a bit of leeway"
	if(tightness > 0.3):
		return "kinda close to escaping"
	if(tightness > 0.2):
		return "close to escaping"
	if(tightness > 0.1):
		return "very close to escaping"
	return "you're almost free"

func getRemoveMessage():
	return "Stocks miraculously give in and let you free your arms and head"

func alwaysBreaksWhenStruggledOutOf():
	return true

func calcStruggleStamina(_pc, mult = 1.0):
	return .calcStruggleStamina(_pc, mult * 2.0)

func calcStruggleDamage(_pc, mult = 1.0):
	return .calcStruggleDamage(_pc, mult / 2.0)

func defaultStruggle(_pc, _minigame, response):
	response = .defaultStruggle(_pc, _minigame, response)
	if(!_pc.hasBoundLegs()):
		response.text.append("{user.name} wiggles {user.his} whole body to try to escape.")
	else:
		response.text.append("{user.name} helplessly wiggles {user.his} body, having {user.his} legs restrained makes this pretty much uselss.")
	return response

func failStruggle(_pc, _minigame, response):
	response.text.append(" but just ends up more tired.")
	response.stamina += calcStruggleStamina(_pc, 0.5)
	return response

func fatalFailStruggle(_pc, _minigame, response):
	response.text.append(" but it seems like {user.youHe} just hurt yourself.")
	response.pain += calcStrugglePain(_pc, 1)
	return response
