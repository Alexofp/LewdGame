extends ItemBase

var programmedToSuppressPerkId: String = ""

func _init():
	id = "HypnovisorMk1"

func getVisibleName():
	return "Hypnovisor Mk1"
	
func getDescription():
	return "Special prototype goggles that were developed by Alex Rynard to help cure depression. What the heck is a 'YOT'?"

func getClothingSlot():
	return InventorySlot.Eyes
	
func getTakeOffScene():
	return "RestraintTakeOffNopeScene"
	
func getBuffs():
	if(isWornByWearer() and getWearer().hasPerk(Perk.HypnosisHATS) and HypnokinkUtil.isInTrance(getWearer())):
		return [buff(Buff.AmbientLustBuff, [300]), buff(Buff.AccuracyBuff, [25])]
	else:
		return [buff(Buff.AmbientLustBuff, [300]), buff(Buff.AccuracyBuff, [-25])]
	
func getPossibleActions():
	if(isWornByWearer()):
		var wearer = getWearer()
		if(wearer.hasPerk(Perk.HypnosisVisorMastery)):
			return [{
					"name": "Program",
					"scene": "ProgramVisorScene",
					"description": "Program the visor to suppress one of your drawback perks",
					"onlyWhenCalm": true
				}]
	return []
	
func getPrice():
	return 60

func canSell():
	return true

func getTags():
	if(GM.main != null && GM.main.getFlag("AlexRynardModule.ch1HypnovisorHappened")):
		return [ItemTag.BDSMRestraint, ItemTag.Hypnovisor, ItemTag.SoldByAlexRynard]
	return [ItemTag.BDSMRestraint, ItemTag.Hypnovisor]

func isRestraint():
	return true

func generateRestraintData():
	restraintData = RestraintHypnovisor.new()
	restraintData.setLevel(calculateBestRestraintLevel())
	
func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return getAStackNameCapitalize()+" was forced over your eyes."
	else:
		return getAStackNameCapitalize()+" was forced over {receiver.nameS} eyes!"

func onEquippedBy(_otherCharacter, _forced = false):
	if(not _forced):
		return
	var wearer = getWearer()
	var currentAmount = HypnokinkUtil.getSuggestibleStacks(wearer)
	if(_otherCharacter.hasPerk(Perk.HypnosisVisorMastery) and currentAmount < 50):
		HypnokinkUtil.changeSuggestibilityBy(wearer, 50 - currentAmount)
	elif(_otherCharacter.hasPerk(Perk.HypnosisGoodAtVisors) and currentAmount < 30):
		HypnokinkUtil.changeSuggestibilityBy(wearer, 30 - currentAmount)
	
func programToSuppressPerk(perkId: String):
	programmedToSuppressPerkId = perkId
	
func programmedToSuppressPerk() -> String:
	return programmedToSuppressPerkId
	
func maxHypnosisStacks() -> int:
	return 125
	
func saveData():
	return {
		"programmedToSuppressPerkId": programmedToSuppressPerkId,
	}
	
func loadData(_data):
	programmedToSuppressPerkId = SAVE.loadVar(_data, "programmedToSuppressPerkId", "")

func getUnriggedParts(_character):
	return {
		"blindfold": ["res://Inventory/UnriggedModels/HypnoVisor/HypnoVisor.tscn"],
	}

func getInventoryImage():
	return "res://Images/Items/bdsm/hypnovisor.png"
