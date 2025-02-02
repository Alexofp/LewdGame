extends BaseCharacter
class_name Player


signal location_changed(newloc)
signal holePainfullyStretched(bodypart, who)
signal gotWoundedBy(who)

var gamename = "Player"
var credits:int = 0
var location:String = "cellblock_orange_playercell"#"ScriptedRoom"

var pickedGender = Gender.Female
var pronounsGender = null
var pickedSpecies = ["feline"]
var inmateNumber = "12859"
var pickedFemininity: int = 50
var pickedThickness: int = 50
var inmateType = InmateType.General


# Intoxication stuff
var intoxication: float = 0.0
var intoxicationTolerance: float = 0.0

#

# lust combat stuff
var lustCombatState
var reputation:Reputation

var tfHolder:TFHolder

var dynamicPersonality: bool = false

func _init():
	initialDodgeChance = 0.05 # Player has a small chance to dodge anything

func _ready():
	#GM.pc = self
	name = "Player"
	menstrualCycle = MenstrualCycle.new()
	menstrualCycle.setCharacter(self)
	menstrualCycle.start()
	
	lustCombatState = LustCombatState.new()
	lustCombatState.setCharacter(self)
	
	reputation = Reputation.new()
	reputation.setCharacter(self)
	
	tfHolder = TFHolder.new()
	tfHolder.setCharacter(self)
	
	var _ok = menstrualCycle.connect("readyToGiveBirthOnce", self, "onPlayerReadyToGiveBirth")
	var _ok2 = menstrualCycle.connect("visiblyPregnant", self, "onPlayerVisiblyPregnant")
	
	getInventory().clear()
	giveBodypart(GlobalRegistry.createBodypart("digilegs"))
	var mybreasts: BodypartBreasts = GlobalRegistry.createBodypart("humanbreasts")
	mybreasts.size = BreastsSize.C
	giveBodypart(mybreasts)
	giveBodypart(GlobalRegistry.createBodypart("baldhair"))
	giveBodypart(GlobalRegistry.createBodypart("felinetail"))
	giveBodypart(GlobalRegistry.createBodypart("felinehead"))
	giveBodypart(GlobalRegistry.createBodypart("anthrobody"))
	giveBodypart(GlobalRegistry.createBodypart("anthroarms"))
	giveBodypart(GlobalRegistry.createBodypart("felineears"))
	giveBodypart(GlobalRegistry.createBodypart("vagina"))
	giveBodypart(GlobalRegistry.createBodypart("anus"))
	#giveBodypart(GlobalRegistry.createBodypart("caninepenis"))
	updateNonBattleEffects()
	
	var allSkills = GlobalRegistry.getSkills();
	for skillID in allSkills:
		if(allSkills[skillID].alwaysVisible()):
			skillsHolder.ensureSkillExists(skillID)
	
	#inventory.addItem(GlobalRegistry.createItem("testitem"))
	#inventory.addItem(GlobalRegistry.createItem("testitem"))
	#inventory.addItem(GlobalRegistry.createItem("ballgag"))
	
	#inventory.equipItem(GlobalRegistry.createItem("ballgag"))
	#skillsHolder.setStat(Stat.Sexiness, 10)
	#skillsHolder.setStat(Stat.Agility, 5)
	#skillsHolder.setStat(Stat.Vitality, 5)
	#skillsHolder.addSkillExperience(Skill.Combat, 250)

func getID():
	return "pc"

func setLocation(newRoomID:String):
	if(newRoomID == location):
		return
	location = newRoomID
	#var roomInfo = GM.world.getRoomByID(location)
	#if(roomInfo):
	#	var roomName = roomInfo.getName()
	#	GM.ui.setLocationName(roomName)
	if(GM.main != null && is_instance_valid(GM.main) && GM.main.IS != null):
		GM.main.IS.updatePCLocation()
	emit_signal("location_changed", newRoomID)
	
func getLocation():
	return location
	
func isInSecludedLocation():
	if(GM.world == null):
		return false
	var cell:GameRoom = GM.world.getRoomByID(location)
	if(cell == null):
		return false
	if(cell.population > 0):
		return false
	return true
	
func getLocationPopulation():
	if(GM.world == null):
		return []
	var cell:GameRoom = GM.world.getRoomByID(location)
	if(cell == null):
		return []
	return cell.getPopulation()
	
func getName() -> String:
	return gamename
	
func setName(newname: String):
	newname = newname.replace("{", "")
	newname = newname.replace("}", "")
	newname = newname.replace("[", "")
	newname = newname.replace("]", "")
	newname = newname.replace("\"", "")
	if(newname == ""):
		newname = "Player"
	
	gamename = newname
	emit_signal("stat_changed")
	
func addCredits(_c: int):
	credits += _c
	emit_signal("stat_changed")

func getCredits() -> int:
	return credits

func isPlayer():
	return true

func _getAttacks():
	var attacks = [
		#"PunchPCAttack",
		#"BitePCAttack",
		#"KickPCAttack",
	]
	var thePlayerAttacks = GlobalRegistry.getPlayerAttackIDs()
	for attackID in thePlayerAttacks:
		var attack = GlobalRegistry.getAttack(attackID)
		if(attack == null):
			continue
		if(attack.canBeUsedByPlayer()):
			attacks.append(attackID)
	
	attacks.append_array(skillsHolder.getPerkAttacks())
	
	var uniqueItemAttacks = {}
	
	for item in getInventory().getItems():
		var itemAttacks = item.getAttacks()
		if(itemAttacks == null):
			continue
		for attackID in itemAttacks:
			var attack = GlobalRegistry.getAttack(attackID)
			if(attack == null):
				continue
			if(attack.combineWeaponAttacks()):
				if(uniqueItemAttacks.has(item.id) && uniqueItemAttacks[item.id].has(attackID)):
					continue
			
			attacks.append({
				"attackID": attackID,
				"itemID": item.getUniqueID(),
				"charID": getID(),
				})
			if(!uniqueItemAttacks.has(item.id)):
				uniqueItemAttacks[item.id] = []
			uniqueItemAttacks[item.id].append(attackID)
	
	return attacks

func canHandleBlindness():
	return skillsHolder.hasPerk(Perk.BDSMBlindfold)
	
func calculateBuffs():
	#updateNonBattleEffects()
	pass

# They may have effect on your damage in battles but they're not a 'battle' effects
func updateNonBattleEffects():
	buffsHolder.calculateBuffs()
	
	for effect in GlobalRegistry.getStatusEffectsAlwaysCheckedForPC():
		if(effect.shouldApplyTo(self)):
			addEffect(effect.id)
		else:
			removeEffect(effect.id)

	GM.GES.callGameExtenders(ExtendGame.pcUpdateNonBattleEffects, [self])

	emit_signal("stat_changed")
	
	buffsHolder.calculateBuffs()
	
	# Exposed status effect depends on stats that are calculated from buffs so it needs to be here
	if(GM.main != null && getExposure() > 0.0 && !GM.main.supportsSexEngine() && !GM.main.supportsBattleTurns()):
		addEffect(StatusEffect.Exposed)
	else:
		removeEffect(StatusEffect.Exposed)

func processBattleTurn():
	.processBattleTurn()
	skillsHolder.giveSkillExperienceBattleTurn()

	GM.GES.callGameExtenders(ExtendGame.pcProcessBattleTurn, [self])

func beforeFightStarted():
	.beforeFightStarted()
	if(lustCombatState != null):
		lustCombatState.enteredBattle()
	
	GM.GES.callGameExtenders(ExtendGame.pcBeforeFightStarted, [self])

func afterFightEnded():
	.afterFightEnded()
	
	if(lustCombatState != null):
		lustCombatState.exitedBattle()
		
	GM.GES.callGameExtenders(ExtendGame.pcAfterFightEnded, [self])

func processTime(_secondsPassed):
	for bodypart in processingBodyparts:
		if(bodypart == null || !is_instance_valid(bodypart)):
			continue
		bodypart.processTime(_secondsPassed)
	
	if(intoxication > 0.0):
		intoxication -= _secondsPassed / 30000.0
		if(intoxication < 0.0):
			intoxication = 0.0
	
	if(timedBuffsDurationSeconds > 0):
		timedBuffsDurationSeconds -= _secondsPassed
		if(timedBuffsDurationSeconds <= 0):
			timedBuffs.clear()
	
	for effectID in statusEffects:
		var effect = statusEffects[effectID]
		effect.processTime(_secondsPassed)
	
	if(menstrualCycle != null):
		menstrualCycle.processTime(_secondsPassed)
	
	if(lustCombatState != null):
		lustCombatState.processTime(_secondsPassed)
	
	if(tfHolder != null):
		tfHolder.processTime(_secondsPassed)
	
	if(!bodyFluids.isEmpty()):
		bodyFluids.drain(0.1 * _secondsPassed / 60.0)
	
	GM.GES.callGameExtenders(ExtendGame.pcProcessTime, [self, _secondsPassed])

func hoursPassed(_howmuch):
	var currentLust = getLust()
	var targetLust = getAmbientLust()
	
	if(currentLust < targetLust):
		var addValue = min(_howmuch, (targetLust - currentLust))
		addLust(addValue)

	var currentPain = getPain()
	var targetPain = getAmbientPain()
	
	if(currentPain < targetPain):
		var addValue = min(_howmuch, (targetPain - currentPain))
		addPain(addValue)
		
	skillsHolder.hoursPassed(_howmuch)
	
	for bodypart in processingBodyparts:
		if(bodypart != null && is_instance_valid(bodypart)):
			bodypart.hoursPassed(_howmuch)
		
	if(intoxication <= 0.0 && intoxicationTolerance > 0.0):
		intoxicationTolerance -= 0.005
		if(intoxicationTolerance < 0.0):
			intoxicationTolerance = 0.0

	GM.GES.callGameExtenders(ExtendGame.pcHoursPassed, [self, _howmuch])

func getGender():
	return pickedGender

func getPronounGender():
	if(pronounsGender == null):
		return getGender()
	return pronounsGender

func setGender(newgender):
	pickedGender = newgender

func setPronounGender(newgender):
	pronounsGender = newgender

func getChatColor():
	var gender = getGender()
	
	if(gender == Gender.Male):
		return "#92B3DD"
	if(gender == Gender.Female):
		return "#FFB7B2"
	if(gender == Gender.Androgynous):
		return "#DABFFF"
	if(gender == Gender.Other):
		return "#C3E8BE"
	
	return "red"

func getSpecies():
	return pickedSpecies

func setSpecies(species: Array):
	pickedSpecies = species
	pickedSpecies.sort()
	emit_signal("stat_changed")

func resetBodypartsToDefault():
	resetBodypartsToDefaultFor(getSpecies())
	
func resetBodypartsToDefaultFor(speciesIds):
	if(speciesIds is String):
		speciesIds = [speciesIds]
	
	var newgender = getGender()
	if(newgender == Gender.Male):
		pickedFemininity = 0
	if(newgender == Gender.Female):
		pickedFemininity = 100
	if(newgender == Gender.Androgynous || newgender == Gender.Other):
		pickedFemininity = 50
	
	#var speciesIds = getSpecies()
	var myspecies = []
	for specieID in speciesIds:
		myspecies.append(GlobalRegistry.getSpecies(specieID))
	if(myspecies.size() == 0):
		return
	resetSlots()
	var allslots = BodypartSlot.getAll()
	
	for slot in allslots:
		var choices = []
		
		for specie in myspecies:
			var bodypartID = specie.getDefaultForSlot(slot, getGender())
			if(bodypartID == null):
				continue
			var bodypart = GlobalRegistry.createBodypart(bodypartID)
			choices.append(bodypart)
			
		if(choices.size() == 0):
			continue
		
		var bestBodypart = choices[0]
		for bodypart in choices:
			if(bodypart.getHybridPriority() > bestBodypart.getHybridPriority()):
				bestBodypart = bodypart
				
		giveBodypart(bestBodypart, false)
		
	emit_signal("bodypart_changed")

func saveData():
	var data = {
		"gamename": gamename,
		"credits": credits,
		"pain": pain,
		"lust": lust,
		"stamina": stamina,
		"location": location,
		"pickedGender": pickedGender,
		"pronounsGender": pronounsGender,
		"pickedSpecies": pickedSpecies,
		"pickedFemininity": pickedFemininity,
		"pickedThickness": pickedThickness,
		"inmateType": inmateType,
		"arousal": arousal,
		"consciousness": consciousness,
		"dynamicPersonality": dynamicPersonality,
		"pickedSkin": pickedSkin,
		"pickedSkinRColor": pickedSkinRColor.to_html(),
		"pickedSkinGColor": pickedSkinGColor.to_html(),
		"pickedSkinBColor": pickedSkinBColor.to_html(),
	}
	
	data["bodyparts"] = {}
	for slot in bodyparts:
		if(bodyparts[slot] == null):
			data["bodyparts"][slot] = null
			continue
		
		data["bodyparts"][slot] = {
			"id": bodyparts[slot].id,
			"data": bodyparts[slot].saveData(),
		}
	
	data["statusEffects"] = saveStatusEffectsData()
	data["inventory"] = inventory.saveData()
	data["skills"] = skillsHolder.saveData()
	data["menstrualCycle"] = menstrualCycle.saveData()
	data["lustCombatState"] = lustCombatState.saveData()
	data["bodyFluids"] = bodyFluids.saveData()
	
	data["timedBuffs"] = saveBuffsData(timedBuffs)
	data["timedBuffsDurationSeconds"] = timedBuffsDurationSeconds
	data["timedBuffsTurns"] = saveBuffsData(timedBuffsTurns)
	data["timedBuffsDurationTurns"] = timedBuffsDurationTurns
	data["intoxication"] = intoxication
	data["intoxicationTolerance"] = intoxicationTolerance
	
	data["fetishHolder"] = fetishHolder.saveData()
	data["personality"] = personality.saveData()
	data["reputation"] = reputation.saveData()
	data["tfHolder"] = tfHolder.saveData()
	
	return data

func loadData(data):
	gamename = SAVE.loadVar(data, "gamename", "Player")
	credits = SAVE.loadVar(data, "credits", 0)
	pain = SAVE.loadVar(data, "pain", 0)
	lust = SAVE.loadVar(data, "lust", 0)
	stamina = SAVE.loadVar(data, "stamina", 100)
	location = SAVE.loadVar(data, "location", "ScriptedRoom")
	pickedGender = SAVE.loadVar(data, "pickedGender", Gender.Female)
	pronounsGender = SAVE.loadVar(data, "pronounsGender", null)
	pickedSpecies = SAVE.loadVar(data, "pickedSpecies", ["human"])
	pickedFemininity = SAVE.loadVar(data, "pickedFemininity", 50)
	pickedThickness = SAVE.loadVar(data, "pickedThickness", 50)
	inmateType = SAVE.loadVar(data, "inmateType", InmateType.General)
	arousal = SAVE.loadVar(data, "arousal", 0.0)
	consciousness = SAVE.loadVar(data, "consciousness", 1.0)
	dynamicPersonality = SAVE.loadVar(data, "dynamicPersonality", false)
	pickedSkin = SAVE.loadVar(data, "pickedSkin", "EmptySkin")
	pickedSkinRColor = Color(SAVE.loadVar(data, "pickedSkinRColor", "ffffff"))
	pickedSkinGColor = Color(SAVE.loadVar(data, "pickedSkinGColor", "cccccc"))
	pickedSkinBColor = Color(SAVE.loadVar(data, "pickedSkinBColor", "999999"))
	
	resetSlots()
	var loadedBodyparts = SAVE.loadVar(data, "bodyparts", {})
	for slot in loadedBodyparts:
		if(loadedBodyparts[slot] == null):
			bodyparts[slot] = null
			continue
		var id = SAVE.loadVar(loadedBodyparts[slot], "id", "errorbad")
		var bodypart = GlobalRegistry.createBodypart(id)
		if(bodypart == null):
			var replacementID = BodypartSlot.findReplacement(slot, id)
			if(replacementID == null || replacementID == ""):
				Log.printerr("Couldn't find an replacement bodypart for slot "+str(slot))
				continue
			bodypart = GlobalRegistry.createBodypart(replacementID)
			
		giveBodypart(bodypart, false)
		bodypart.loadData(SAVE.loadVar(loadedBodyparts[slot], "data", {}))
	checkSkins()
	
	loadStatusEffectsData(SAVE.loadVar(data, "statusEffects", {}))
	inventory.loadData(SAVE.loadVar(data, "inventory", {}))
	skillsHolder.loadData(SAVE.loadVar(data, "skills", {}))
	menstrualCycle.loadData(SAVE.loadVar(data, "menstrualCycle", {}))
	lustCombatState.loadData(SAVE.loadVar(data, "lustCombatState", {}))
	bodyFluids.loadData(SAVE.loadVar(data, "bodyFluids", {}))
	
	timedBuffs = loadBuffsData(SAVE.loadVar(data, "timedBuffs", []))
	timedBuffsDurationSeconds = SAVE.loadVar(data, "timedBuffsDurationSeconds", 0)
	timedBuffsTurns = loadBuffsData(SAVE.loadVar(data, "timedBuffsTurns", []))
	timedBuffsDurationTurns = SAVE.loadVar(data, "timedBuffsDurationTurns", 0)
	intoxication = SAVE.loadVar(data, "intoxication", 0.0)
	intoxicationTolerance = SAVE.loadVar(data, "intoxicationTolerance", 0.0)
	
	fetishHolder.loadData(SAVE.loadVar(data, "fetishHolder", {}))
	personality.loadData(SAVE.loadVar(data, "personality", {}))
	reputation.loadData(SAVE.loadVar(data, "reputation", {}))
	tfHolder.loadData(SAVE.loadVar(data, "tfHolder", {}))
	
	checkLocation()
		
	updateNonBattleEffects()
	emit_signal("bodypart_changed")
	
	#ensure always-visible skills are visible for old saves
	var allSkills = GlobalRegistry.getSkills();
	for skillID in allSkills:
		if(allSkills[skillID].alwaysVisible()):
			skillsHolder.ensureSkillExists(skillID)
	getInventory().removeBrokenDuplicatedItems()

func checkLocation():
	var _roomInfo = GM.world.getRoomByID(getLocation())
	if(_roomInfo == null):
		Log.printerr("Player's location '"+str(location)+"' doesn't exists, reseting them to their cell")
		location = getCellLocation()


		

func getFightState(_battleName):
	if(getPainLevel() > getLustLevel()):
		var mypain = getPainLevel() * 100
		
		if(mypain >= 70):
			return "Everything hurts, you are barely able to continue fighting."
		if(mypain >= 50):
			return "The pain begins to take over your body, it's hard to concentrate on fighting"
		if(mypain >= 10):
			return "You got bruised but doing fine otherwise"
	else:
		var mylust = getLustLevel() * 100
		
		if(mylust >= 70):
			return "You feel so horny, you just can't stop thinking about your opponent, your hands sneak down to your privates and tease them"
		if(mylust >= 50):
			return "You feel very lusty, you find your opponent to be quite hot"
		if(mylust >= 10):
			return "You are slightly aroused but you manage to control it just fine"
		
	return "You seem to be doing just fine during this moment in a fight"

func getBodypartTooltipName(_bodypartSlot):
	if(hasBodypart(_bodypartSlot)):
		var bodypart: Bodypart = getBodypart(_bodypartSlot)
		return bodypart.getName()
	
	return "error"

func getBodypartTooltipInfo(_bodypartSlot):
	if(hasBodypart(_bodypartSlot)):
		var bodypart: Bodypart = getBodypart(_bodypartSlot)
		return bodypart.getTooltipInfo()
	
	return "error"

func afterSleeping():
	var mult = max(1.0 + GM.pc.getBuffsHolder().getCustom(BuffAttribute.RestEffectiveness), 0.1) # 0.1 minimum to avoid softlock scenarios
	var staminaChange = mult * (getMaxStamina() - getStamina())
	var painChange = mult * getPain()
	addStamina(staminaChange)
	addPain(-painChange)
	skillsHolder.onNewDay()
	for item in getInventory().getEquppedRestraints():
		item.getRestraintData().resetOnNewDay()
	
	for statusEffectID in statusEffects:
		statusEffects[statusEffectID].onSleeping()
	
	if(isPregnant() && getPregnancyProgress() <= 0.5 && RNG.chance(30)):
		GM.main.addLogMessage("Nausea", "You wake up and feel kinda nauseous.")
		addEffect(StatusEffect.PregnancySickness)

func afterSleepingInBed():
	afterSleeping()

func afterRestingInBed(seconds):
	var _hours = floor(seconds/3600.0)
	
	var mult = max(1.0 + GM.pc.getBuffsHolder().getCustom(BuffAttribute.RestEffectiveness), 0.1) # 0.1 minimum to avoid softlock scenarios
	addStamina(_hours * 10 * mult)

func afterCryopodTreatment():
	removeEffect(StatusEffect.Wounded)
	removeEffect(StatusEffect.StretchedPainfullyAnus)
	removeEffect(StatusEffect.StretchedPainfullyPussy)
	addPain(-GM.pc.getPain())
	addStamina(GM.pc.getMaxStamina())

func afterHealingGelTreatment():
	removeEffect(StatusEffect.StretchedPainfullyAnus)
	removeEffect(StatusEffect.StretchedPainfullyPussy)

func afterEatingAtCanteen():
	addStamina(100)
	addPain(-20)

func afterTakingAShower():
	addStamina(30)
	clearBodyFluids()
	clearBodywritings()
	clearTallymarks()

func orgasmFrom(_characterID: String):
	afterOrgasm()
	
	if(true):
		var event = SexEventHelper.create(SexEvent.Orgasmed, _characterID, getID(), {
		})
		if(_characterID != getID()):
			var ch = GlobalRegistry.getCharacter(_characterID)
			if(ch != null):
				ch.sendSexEvent(event)
		sendSexEvent(event)

func getInmateNumber():
	return inmateNumber

func getFullInmateNumber():
	return "P-"+inmateNumber

func getFemininity() -> int:
	return pickedFemininity

func getThickness() -> int:
	return pickedThickness

func getPickableAttributes():
#	var skinsOptions = []
#	for skinID in GlobalRegistry.getSkinsAllKeys():
#		var theSkin = GlobalRegistry.getSkin(skinID)
#		skinsOptions.append([skinID, theSkin.getName(), "Pick this skin"])
#
	return {
		"femininity": {
			"text": "Pick how feminine or masculine you are",
			"textButton": "Femininity",
			"buttonDesc": "Pick how feminine or masculine you are",
			"options": [
				[0, "Very masculine", "Fully masculine"],
				[25, "Masculine", "75% Masculine"],
				[50, "Androgynous", "Half-way between feminine and masculine"],
				[75, "Feminine", "75% Feminine"],
				[100, "Very feminine", "Fully feminine"],
			]
		},
		"thickness": {
			"text": "Pick how thick you are",
			"textButton": "Thickness",
			"buttonDesc": "Pick how thick you are",
			"options": [
				[0, "Skinny", "0% thick"],
				[25, "Slim", "25% thick"],
				[50, "Average", "50% thick"],
				[75, "Thick", "75% thick"],
				[100, "Very thick", "100% thicc"],
				[125, "125% thick", "Sooo thicc"],
				[150, "150% thick", "Sooo thicc"],
				[175, "175% thick", "Sooo thicc"],
				[200, "200% thick", "Sooo thicc"],
			]
		},
#		"skin": {
#			"text": "Pick your base skin. All bodyparts will use this skin unless overridden.",
#			"textButton": "Skin",
#			"buttonDesc": "Change your skin type",
#			"options": skinsOptions,
#		},
#		"skinPrimaryColor": {
#			"text": "Pick your primary color.",
#			"textButton": "Primary color",
#			"buttonDesc": "Change the primary color of your skin",
#			"options": [[1, "Select", "Pick this color"]],
#			"type": "color",
#			"currentColor": pickedSkinRColor,
#		},
#		"skinSecondaryColor": {
#			"text": "Pick your secondary color.",
#			"textButton": "Secondary color",
#			"buttonDesc": "Change the secondary color of your skin",
#			"options": [[1, "Select", "Pick this color"]],
#			"type": "color",
#			"currentColor": pickedSkinGColor,
#		},
#		"skinTertiaryColor": {
#			"text": "Pick your tertiary color.",
#			"textButton": "Tertiary color",
#			"buttonDesc": "Change the tertiary color of your skin",
#			"options": [[1, "Select", "Pick this color"]],
#			"type": "color",
#			"currentColor": pickedSkinBColor,
#		},
	}
	
func applyAttribute(_attrID: String, _attrValue):
	if(_attrID == "femininity"):
		pickedFemininity = _attrValue
	if(_attrID == "thickness"):
		pickedThickness = _attrValue
	if(_attrID == "skin"):
		pickedSkin = _attrValue
	if(_attrID == "skinPrimaryColor"):
		pickedSkinRColor = _attrValue
	if(_attrID == "skinSecondaryColor"):
		pickedSkinGColor = _attrValue
	if(_attrID == "skinTertiaryColor"):
		pickedSkinBColor = _attrValue

func getAttributesText():
	return [
		["Femininity", str(pickedFemininity)+"%"],
		["Thickness", str(pickedThickness)+"%"],
	]

func freeMouthDeleteAll():
	var r1 = getInventory().removeEquippedItemsWithBuff(Buff.GagBuff)
	var r2 = getInventory().removeEquippedItemsWithBuff(Buff.MuzzleBuff)
	return r1 || r2
	
func freeHandsDeleteAll():
	return getInventory().removeEquippedItemsWithBuff(Buff.BlockedHandsBuff)
	
func freeArmsDeleteAll():
	return getInventory().removeEquippedItemsWithBuff(Buff.RestrainedArmsBuff)
	
func freeLegsDeleteAll():
	return getInventory().removeEquippedItemsWithBuff(Buff.RestrainedLegsBuff)
	
func freeEyesDeleteAll():
	return getInventory().removeEquippedItemsWithBuff(Buff.BlindfoldBuff)

func canUndress():
	var slotsToCheck = [InventorySlot.Body, InventorySlot.UnderwearTop, InventorySlot.UnderwearBottom]
	for slot in slotsToCheck:
		if(getInventory().hasSlotEquipped(slot)):
			return true
	return false

func setInmateType(newtype):
	inmateType = newtype

func getInmateType():
	return inmateType

func getInmateTypeString():
	return InmateType.getOfficialName(getInmateType())

func getInmateColorString():
	return InmateType.getColorName(getInmateType())

func getCellLocation():
	if(inmateType == InmateType.General):
		return "cellblock_orange_playercell"
	if(inmateType == InmateType.HighSec):
		return "cellblock_red_playercell"
	if(inmateType == InmateType.SexDeviant):
		return "cellblock_pink_playercell"
	
	return "cellblock_orange_playercell"

func addIntoxication(howmuch: float):
	intoxication += howmuch
	intoxication = clamp(intoxication, 0.0, 2.0)
	
	if(intoxication >= 0.5 && howmuch > 0.0):
		intoxicationTolerance += howmuch / 20.0
		if(intoxicationTolerance > 1.0):
			intoxicationTolerance = 1.0
	

func getIntoxicationLevel() -> float:
	return intoxication

func getIntoxicationTolerance() -> float:
	return intoxicationTolerance

func getIntoxicationMod() -> float:
	if(intoxicationTolerance < 0.2):
		return 1.0
	
	return 1.0 - (intoxicationTolerance - 0.1) / 0.9 * 0.4

func canIntoxicateMore(_howmuch: float):
	if(getIntoxicationLevel() >= 1.0):
		return false

	return true

func hasCondoms():
	return getInventory().getItemsWithTag(ItemTag.Condom).size() > 0

func useBestCondom():
	var condoms = getInventory().getItemsWithTag(ItemTag.Condom)
	if(condoms.size() <= 0):
		return null
	
	var bestObject = null
	var bestChance = -99.0
	for condom in condoms:
		if(condom.getCondomBreakChance() > bestChance):
			bestChance = condom.getCondomBreakChance()
			bestObject = condom
	
	if(bestObject != null):
		bestObject.removeXOrDestroy(1)
	return bestChance

func useWorstCondom():
	var condoms = getInventory().getItemsWithTag(ItemTag.Condom)
	if(condoms.size() <= 0):
		return null
	
	var bestObject = null
	var bestChance = 100000.0
	for condom in condoms:
		if(condom.getCondomBreakChance() < bestChance):
			bestChance = condom.getCondomBreakChance()
			bestObject = condom
	
	if(bestObject != null):
		bestObject.removeXOrDestroy(1)
	return bestChance

func onPlayerVisiblyPregnant():
	GM.main.addLogMessage("Uh oh", "You notice that your belly is more inflated that normally. You can't deny it anymore, you are pregnant..")

func onPlayerReadyToGiveBirth():
	GM.main.addLogMessage("It's time..", "Your belly is so swollen, it's hard to walk! You feel ready to give birth, maybe it's time to visit the nursery.")

func getLustCombatState():
	return lustCombatState

func getRestraintForcingSuccessChanceMod():
	return max(1.0 + min(getAttackAccuracy(), 0.0), 0.0) * (1.0 + buffsHolder.getCustom(BuffAttribute.RestraintForcingSuccess))

func personalityChangesAfterSex():
	return dynamicPersonality

func getCharacterType():
	return CharacterType.Inmate

func doPainfullyStretchHole(_bodypart, _who = "pc"):
	if(_bodypart == BodypartSlot.Vagina && hasBodypart(_bodypart)):
		if(hasEffect(StatusEffect.LubedUp)):
			return
		
		addEffect(StatusEffect.StretchedPainfullyPussy, [1])
		emit_signal("holePainfullyStretched", _bodypart, _who)
	if(_bodypart == BodypartSlot.Anus && hasBodypart(_bodypart)):
		if(hasEffect(StatusEffect.LubedUp)):
			return
		
		addEffect(StatusEffect.StretchedPainfullyAnus, [1])
		emit_signal("holePainfullyStretched", _bodypart, _who)

func doWound(_who = "pc"):
	addEffect(StatusEffect.Wounded, [1])
	emit_signal("gotWoundedBy", _who)

func getEncounterChanceModifierStaff():
	return clamp(buffsHolder.getCustom(BuffAttribute.EncounterChanceModifierStaff) + 1.0, 0.1, 10.0)
	
func getEncounterChanceModifierInmates():
	return clamp(buffsHolder.getCustom(BuffAttribute.EncounterChanceModifierInmates) + 1.0, 0.1, 10.0)

func giveBirth():
	var bornChildren = .giveBirth()
	
	var bornChildAmount = bornChildren.size()
	addSkillExperience(Skill.Fertility, 90 + Util.mini(210, bornChildAmount * 10))
	if(hasPerk(Perk.FertilityMotherOfTheYear)):
		addEffect(StatusEffect.MaternalGlow)
		
		var paycheck = Util.mini(20, bornChildAmount * 2)
		addCredits(paycheck)
		
		#if(GM.ui != null):
		#	GM.ui.showHornyMessage("[center][color=#f0dd61]AlphaCorp thanks you for your compliance and hopes to continue our 'fruitful cooperation' in the future \n [b]You recieved: " +str(paycheck)+ " credits![/b][/color][/center]")
		GM.main.addMessage("AlphaCorp has transferred "+str(paycheck)+" credits to you for being a good mother.")
	
	return bornChildren

func setThickness(_newT:int):
	pickedThickness = _newT
	updateAppearance()

func setFemininity(_newF:int):
	pickedFemininity = _newF
	updateAppearance()

func canStartSex() -> bool:
	if(hasBoundArms()):
		return false
	if(hasBlockedHands()):
		return false
	if(hasBoundLegs()):
		return false
	if(isOralBlocked()):
		return false
	return true

func getReputation():
	return reputation

func getTFHolder():
	return tfHolder

func saveOriginalTFData() -> Dictionary:
	var partSkinData:Dictionary = {}
	for bodypartSlot in bodyparts:
		var bodypart = getBodypart(bodypartSlot)
		if(bodypart == null):
			continue
		partSkinData[bodypartSlot] = bodypart.getSkinData()
	
	var result:Dictionary = {
		"species": pickedSpecies,
		"femininity": pickedFemininity,
		"thickness": pickedThickness,
		"pickedSkin": pickedSkin,
		"pickedSkinRColor": pickedSkinRColor.to_html(),
		"pickedSkinGColor": pickedSkinGColor.to_html(),
		"pickedSkinBColor": pickedSkinBColor.to_html(),
		"gender": pickedGender,
		"pronounsGender": pronounsGender,
		"partsSkins": partSkinData,
	}
	
	return result

func applyTFData(_data):
	pickedSpecies = loadTFVar(_data, "species", pickedSpecies)
	pickedFemininity = loadTFVar(_data, "femininity", pickedFemininity)
	pickedThickness = loadTFVar(_data, "thickness", pickedThickness)
	pickedSkin = loadTFVar(_data, "pickedSkin", pickedSkin)
	pickedGender = loadTFVar(_data, "gender", pickedGender)
	pronounsGender = loadTFVar(_data, "pronounsGender", pronounsGender)
	if(_data.has("pickedSkinRColor")):
		pickedSkinRColor = Color(_data["pickedSkinRColor"])
	if(_data.has("pickedSkinGColor")):
		pickedSkinGColor = Color(_data["pickedSkinGColor"])
	if(_data.has("pickedSkinBColor")):
		pickedSkinBColor = Color(_data["pickedSkinBColor"])
	var partSkinData:Dictionary = loadTFVar(_data, "partsSkins", {})
	for bodypartSlot in bodyparts:
		var bodypart = getBodypart(bodypartSlot)
		if(bodypart == null || !partSkinData.has(bodypartSlot)):
			continue
		bodypart.applySkinData(partSkinData[bodypartSlot] if partSkinData.has(bodypartSlot) else {})

func onSexEvent(_event : SexEvent):
	.onSexEvent(_event)
	
	if(GM.main != null && GM.main.SCI != null):
		GM.main.SCI.handleSexEvent(_event)
