extends RestraintChastityCage
	
func alwaysSavedWhenStruggledOutOf():
	return true

func canBreakLock(_pc, _minigame):
	return false 

func failStruggle(_pc, _minigame, response):
	if failChance(_pc, 30):
		response.text.append("{user.name}'s chastity cage BEEPS.. And then suddenly [b]shocks[/b] {user.his} {user.penis}!")
		response.pain += calcStrugglePain(_pc, 2)
	else:
		response.text.append("{user.name}'s chastity cage BEEPS.. But doesn't do anything to {user.him} this time. Phew.")
	return response


func sucessStruggleLocked(_pc, _minigame, response):
	response.text.append("Nothing despite best efforts, there's no way to escape as long as the thing is locked.")
	return response


func afterPick(_pc, _minigame, response):
	if failChance(_pc, 20):
		response.text.append("Opps, {user.name}'s chastity cage BEEPS.. And then suddenly [b]shocks[/b] {user.his} {user.penis}!")
		response.pain += calcPickPain(_pc, 1)
	elif failChance(_pc, 20):
		response.text.append("{user.name}'s chastity cage BEEPS.. But doesn't do anything to {user.him} this time. Phew.")

	return response
