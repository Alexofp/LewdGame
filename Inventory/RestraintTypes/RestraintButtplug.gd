extends RestraintData
class_name RestraintButtplug

func _init():
	npcDodgeDifficultyMod = 1.5
	restraintType = RestraintType.ButtPlug

func canUnlockWithKey():
	return false
	
func canBeLocked():
	return false

func alwaysSavedWhenStruggledOutOf():
	return true

func shouldDoStruggleMinigame(_pc):
	if !_pc.hasBoundArms() && !_pc.hasBlockedHands() && !isLocked():
		return false
	return .shouldDoStruggleMinigame(_pc)


func defaultStruggle(_pc, _minigame, response):
	if !_pc.hasBoundArms() && !_pc.hasBlockedHands():
		response.text.append("Because {user.name}'s hands are free {user.he} {user.verbS('manage')} to just remove the buttplug.")
		response.damage = 1.0
		response.stamina = 0
		response.skipRest()
	elif !_pc.hasBoundLegs():
		response.use.append("legs")
		response.text.append("{user.name} squirms and wiggles {user.his} rear, trying to push the buttplug out of {user.his} butt.")
	else:
		response.text.append("{user.name} desperatelly squirms, trying to make the buttplug fall out. Not being able to spread {user.his} legs makes it very hard.")
	return response
		
func fatalFailStruggle(_pc, _minigame, response):
	response.text.clear()
	response.text.append("{user.name} desperatelly squirms, trying to make the {item.name} fall out but it slipped back.")
	response.damage = -1.0
	response.lust += calcStruggleLust(_pc, 5)
	return response
	
func failStruggle(_pc, _minigame, response):
	if response.use.has("legs"):
		response.text.append(" but without visible effect.")
	else: 
		response.text.append("No surprise that the plug didn't move out even a bit.")
	return response	
	
func sucessStruggle(_pc, _minigame, response):
	response.damage += calcStruggleDamage(_pc, _minigame) * calcRestrainMult(_pc, _minigame)
	if _pc.isPlayer() && failChance(_pc, 40) && GM.pc.getInventory().hasSlotEquipped(InventorySlot.UnderwearBottom):
		if(_pc.getInventory().getEquippedItem(InventorySlot.UnderwearBottom).coversBodypart(BodypartSlot.Vagina)):
			response.text.append("The plug presses into your panties.")
			response.damage /= 2.0

			if(failChance(_pc, 30)):
				response.text.append("[b]Your panties slipped down, oops.[/b]")
				_pc.getInventory().unequipSlot(InventorySlot.UnderwearBottom)
	return response
	

func processStruggleTurn(_pc, _isActivelyStruggling):
	var response = .processStruggleTurn(_pc, _isActivelyStruggling)
	if(failChance(_pc, 10) || _isActivelyStruggling):
		response.text.append("The buttplug shifts inside {user.name} while {user.he} {user.verbS('squirm')}")
		response.lust += calcStruggleLust(_pc, 1)
	return response
