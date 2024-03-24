extends SexActivityBase

var pcUniqueID = ""
var npcItemID = ""

func _init():
	id = "DomBondage"
	startedByDom = true
	startedBySub = false

func getGoals():
	return {
		SexGoal.TieUp: 1.0,
	}

func getSupportedSexTypes():
	return {
		SexType.DefaultSex: true,
		SexType.StocksSex: true,
	}

func isStocksSex():
	return getSexEngine().getSexTypeID() == SexType.StocksSex

func getActivityBaseScore(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var mult = 1.0
	# Inmates don't have much bdsm gear
	if(_domInfo.getChar().getCharacterType() == CharacterType.Inmate):
		mult = 0.1
	return 0.0 + _domInfo.fetishScore({Fetish.Rigging: 0.1}) * mult

func getVisibleName():
	return "Bondage"

func getCategory():
	return ["Bondage"]

func getDomTags():
	return []

func getSubTags():
	return [SexActivityTag.BeingUndressed]

func getStartActions(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var actions = []
	var dom:BaseCharacter = _domInfo.getChar()
	var sub:BaseCharacter = _subInfo.getChar()
	
	var usableItems = []
	
	if(_domInfo.getChar().isPlayer()):
		if(_subInfo.getChar().isDynamicCharacter()):
			usableItems = dom.getInventory().getAllCombatUsableRestraints()
		else:
			usableItems = dom.getInventory().getAllCombatUsableRestraintsForStaticNpc()
	else:
		var itemTagToUse = ItemTag.CanBeForcedByGuards
		if(_sexEngine.getSexTypeID() == SexType.StocksSex):#(isStocksSex()):
			itemTagToUse = ItemTag.CanBeForcedInStocks
		
		var possibleRestraints = sub.getInventory().getRestraintsThatCanBeForcedDuringSex(itemTagToUse)
		
		for possibleRestraintID in possibleRestraints:
			var item:ItemBase = GlobalRegistry.getItemRef(possibleRestraintID)
			if(_domInfo.goalsScore({SexGoal.FuckOral: 1.0}, _subInfo.charID) > 0.0 || _domInfo.goalsScore({SexGoal.BreastFeedSub: 1.0}, _subInfo.charID) > 0.0 || _sexEngine.hasTag(subID, SexActivityTag.MouthUsed)):
				if(item.getClothingSlot() == InventorySlot.Mouth):
					if(!item.hasBuff(Buff.RingGagBuff)):
						continue
			
			usableItems.append(item)
		
	var countsByItemID = {}
	if(_domInfo.getChar().isPlayer()):
		for item in usableItems:
			if(!countsByItemID.has(item.id)):
				countsByItemID[item.id] = 1
			else:
				countsByItemID[item.id] += 1
		
	#var canActuallyPutOn = 0
	for item in usableItems:
		var itemSlot = item.getClothingSlot()
		var bodypartSlot = item.getRequiredBodypart()
		
		if(item.getRequiredBodypart() == BodypartSlot.Vagina && _subInfo.hasTag(SexActivityTag.VaginaPenetrated)):
			continue
		if(item.getRequiredBodypart() == BodypartSlot.Anus && _subInfo.hasTag(SexActivityTag.AnusPenetrated)):
			continue
		if(item.getRequiredBodypart() == BodypartSlot.Penis && _subInfo.hasTag(SexActivityTag.PenisUsed)):
			continue
		
		if(bodypartSlot != null && sub.getFirstItemThatCoversBodypart(bodypartSlot) != null):
			continue
		elif(!sub.invCanEquipSlot(itemSlot)):
			continue
		elif(sub.getInventory().hasSlotEquipped(itemSlot) && sub.getInventory().getEquippedItem(itemSlot)!=null && !sub.getInventory().getEquippedItem(itemSlot).isRemoved()):
			continue
		else:
			var restraintData:RestraintData = item.getRestraintData()
			if(restraintData == null):
				continue
			
			if(_domInfo.getChar().isPlayer()):
				actions.append({
					name = item.getVisibleName(),
					args = ["pc", item.uniqueID],
					score = getActivityScore(_sexEngine, _domInfo, _subInfo),
					category = (getCategory() if (!countsByItemID.has(item.id) || countsByItemID[item.id] <= 1) else (getCategory() + [str(countsByItemID[item.id])+"x"+item.getVisibleName()])),
					desc = "Restraint level: "+str(restraintData.getLevel()) + "\n" + item.getCombatDescription(),
				})
			else:
				#canActuallyPutOn += 1
				actions.append({
					name = item.getVisibleName(),
					args = ["npc", item.id],
					score = getActivityScore(_sexEngine, _domInfo, _subInfo) * item.getAIForceItemWeight(),
					category = getCategory(),
					desc = "Restraint level: "+str(restraintData.getLevel()) + "\n" + item.getCombatDescription(),
				})
	
	#if(!dom.isPlayer() && canActuallyPutOn == 0):
	#	_sexEngine.satisfyGoal(_domInfo, SexGoal.TieUp, _subInfo)
	if(dom.isPlayer() && !dom.hasBlockedHands() && !dom.hasBoundArms()):
		var allSubRestraints = sub.getInventory().getEquippedRestraints()
		
		for item in allSubRestraints:
			if(!item.canBeEasilyRemovedByDom()):
				continue
			var restraintData:RestraintData = item.getRestraintData()
			if(restraintData == null):
				continue
				
			actions.append({
				name = item.getVisibleName(),
				args = ["rem", item.uniqueID],
				score = 0.0,
				category = ["Bondage", "Take off"],
				desc = "Status: "+restraintData.getVisibleTightness()+"\nRestraint level: "+str(restraintData.getLevel()) + "\n" + item.getCombatDescription(),
			})
	
	return actions

func startActivity(_args):
	state = ""
	
	subInfo.addResistance(subInfo.fetishScore({Fetish.Bondage: -0.5})+0.3-subInfo.personalityScore({PersonalityStat.Subby: 0.2}))
	subInfo.addLust(subInfo.fetishScore({Fetish.Bondage: 1.0}) * 20)
	
	if(_args[0] == "pc"):
		pcUniqueID = _args[1]
		
		var item = getDom().getInventory().getItemByUniqueID(pcUniqueID)
		return {
			text = "{dom.You} {dom.youVerb('attempt')} to force "+str(item.getAStackName())+" onto {sub.you}!",
		}
	if(_args[0] == "npc"):
		npcItemID = _args[1]
	
		var item = GlobalRegistry.getItemRef(npcItemID)
		return {
			text = "{dom.You} {dom.youVerb('attempt')} to force "+str(item.getAStackName())+" onto {sub.you}!",
		}
	if(_args[0] == "rem"):
		endActivity()
		var itemUniqueID = _args[1]
		var item:ItemBase = getSub().getInventory().getItemByUniqueID(itemUniqueID)
		if(item == null):
			return
		var restraintData:RestraintData = item.getRestraintData()
		if(restraintData == null):
			return
		
		var text = "{dom.You} {dom.youVerb('help')} to take off {sub.yourHis} "+item.getVisibleName()+"."
		
		var struggleText = restraintData.getRemoveMessage()
		if(struggleText != ""):
			text += " [b]"+struggleText+"[/b]"
		restraintData.onStruggleRemoval()
		getSub().getInventory().removeEquippedItem(item)
		getSexEngine().removeTrackedGear(domID, subID, item.uniqueID)
		
		#var canKeepTheRestraint = false
		if(!restraintData.alwaysBreaksWhenStruggledOutOf() && (getDom().hasPerk(Perk.BDSMCollector) || restraintData.alwaysSavedWhenStruggledOutOf())):
			#canKeepTheRestraint = true
			text += " {dom.You} managed to keep the restraint."
		
			getDom().getInventory().addItem(item)
		else:
			text += " The restraint broke and was unable to be recovered."
		return {text = text}

func processTurn():
	if(state == ""):
		state = "aboutToTieUp"
	elif(state == "aboutToTieUp"):
		#var item = _args[1]
		var sub:BaseCharacter = getSub()
		var dom:BaseCharacter = getDom()
		var item
		
		if(dom.isPlayer()):
			item = dom.getInventory().getItemByUniqueID(pcUniqueID)
		else:
			item = GlobalRegistry.createItem(npcItemID)
		
		endActivity()
		
		if(item == null):
			return {text="{dom.You} somehow lost the restraint."}
		
		if(dom.isPlayer()):
			dom.getInventory().removeItem(item)
		if item.isRestraint() && item.getRestraintData().canBeLocked() && RNG.chance(33):
			item.getRestraintData().lockIt()
		sub.getInventory().forceEquipByStoreOtherUnlessRestraint(item, dom)
		#sub.getBuffsHolder().calculateBuffs()
		#sub.updateNonBattleEffects()
		
		var text = RNG.pick([
			"{dom.You} {dom.youVerb('were', 'was')} successful. ",
		])
		text += GM.ui.processString(item.getForcedOnMessage(false), {receiver=subID})
		
		sendSexEvent(SexEvent.BondageGearForced, domID, subID, {itemID=item.id})
		getSexEngine().addTrackedGear(domID, subID, item.uniqueID)
		progressGoal(SexGoal.TieUp)
		
		return {text = text}

func getDomActions():
	var actions = []

	return actions

func doDomAction(_id, _actionInfo):
	return null

func getSubActions():
	var actions = []
	if(!getSub().hasBoundArms()):
		actions.append({
				"id": "resist",
				"score": subInfo.getResistScore() * 1.0 - subInfo.fetishScore({Fetish.Bondage: 1.0}) * subInfo.getComplyScore(),
				"name": "Resist the restraint",
				"desc": "You don't wanna be restrained",
				"chance": 70.0 - domInfo.getAngerScore()*60.0,
			})
	return actions

func doSubAction(_id, _actionInfo):
	if(_id == "resist"):
		if(RNG.chance(70.0 - domInfo.getAngerScore()*60.0)):
			progressGoal(SexGoal.TieUp)
			domInfo.addAnger(0.3)
			endActivity()
			return {
				text = "{sub.You} {sub.youVerb('manage', 'managed')} to resist {dom.yourHis} attempt to force a restraint!",
			}
		
		domInfo.addAnger(0.1)
		return {text = "{sub.You} {sub.youVerb('try', 'tries')} to resist {dom.yourHis} attempt at restraining {sub.youHim} but {sub.youVerb('fail')}.",
		subSay=subReaction(SexReaction.Resisting, 50)}

func saveData():
	var data = .saveData()
	
	data["pcUniqueID"] = pcUniqueID
	data["npcItemID"] = npcItemID

	return data
	
func loadData(data):
	.loadData(data)
	
	pcUniqueID = SAVE.loadVar(data, "pcUniqueID", "")
	npcItemID = SAVE.loadVar(data, "npcItemID", "")
