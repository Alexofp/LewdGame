extends Reference
class_name ItemBase

var id = "baditem"
var uniqueID = null
var amount = 1
var currentInventory = null
var restraintData: RestraintData
var itemState: ItemState
var fluids: Fluids
var clothesColor: Color = Color.white

func _init():
	#if(uniqueID == null):
	#	uniqueID = "item"+str(GlobalRegistry.generateUniqueID())
	generateRestraintData()
	if(restraintData != null):
		restraintData.item = weakref(self)
		
	generateItemState()
	if(itemState != null):
		itemState.item = weakref(self)
	
	generateFluids()

func getVisibleName():
	return "Bad item"

func getCasualName():
	if(itemState == null):
		return getVisibleName()
	
	var theCasualName = itemState.getCasualName()
	if(theCasualName == null):
		return getVisibleName()
	return theCasualName

func getStackName():
	if(amount > 1):
		return ""+str(amount)+"x"+getVisibleName()
	else:
		return getVisibleName()

func getInventoryName():
	var theName = getStackName()
	if(fluids != null):
		if(fluids.isEmpty()):
			theName += " (empty)"
		else:
			if(fluids.isCapacityLimited()):
				theName += " ("+str(Util.roundF(fluids.getFluidAmount()))+"/"+str(Util.roundF(fluids.getCapacity(), 1))+" ml)"
			else:
				theName += " ("+str(Util.roundF(fluids.getFluidAmount()))+" ml)"
	elif(restraintData != null):
		if(currentInventory != null):
			if(!restraintData.hasSmartLock()):
				theName += " (Level "+restraintData.getVisibleLevel(GM.pc.isBlindfolded() && !GM.pc.canHandleBlindness())+")"
			else:
				theName += " (SMART-LOCKED)"
	return theName

# Hacky but good enough for most things, can always just override just function with a proper one
func getA():
	var visName = getVisibleName()
	
	if(visName.ends_with("s")):
		return ""
	if(visName.length() > 0 && visName[0].to_lower() in ["a", "e", "i", "o", "u"]):
		return "an"
	return "a"

func getAStackName():
	if(amount > 1):
		return ""+str(amount)+"x"+getVisibleName()
	else:
		return (getA() + " " + getVisibleName()).trim_prefix(" ")

func getAStackNameCapitalize():
	if(amount > 1):
		return ""+str(amount)+"x"+getVisibleName()
	else:
		return (getA().capitalize() + " " + getVisibleName()).trim_prefix(" ")

func getDescription():
	return "No description provided, please let the developer know"
	
func getVisisbleDescription():
	var text = getDescription()
	if(itemState != null):
		var extraDesc = itemState.getExtraDescription()
		if(extraDesc != null && extraDesc != ""):
			text += "\n"+extraDesc
	if(canDye()):
		text += "\n[color=gray]Color: "+str(clothesColor.to_html(false))+"[/color]"+" [color=#"+clothesColor.to_html(false)+"]###[/color]"
	if(hasTag(ItemTag.Illegal)):
		text += "\n[color=red]This item is illegal![/color]"
	if(addsIntoxication() > 0.0):
		text += "\n[color=red]Adds "+str(round(addsIntoxicationToPC()*100.0))+"% intoxication[/color]"
	
	if(fluids != null):
		if(fluids.isCapacityLimited()):
			text += "\n\nMax volume: "+str(Util.roundF(fluids.getFluidAmount()))+"/"+str(Util.roundF(fluids.getCapacity(), 1))+" ml"
		else:
			text += "\n"
		if(!fluids.isEmpty()):
			text += "\nContents:\n"+Util.join(fluids.getContentsHumanReadableArray(),"\n")
		else:
			text += "\nContents: Empty"
			
	var timedBuffs = getTimedBuffs()
	if(timedBuffs.size() > 0):
		var t = getBuffsDurationSeconds()
		var tstring = Util.getTimeStringHumanReadable(t)
		
		text += "\n- For the next "+tstring+":"
		for buff in timedBuffs:
			text += "\n" + "[color=#"+buff.getBuffColor().to_html(false)+"]" + buff.getVisibleDescription() + "[/color]"
	
	var turnBuffs = getTimedBuffsTurns()
	if(turnBuffs.size() > 0):
		var duration = getBuffsDurationTurns()
		
		text += "\n- Next "+str(duration)+" turns (in-fight only):"
		for buff in turnBuffs:
			text += "\n" + "[color=#"+buff.getBuffColor().to_html(false)+"]" + buff.getVisibleDescription() + "[/color]"
	
	var buffs = getBuffs()
	if(buffs.size() > 0):
		for buff in buffs:
			text += "\n" + "[color=#"+buff.getBuffColor().to_html(false)+"]" + buff.getVisibleDescription() + "[/color]"

	if(restraintData != null && restraintData.hasSmartLock()):
		var smartLock:SmartLockBase = restraintData.getSmartLock()
		text += "\n" + smartLock.getName()+": "+smartLock.getUnlockDescription()
	return text

func getCombatDescription():
	return getVisisbleDescription()

func getVisibleDescription(): # A TYPOOO
	return getVisisbleDescription()

func getUniqueID():
	assert(uniqueID != null)
	
	return uniqueID

func canCombine():
	return false
	
func tryCombine(_otherItem):
	amount += _otherItem.amount
	return true

func canUseInCombat():
	return false

func useInCombatWithBuffs(_attacker, _receiver):
	if(_attacker.isPlayer()):
		var intoxic = addsIntoxication()
		if(intoxic > 0.0):
			if(_attacker.isPlayer()):
				_attacker.addIntoxication(addsIntoxicationToPC())
			else:
				_attacker.addIntoxication(addsIntoxication())
			
		var timedBuffs = getTimedBuffs()
		if(timedBuffs.size() > 0):
			_attacker.addTimedBuffs(timedBuffs, getBuffsDurationSeconds())
		var turnBuffs = getTimedBuffsTurns()
		if(turnBuffs.size() > 0):
			_attacker.addTimedBuffsTurns(turnBuffs, getBuffsDurationTurns())
			
		#_attacker.updateNonBattleEffects()
	
	return useInCombat(_attacker, _receiver)

func useInCombat(_attacker, _receiver):
	return ""

func addsIntoxication() -> float:
	return 0.0
	
func addsIntoxicationToPC() -> float:
	return addsIntoxication() * GM.pc.getIntoxicationMod()

func destroyMe():
	if(currentInventory == null):
		return
	var invent = currentInventory
	invent.removeItem(self)
	invent.removeEquippedItem(self)

func removeXOrDestroy(remamount):
	amount -= remamount
	
	if(amount <= 0):
		destroyMe()

func setAmount(newamount):
	if(newamount > 1):
		assert(canCombine())
	amount = newamount

func getAmount():
	return amount

func splitAmount(howMuchTake:int):
	if(!canCombine()):
		return null
	
	if(howMuchTake <= 0):
		return null
	
	if(howMuchTake >= getAmount()):
		destroyMe()
		return self
	
	var itemCopy = GlobalRegistry.createItem(id)
	itemCopy.loadData(saveData())
	
	itemCopy.amount = howMuchTake
	amount -= howMuchTake
	
	return itemCopy

func getPossibleActions():
	return [
	]
	
func saveData():
	var data = {}
	
	data["amount"] = amount
	
	if(restraintData != null):
		data["restraintData"] = restraintData.saveData()

	if(itemState != null):
		data["itemState"] = itemState.saveData()

	if(fluids != null):
		data["fluids"] = fluids.saveData()

	if(canDye()):
		data["clothesColor"] = clothesColor.to_html()

	return data
	
func loadData(_data):
	amount = SAVE.loadVar(_data, "amount", 1)
	
	if(restraintData != null):
		restraintData.loadData(SAVE.loadVar(_data, "restraintData", {}))
		
	if(itemState != null && _data.has("itemState")):
		itemState.loadData(SAVE.loadVar(_data, "itemState", {}))

	if(fluids != null):
		fluids.loadData(SAVE.loadVar(_data, "fluids", {}))
	
	if(canDye()):
		if(_data.has("clothesColor")):
			clothesColor = Color(SAVE.loadVar(_data, "clothesColor", "white"))

func getClothingSlot():
	return null

func getRequiredBodypart():
	return null

func getTakeOffScene():
	return "TakeAnyItemOffScene"

func getPutOnScene():
	return "PutOnAnyItemScene"

func getBuffs():
	return []

func hasBuff(buffID):
	var thebuffs = getBuffs()
	if(thebuffs == null):
		return false
	
	for buff in thebuffs:
		if(buff.id == buffID):
			return true
	return false

func getTimedBuffs():
	return []

func getBuffsDurationSeconds():
	return 0

func getTimedBuffsTurns():
	return []

func getBuffsDurationTurns():
	return 0

func buff(buffid, args = []):
	var buff: BuffBase = GlobalRegistry.createBuff(buffid)
	buff.initBuff(args)
	return buff

func getPrice():
	return 0

func getBuyAmount():
	return 1

func getSellPrice():
	return int(getPrice() / 2.0 / getBuyAmount())

func getStackPrice():
	return int(getPrice() * amount)

func getStackSellPrice():
	return int(getSellPrice() * amount)

func canSell():
	return true

func getTakingOffStringLong(withS):
	if(withS):
		return "takes off your "+getVisibleName().to_lower()
	else:
		return "take off your "+getVisibleName().to_lower()

func getTakingOffVerb(withS):
	if(withS):
		return "takes off"
	else:
		return "take off"

func getPuttingOnStringLong(withS):
	if(withS):
		return "puts on your "+getVisibleName().to_lower()
	else:
		return "put on your "+getVisibleName().to_lower()

func getPuttingOnVerb(withS):
	if(withS):
		return "puts on"
	else:
		return "put on"

func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return getAStackNameCapitalize()+" was forced on you!"
	else:
		return getAStackNameCapitalize()+" was forced on {receiver.name}!"

func coversBodyparts():
	if(itemState != null):
		return itemState.coversBodyparts()
	return {}

func coversBodypart(bodypartSlot):
	var covers = coversBodyparts()
	if(covers.has(bodypartSlot)):
		return true
	return false

func getTags():
	return []

func hasTag(tag):
	if(getTags().has(tag)):
		return true
	return false

func generateItemState():
	if(getClothingSlot() != null):
		itemState = ItemState.new()

func getItemState():
	return itemState

func generateFluids():
	pass

func getFluids():
	return fluids

func setFluidsCauserID(_charID:String):
	if(fluids != null):
		fluids.setCauserID(_charID)

func isImportant():
	return false

func isRestraint():
	return restraintData != null

func generateRestraintData():
	pass

func getRestraintData() -> RestraintData:
	return restraintData

func setRestraintLevel(newlevel):
	if(restraintData != null):
		restraintData.setLevel(newlevel)

func calculateBestRestraintLevel():		
	if(GM.pc != null):
		var cLevel = 2 + pow(GM.pc.getLevel(), 0.8);
		return int(RNG.randf_rangeDis(1, cLevel))
	else:
		return RNG.randi_range(1, 5)

func canForceOntoNpc():
	return isRestraint()

func canForceOntoStaticNpc():
	return canForceOntoNpc()

func canBeEasilyRemovedByDom():
	if(restraintData != null):
		return restraintData.canBeEasilyRemovedByDom()
	return false

func onEquippedBy(_otherCharacter, _forced = false):
	pass

func tryAddSmartLock(_forcer, _addMessage = true):
	if(!isRestraint() || _forcer == null):
		return false
	if(_forcer is String):
		_forcer = GlobalRegistry.getCharacter(_forcer)
	
	var amountOfSmartLockedItems = 0
	var wearer = getWearer()
	if(wearer != null):
		amountOfSmartLockedItems = wearer.getInventory().getSmartLockedItemsAmount()
	
	# never veryrare rare normal often veryoften bdsmslut
	var rarityString = OPTIONS.getSmartLockRarity()
	
	var chanceLock = 8.0 - 2.0*amountOfSmartLockedItems
	
	if(rarityString == "veryrare"):
		chanceLock = 4.0 - 1.0*amountOfSmartLockedItems
	elif(rarityString == "rare"):
		chanceLock = 8.0 - 2.0*amountOfSmartLockedItems
	elif(rarityString == "normal"):
		chanceLock = 16.0 - 4.0*amountOfSmartLockedItems
	elif(rarityString == "often"):
		chanceLock = 24.0 - 6.0*amountOfSmartLockedItems
	elif(rarityString == "veryoften"):
		chanceLock = 32.0 - 8.0*amountOfSmartLockedItems
	elif(rarityString == "bdsmslut"):
		chanceLock = 60.0 - 10.0*amountOfSmartLockedItems
	elif(rarityString == "always"):
		chanceLock = 100.0
	elif(rarityString == "never"):
		return false
	
	if(chanceLock < 1.0):
		chanceLock = 1.0
		
	if(!RNG.chance(chanceLock)):
		return false

	return addRandomSmartLock(_forcer, _addMessage)

func addRandomSmartLock(_forcer, _addMessage = true):
	var randomLock = SmartLock.getRandomSmartLock()
	if(_forcer is String):
		_forcer = GlobalRegistry.getCharacter(_forcer)
	if(_forcer != null && _forcer.shouldBeExcludedFromEncounters() && randomLock == SmartLock.KeyholderLock):
		randomLock = SmartLock.TightLock # If we can't encouncter this npc, we can't our key back from them
	if(randomLock == SmartLock.SlutLock):
		var wearer = getWearer()
		if(wearer != null):
			wearer.updateNonBattleEffects() # Makes sure the bdsm restraint has added the buffs so impossible sluttasks won't generate
	return addSmartLock(randomLock, _forcer, _addMessage)

func addSmartLock(_lockID, _forcer, _addMessage = true):
	if(!isRestraint() || _forcer == null || (isWornByWearer() && !getWearer().isPlayer())):
		return false
	if(_forcer is String):
		_forcer = GlobalRegistry.getCharacter(_forcer)
	
	var theLock = SmartLock.create(_lockID)
	
	restraintData.setSmartLock(theLock)
	theLock.onLocked({forcer = _forcer})
	
	if(_addMessage && getWearer() == GM.pc):
		if(GM.main != null):
			GM.main.addMessage("A smartlocked restraint got forced onto you.")
	return true

func getUnriggedParts(_character):
	return null

func getRiggedParts(_character):
	return null

func getHidesParts(_character):
	if(itemState != null):
		return itemState.getHidesParts(_character)
	return null

func getHidesAttachments(_character):
	return null

func getLustActions():
	if(itemState != null):
		return itemState.getActions()
	return []

func resetLustState():
	if(itemState != null):
		return itemState.resetState()

func getAttacks():
	return null

func getWearer():
	if(currentInventory == null):
		return null
	
	return currentInventory.getCharacter()

func isWornByWearer():
	var wearer = getWearer()
	if(wearer == null):
		return false
	if(wearer.getInventory().getEquippedItem(getClothingSlot()) == self):
		return true
	return false

func updateWearerAppearance():
	var wearer = getWearer()
	if(wearer != null && wearer.has_method("updateAppearance")):
		wearer.updateAppearance()

func updateDoll(_doll: Doll3D):
	pass

func canDamage():
	if(itemState != null):
		return itemState.canDamage()
	return false

func receiveDamage():
	if(itemState != null):
		var theResult = itemState.receiveDamage()
		if(theResult != null && theResult[0]):
			updateWearerAppearance()
		return theResult
	return [false]

func isDamaged():
	if(itemState != null):
		return itemState.isDamaged()
	return false

func canRepair():
	if(itemState != null):
		return itemState.canRepair()
	return false

func repairDamage():
	if(itemState != null):
		itemState.repairDamage()
		updateWearerAppearance()

func alwaysVisible():
	return false

func shouldBeVisibleOnDoll(_character, _doll):
	return true

func onSexEvent(_event):
	if(restraintData != null):
		restraintData.handleSexEvent(_event)

func onSexEnded(_contex = {}):
	if(restraintData != null):
		restraintData.onSexEnded(_contex)

func onSexEnd():
	pass

func getAIForceItemWeight(_whoForcesNpc, _targetNpc):
	return 1.0

func getItemWeightForNpcGeneration():
	return 1.0

func useInSex(_receiver):
	return {
		text = "something something",
	}

func getItemCategory():
	if(restraintData != null):
		return ItemCategory.BDSM
	
	if(getClothingSlot() in [InventorySlot.UnderwearBottom, InventorySlot.UnderwearTop]):
		return ItemCategory.Underwear
	elif(getClothingSlot() != null):
		return ItemCategory.Clothes
	
	if(fluids != null):
		return ItemCategory.FluidStorage
	
	return ItemCategory.Generic

func isRemoved():
	if(itemState == null):
		return false
	return itemState.isRemoved()

func getChains():
	return null

func getInventoryImage():
	
	if(hasTag(ItemTag.SexEngineDrug)):
		return "res://Images/Items/medical/pill.png"
	
	if(hasTag(ItemTag.Condom)):
		return "res://Images/Items/medical/condom.png"
	
	if(getClothingSlot() == InventorySlot.Ring):
		return "res://Images/Items/equipment/ring.png"
	
	if(getClothingSlot() != null):
		return "res://Images/Items/equipment/shirt.png"
	
	return null

func getInventoryImageColor():
	return Color.white

func onUnequipped():
	if(itemState != null):
		itemState.resetState()

func isPersistent():
	return false

func alwaysRecoveredAfterSex():
	return false

func onDollUpdate(_doll : Doll3D, _zone, _dollpart):
	if(canDye() && _dollpart != null && _dollpart.has_method("setColor")):
		_dollpart.setColor(clothesColor)

func canDye():
	return false

func onDyed(_newColor:Color):
	if(canDye()):
		clothesColor = _newColor
		updateWearerAppearance()

func canGroupRestraintWithOtherInFightScene(otherItem):
	if(id != otherItem.id):
		return false
	if(restraintData == null || otherItem.restraintData == null):
		return false
	if(getRestraintData().getLevel() != otherItem.getRestraintData().getLevel()):
		return false
	if(canDye() && clothesColor != otherItem.clothesColor):
		return false
	return true

func getDatapackEditVars():
	var result = {}
	if(canDye()):
		result["clothesColor"] = {
			name = "Color",
			type = "color",
			value = clothesColor,
		}
	if(isRestraint() && restraintData != null):
		result["restraintLevel"] = {
			"name": "Restraint level",
			"type": "number",
			"int": true,
			"value": restraintData.getLevel(),
		}
		result["aiWontResist"] = {
			"name": "Disable ai struggle",
			"type": "checkbox",
			"value": restraintData.aiWontResist,
		}
	return result

func applyDatapackEditVar(_id, _value):
	if(_id == "clothesColor"):
		clothesColor = _value
	if(_id == "restraintLevel"):
		restraintData.setLevel(_value)
	if(_id == "aiWontResist"):
		restraintData.aiWontResist = _value
