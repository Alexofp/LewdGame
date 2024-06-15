extends ItemBase

var currentColor = 0

func _init():
	id = "ChastityCageAdvanced"

func getVisibleName():
	return "Advanced Chastity Cage"
	
func getDescription():
	return "Prevents the ability to use your penis. This one is incredibly hard to take off and can also shock you! But at least it has a button to customize its color.."

func getClothingSlot():
	return InventorySlot.Penis

func getRequiredBodypart():
	return BodypartSlot.Penis

func getBuffs():
	return [
		buff(Buff.ChastityPenisBuff),
		]

func getTakeOffScene():
	return "RestraintTakeOffNopeScene"

func getPrice():
	return 40

func canSell():
	return true

func getTags():
	if(GM.main != null && GM.main.getFlag("AlexRynardModule.ch2DidChastityWith")):
		return [ItemTag.BDSMRestraint, ItemTag.ChastityCage, ItemTag.SoldByAlexRynard]
	return [ItemTag.BDSMRestraint, ItemTag.ChastityCage]

func isRestraint():
	return true

func generateRestraintData():
	restraintData = preload("res://Inventory/RestraintTypes/RestraintChastityCageAdvanced.gd").new()
	restraintData.setLevel(calculateBestRestraintLevel(3))
	restraintData.lockIt()

func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return getAStackNameCapitalize()+" was locked onto your penis, making it useless!"
	else:
		return getAStackNameCapitalize()+" was locked onto {receiver.nameS} penis, making it useless!"

func getRiggedParts(_character):
	if(currentColor == 1):
		return {
			"chastity_cage": "res://Inventory/RiggedModels/ShockCage/ShockCageLilac.tscn",
		}
	if(currentColor == 2):
		return {
			"chastity_cage": "res://Inventory/RiggedModels/ShockCage/ShockCageGeneral.tscn",
		}
	return {
		"chastity_cage": "res://Inventory/RiggedModels/ShockCage/ShockCage.tscn",
	}

func getHidesParts(_character):
	return {
		BodypartSlot.Penis: true,
	}

func shouldBeVisibleOnDoll(_character, _doll):
	if(!_character.isBodypartCovered(BodypartSlot.Penis) || _doll.isForcedExposed(BodypartSlot.Penis)):
		return true
	return false

func isImportant():
	return true

func getInventoryImage():
	if(currentColor == 1):
		return "res://Images/Items/bdsm/ShockCagePurple.png"
	if(currentColor == 2):
		return "res://Images/Items/bdsm/ShockCageOrange.png"
	return "res://Images/Items/bdsm/ShockCageRed.png"

func useInCombat(_attacker, _receiver):
	var text = "You toggle between the 3 available colors."
	
	currentColor += 1
	if(currentColor >= 3):
		currentColor = 0
	
	if(isWornByWearer()):
		updateWearerAppearance()
	
	return text

func getPossibleActions():
	return [
		{
			"name": "Change color",
			"scene": "UseItemLikeInCombatScene",
			"description": "Toggle between colors of your chastity cage",
		},
	]

func saveData():
	var data = .saveData()
	
	data["currentColor"] = currentColor
	
	return data
	
func loadData(data):
	.loadData(data)
	
	currentColor = SAVE.loadVar(data, "currentColor", 0)
