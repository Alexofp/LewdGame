extends "res://Inventory/RestraintTypes/RestraintButtplug.gd"
class_name RestraintVaginalplug

func _init():
	npcDodgeDifficultyMod = 1.5
	restraintType = RestraintType.VaginalPlug

var turnedOn = false

func defaultStruggle(_pc, _minigame, response):
	if !_pc.hasBoundArms() && !_pc.hasBlockedHands():
		response.text.append("Because {user.name}'s hands are free {user.he} just {user.verbS('remove')} the plug.")
		response.damage = 1.0
		response.stamina = 0
		response.skipRest()
	elif !_pc.hasBoundLegs():
		response.use.append("legs")
		response.text.append("{user.name} squirms and wiggles {user.his} rear, trying to push the plug out of {user.his} pussy.")
	else:
		response.text.append("{user.name} desperatelly squirms, trying to push the vaginal plug out. Not being able to spread {user.his} legs makes it very hard.")
	return response

func sucessStruggle(_pc, _minigame, response):
	response = .sucessStruggle(_pc, _minigame, response)
	if(!turnedOn && failChance(_pc, 40)):
		response.text.append("{user.name} accidentally turns on the plug inside {user.him} and it starts vibrating!")
		turnedOn = true
	elif(turnedOn && failChance(_pc, 20)):
		response.text.append("{user.name} managed to randomly turn off the vibrating plug.")
		turnedOn = false
	return response
	

func processStruggleTurn(_pc, _isActivelyStruggling):
	var response = ResponseData.new(getItem().getVisibleName())
	if(turnedOn):
		response.text.append("The vaginal plug strongly vibrates inside {user.nameS} pussy.")
		response.lust += calcStruggleLust(_pc, 2)
	else:
		if(failChance(_pc, 5) || (_isActivelyStruggling && failChance(_pc, 30))):
			turnedOn = true
			response.text.append("[b]The plug inside {user.nameS} pussy accidentally turns on[/b]. It vibrates, bringing {user.him} pleasure!")
	return response
	
	
func resetOnNewDay():
	.resetOnNewDay()
	turnedOn = false

func resetOnNewTry():
	.resetOnNewTry()
	#tightness = 1

func onStruggleRemoval():
	.onStruggleRemoval()
	turnedOn = false

func saveData():
	var data = .saveData()
	
	data["turnedOn"] = turnedOn

	return data
	
func loadData(_data):
	.loadData(_data)
	
	turnedOn = SAVE.loadVar(_data, "turnedOn", false)
