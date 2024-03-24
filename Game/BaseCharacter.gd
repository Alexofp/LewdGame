extends Node
class_name BaseCharacter

#Base class that has all the functions
signal stat_changed
signal pain_changed(newValue, oldValue)
signal lust_changed(newValue, oldValue)
signal stamina_changed(newValue, oldValue)
signal levelChanged
signal skillLevelChanged(skillID)
signal bodypart_changed
signal orificeBecomeMoreLoose(orificeName, newvalue, oldvalue)
signal exchangedCumDuringRubbing(senderName, receiverName)
#signal soft_doll_update

var pain:int = 0
var lust:int = 0
var stamina:int = 100

# sex stats
var arousal:float = 0
var consciousness: float = 1.0

var statusEffects:Dictionary = {}
var inventory: Inventory
var buffsHolder: BuffsHolder
var skillsHolder: SkillsHolder
var lustInterests: LustInterests
var fetishHolder: FetishHolder
var personality: Personality
var sexVoice: SexVoice
var bodyFluids: Fluids

# Bodypart stuff
var bodyparts: Dictionary
var processingBodyparts: Array
var bodypartStorageNode

# Combat stats
var initialDodgeChance = 0
var fightingState = "" # dodge, block, defocus

# pregnancy stuff
var menstrualCycle: MenstrualCycle

var timedBuffs: Array = []
var timedBuffsDurationSeconds: int = 0
var timedBuffsTurns: Array = []
var timedBuffsDurationTurns: int = 0

# Skin data
var pickedSkin:String = "EmptySkin"
var pickedSkinRColor:Color = Color.white
var pickedSkinGColor:Color = Color.lightgray
var pickedSkinBColor:Color = Color.darkgray

func _init():
	name = "BaseCharacter"

func _ready():
	bodypartStorageNode = Node.new()
	add_child(bodypartStorageNode)
	bodypartStorageNode.name = "Bodyparts"
	resetSlots()
	inventory = Inventory.new()
	add_child(inventory)
	var _con = inventory.connect("equipped_items_changed", self, "onEquippedItemsChange")
	buffsHolder = BuffsHolder.new()
	buffsHolder.setCharacter(self)
	add_child(buffsHolder)
	skillsHolder = SkillsHolder.new()
	skillsHolder.setCharacter(self)
	add_child(skillsHolder)
	var _con2 = skillsHolder.connect("statChanged", self, "onStatChange")
	var _con3 = skillsHolder.connect("experienceChanged", self, "onStatChange")
	var _con4 = skillsHolder.connect("levelChanged", self, "onLevelChange")
	var _con5 = skillsHolder.connect("skillLevelChanged", self, "onSkillLevelChange")
	stamina = getMaxStamina()
	#resetToDefault()
	lustInterests = LustInterests.new()
	fetishHolder = FetishHolder.new()
	fetishHolder.setCharacter(self)
	personality = Personality.new()
	personality.setCharacter(self)
	createVoice()
	bodyFluids = Fluids.new()

func getID():
	assert(false, "Getting an ID of a baseCharacter class")

# Skips armor checks etc
func addPain(_p: int):
	var initialPain = pain
	pain += _p
	if(pain > painThreshold()):
		pain = painThreshold()
	if(pain < 0):
		pain = 0
		
	if(initialPain != pain):
		emit_signal("pain_changed", pain, initialPain)
	emit_signal("stat_changed")

func addLust(_l: int):
	var initialLust = lust
	lust += _l
	if(lust > lustThreshold()):
		lust = lustThreshold()
	if(lust < 0):
		lust = 0
	
	if(initialLust != lust):
		emit_signal("lust_changed", lust, initialLust)
	emit_signal("stat_changed")

func addStamina(_s: int):
	var initialStamina = stamina
	stamina += _s
	if(stamina > getMaxStamina()):
		stamina = getMaxStamina()
	if(stamina < 0):
		stamina = 0
	
	if(initialStamina != stamina):
		emit_signal("stamina_changed", stamina, initialStamina)
	emit_signal("stat_changed")

func getPain() -> int:
	return pain

func getLust() -> int:
	return lust
	
func getStamina() -> int:
	return stamina
	
func getBaseMaxStamina() -> int:
	return 100
	
func getMaxStamina() -> int:
	return int(max(0, getBaseMaxStamina() + skillsHolder.getExtraStamina() + buffsHolder.getExtraStamina()))
	
func getName() -> String:
	return name
	
func getSmallDescription() -> String:
	return "Test test test"

func getBasePainThreshold() -> int:
	return 100

func painThreshold() -> int:
	return int(max(10, getBasePainThreshold() + skillsHolder.getExtraPainThreshold() + buffsHolder.getExtraPainThreshold()))

func getBaseLustThreshold() -> int:
	return 100

func lustThreshold() -> int:
	return int(max(10, getBaseLustThreshold() + skillsHolder.getExtraLustThreshold() + buffsHolder.getExtraLustThreshold()))

func getPainLevel():
	return float(getPain()) / float(painThreshold())

func getLustLevel():
	return float(getLust()) / float(lustThreshold())

func getStaminaLevel():
	return float(getStamina()) / float(getMaxStamina())

func getAmbientPain():
	return int(buffsHolder.getAmbientPain())

func getAmbientLust():
	return int(buffsHolder.getAmbientLust())

func addEffect(effectID: String, args = []):
	if(statusEffects.has(effectID)):
		statusEffects[effectID].combine(args)
		return true
	
	var immunity = getStatusEffectImmunity(effectID)
	if(RNG.chance(clamp(immunity, 0.0, 1.0)*100.0) || GlobalRegistry.getStatusEffectRef(effectID).checkAvoidedBuff(self)):
		if(GM.main != null && GM.main.characterIsVisible(getID())):
			if(isPlayer()):
				GM.main.addMessage("You managed to avoid the '"+GlobalRegistry.getStatusEffectRef(effectID).getEffectName()+"' status effect!")
			else:
				GM.main.addMessage(getName()+" managed to avoid the '"+GlobalRegistry.getStatusEffectRef(effectID).getEffectName()+"' status effect!")
		return false
	
	var effect = GlobalRegistry.createStatusEffect(effectID)
	effect.setCharacter(self)
	effect.initArgs(args)
	
	statusEffects[effectID] = effect
	#buffsHolder.calculateBuffs()
	return true

func hasEffect(effectID: String):
	return statusEffects.has(effectID)
	
func getEffect(effectID: String):
	if(!statusEffects.has(effectID)):
		return null
	return statusEffects[effectID]
	
func removeEffect(effectID: String):
	if(statusEffects.has(effectID)):
		#statusEffects[effectID].queue_free()
		var _wasremoved = statusEffects.erase(effectID)
		#buffsHolder.calculateBuffs()
	
func canStandUpCombat():
	if(!hasEffect(StatusEffect.Collapsed)):
		return false
	
	var collapsedEffect = statusEffects[StatusEffect.Collapsed]
	return collapsedEffect.canStandUp() || hasPerk(Perk.CombatBetterGetUp)
	
func getStatusEffects():
	return statusEffects
	
func saveStatusEffectsData():
	var data = {}
	for effectID in statusEffects:
		data[effectID] = statusEffects[effectID].saveData()
	return data
	
func loadStatusEffectsData(data):
	for effectID in statusEffects.keys():
		removeEffect(effectID)
	
	for effectID in data:
		var effect = GlobalRegistry.createStatusEffect(effectID)
		if(effect == null):
			continue
		effect.setCharacter(self)
		statusEffects[effectID] = effect
		
		effect.loadData(data[effectID])
	
func updateEffectPanel(panel: StatusEffectsPanel):
	panel.clearBattleEffects()
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		panel.addBattleEffect(effect.getIconColor(), effect.getEffectName(), effect.getVisisbleDescription(), effect.getEffectImage(), effect.shouldHaveWideTooltip())

func processBattleTurn():
	if(timedBuffsDurationTurns > 0):
		timedBuffsDurationTurns -= 1
		if(timedBuffsDurationTurns <= 0):
			timedBuffsTurns.clear()
	
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		effect.processBattleTurn()
		
	skillsHolder.processBattleTurn()
		
	#buffsHolder.calculateBuffs()
		
func beforeFightStarted():
	pass

func afterFightEnded():
	print(getName()+" my fight has ended")
	
	timedBuffsTurns.clear()
	timedBuffsDurationTurns = 0
	
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		if(effect.isBattleOnly):
			removeEffect(effectID)
	
func isPlayer():
	return false

func isOverriddenPlayer():
	return false

func _getAttacks():
	return ["blunderAttack"]
	
func _getAttacksForBattle(_battlename):
	return null
	
func getAttacks(_battlename):
	var battleAttacks = _getAttacksForBattle(_battlename)
	if(battleAttacks != null):
		return battleAttacks
	
	return _getAttacks()
	
func getArmor(_damageType):
	var armor = 0
	if(isBlocking()):
		if(_damageType == DamageType.Physical):
			armor += getBlockArmor()
	if(isDefocusing()):
		if(_damageType == DamageType.Lust):
			armor += getDefocusArmor()
	
	armor += buffsHolder.getArmor(_damageType)
	
	return armor
	
func calculateBuffs():
	#buffsHolder.calculateBuffs()
	pass
	
func onEquippedItemsChange():
	#calculateBuffs()
	updateAppearance()
	
func onStatChange():
	emit_signal("stat_changed")
	
func onDamage(_damageType, _amount):
	pass

func getDamageMultiplier(_damageType):
	var mult = 0
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		mult += effect.getDamageMultiplierMod(_damageType)
	
	mult += buffsHolder.getDealDamageMult(_damageType)
	mult += skillsHolder.getDamageMultiplier(_damageType)

	if(mult < -0.8):
		mult = -0.8

	return mult

func getRecieveDamageMultiplier(_damageType):
	var mult = 0
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		mult += effect.getRecievedDamageMod(_damageType)
		
	mult += buffsHolder.getRecieveDamageMult(_damageType)
	
	if(mult < -0.8):
		mult = -0.8
	
	return mult

func getDodgeChance():
	if(isDodging()):
		return 1
	
	var mult = initialDodgeChance
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		mult += effect.getDodgeMod()

	mult += buffsHolder.getDodgeChance()

	if(mult > 0.8):
		mult = 0.8

	return mult
	
func getAttackAccuracy():
	var mult = 0
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		mult += effect.getAccuracyMod()
	
	mult += buffsHolder.getAccuracy()
	
	if(mult < -0.9):
		mult = -0.9
	
	return mult
	
func receiveDamage(damageType, amount: int, armorScale: float = 1.0):
	var mult = getRecieveDamageMultiplier(damageType)
	var newdamage = round(amount * (1.0 + mult))
	
	if(amount > 0):
		var finalArmor = floor(getArmor(damageType) * armorScale)
		#newdamage -= finalArmor
		newdamage = newdamage * (50.0/(50.0+finalArmor)) 
		newdamage = max(newdamage, 1)
	
	if(damageType == DamageType.Physical):
		var oldpain = pain

		addPain(newdamage)
		
		var actualAddpain = pain - oldpain
		onDamage(damageType, actualAddpain)
		return actualAddpain
		
	if(damageType == DamageType.Lust):
		var oldlust = lust

		addLust(newdamage)
		if(isDefocusing() && hasPerk(Perk.SexDefocusNeverLose) && (oldlust < (lustThreshold()-1)) && (getLust() >= lustThreshold())):
			addLust(-1)
		
		var actualAddlust = lust - oldlust
		onDamage(damageType, actualAddlust)
		return actualAddlust
		
	if(damageType == DamageType.Stamina):
		var oldstamina = stamina

		addStamina(-newdamage)
		
		var actualAddstamina = stamina - oldstamina
		onDamage(damageType, actualAddstamina)
		return -actualAddstamina
		
	return 0

func isDodging():
	return fightingState == "dodge"
	
func isBlocking():
	return fightingState == "block"
	
func isDefocusing():
	return fightingState == "defocus"

func setFightingStateNormal():
	fightingState = ""
	
func setFightingStateDodging():
	fightingState = "dodge"
	
func setFightingStateBlocking():
	fightingState = "block"
	
func setFightingStateDefocusing():
	fightingState = "defocus"

func lustDamageReaction(lustDamage, _enemy):
	if(lustDamage <= -10):
		return getName() + " got very turned off by the sight"
	if(lustDamage <= -6):
		return getName() + " didn't like that at all"
	if(lustDamage <= -3):
		return getName() + " sighs and shakes "+hisHer()+" head"
	if(lustDamage == 0):
		return getName() + " didn't seem to care at all"
	if(lustDamage <= 5):
		return getName() + " seems intrigued"
	if(lustDamage <= 10):
		return getName() + " smiles eagerly and watches the show"
	if(lustDamage <= 10):
		return getName() + " blushes watching " + _enemy.getName()
	if(lustDamage <= 15):
		return getName() + " exhalled deeply while rubbing "+hisHer()+" legs together"
	if(lustDamage > 15):
		return getName() + " moans audibly, "+hisHer()+" eyes burn with desire"

func getGender():
	return Gender.Other

func getPronounGender():
	return getGender()

func getChatColor():
	var gender = getGender()
	
	if(gender == Gender.Male):
		return "#5696EA"
	if(gender == Gender.Female):
		return "#FF837A"
	if(gender == Gender.Androgynous):
		return "#BA82FF"
	if(gender == Gender.Other):
		return "#77D86C"
	
	return "red"

func formatSay(text):
	var color = getChatColor()
	if(GM.ui != null):
		text = GM.ui.processString(text)
	
	for speechModifier in GlobalRegistry.getSpeechModifiers():
		if(speechModifier.appliesTo(self)):
			text = speechModifier.modify(text, self)
	
	return "[color="+color+"]\""+text+"\"[/color]"

func heShe():
	var gender = getPronounGender()
	
	if(gender == Gender.Male):
		return "he"
	if(gender == Gender.Female):
		return "she"
	if(gender == Gender.Androgynous):
		return "they"
	if(gender == Gender.Other):
		return "it"
		
func hisHer():
	var gender = getPronounGender()
	
	if(gender == Gender.Male):
		return "his"
	if(gender == Gender.Female):
		return "her"
	if(gender == Gender.Androgynous):
		return "their"
	if(gender == Gender.Other):
		return "its"
		
func himHer():
	var gender = getPronounGender()
	
	if(gender == Gender.Male):
		return "him"
	if(gender == Gender.Female):
		return "her"
	if(gender == Gender.Androgynous):
		return "them"
	if(gender == Gender.Other):
		return "it"

func isAre():
	var gender = getPronounGender()
	
	if(gender == Gender.Male):
		return "is"
	if(gender == Gender.Female):
		return "is"
	if(gender == Gender.Androgynous):
		return "are"
	if(gender == Gender.Other):
		return "is"

func hasHave():
	var gender = getPronounGender()
	
	if(gender == Gender.Male):
		return "has"
	if(gender == Gender.Female):
		return "has"
	if(gender == Gender.Androgynous):
		return "have"
	if(gender == Gender.Other):
		return "has"

func himselfHerself():
	var gender = getPronounGender()
	
	if(gender == Gender.Male):
		return "himself"
	if(gender == Gender.Female):
		return "herself"
	if(gender == Gender.Androgynous):
		return "themself"
	if(gender == Gender.Other):
		return "itself"

func verbS(verbWithNoS, verbWithS = null):
	var gender = getPronounGender()
	
	if(verbWithS == null):
		verbWithS = verbWithNoS + "s"
	
	if(gender == Gender.Male):
		return verbWithS
	if(gender == Gender.Female):
		return verbWithS
	if(gender == Gender.Androgynous):
		return verbWithNoS
	if(gender == Gender.Other):
		return verbWithS

func getPenisSizeString() -> String:
	if(!hasBodypart(BodypartSlot.Penis) && !isWearingStrapon()):
		return "ERROR:NO_PENIS"
	
	return Util.cmToString(getPenisSize())

func getInventory() -> Inventory:
	return inventory

func getLustInterests() -> LustInterests:
	return lustInterests

func getSkillsHolder() -> SkillsHolder:
	return skillsHolder

func getBuffsHolder() -> BuffsHolder:
	return buffsHolder

func getFetishHolder() -> FetishHolder:
	return fetishHolder

func getPersonality() -> Personality:
	return personality

func addExperience(newexp: int):
	skillsHolder.addExperience(newexp)

func addSkillExperience(skillID, amount:int, activityID = null):
	skillsHolder.addSkillExperience(skillID, amount, activityID)

func hasPerk(perkID):
	return skillsHolder.hasPerk(perkID)

func getStat(statID):
	return skillsHolder.getStat(statID)

func getSkillLevel(skillID):
	var skill = skillsHolder.getSkill(skillID)
	if(skill == null):
		return 0
	return skill.getLevel()

func getLevel() -> int:
	return skillsHolder.getLevel()

func getSpecies():
	return []

func getSpeciesFullName():
	var species = getSpecies()
	return Util.getSpeciesName(species)
	
func getFightIntro(_battleName):
	return getName() + " gets into the combat stance and prepares for a fight."

func getFightState(_battleName):
	if(getPainLevel() > getLustLevel()):
		var mypain = getPainLevel() * 100
		
		if(mypain >= 70):
			return getName() + " constantly grunts from pain. "+heShe()+" can barely stand at this point, all "+hisHer()+" bruises are really wearing "+himHer()+" down"
		if(mypain >= 50):
			return getName() + " looks pretty beat up and "+hisHer()+" face shows it but "+heShe()+" is still standing strong"
		if(mypain >= 25):
			return getName() + " has a bruise there and there but "+heShe()+" clearly won't give up the fight any time soon"
	else:
		var mylust = getLustLevel() * 100
		
		if(mylust >= 70):
			return getName() + " keeps moaning to "+himselfHerself()+" and can't hide the arousal anymore, "+heShe()+" blatantly gropes and rubs "+hisHer()+" body in front of you"
		if(mylust >= 50):
			return getName() + " breathes warmly, "+hisHer()+" blush starts to shine through, "+ heShe()+" is lusty and "+hisHer()+" eyes show it"
		if(mylust >= 25):
			return getName() + " looks alright but you notice some desire in "+hisHer()+" eyes"
		
	return getName() + " looks completely fine, no visible bruises or signs of lust"

func getLootTable(_battleName):
	return LootTableBase.new()

func getLoot(_battleName):
	var lootTable = getLootTable(_battleName)
	if(lootTable is String):
		lootTable = GlobalRegistry.getLootTable(lootTable)
	
	if(lootTable == null):
		return {"credits": 0, "items": []}
	
	var generatedLoot = lootTable.generate(getID(), _battleName)
	
	var resultCredits = 0
	
	var resultItems = []
	if(generatedLoot.has("items")):
		for generatedItemData in generatedLoot["items"]:
			var generatedItem = GlobalRegistry.createItem(generatedItemData[0])
			if(generatedItemData[1] > 1):
				generatedItem.setAmount(generatedItemData[1])
			resultItems.append(generatedItem)
	if(generatedLoot.has("credits")):
		resultCredits = generatedLoot["credits"]
	
	return {"credits": resultCredits, "items": resultItems}

func getBodypartTooltipName(_bodypartSlot):
	return "error"

func getBodypartTooltipInfo(_bodypartSlot):
	return "error"

func getPenisSize():
	var strapon = getWornStrapon()
	if(strapon != null):
		return strapon.getStraponLength()
	
	if(!hasBodypart(BodypartSlot.Penis)):
		return 20.0
	
	var bodypart = getBodypart(BodypartSlot.Penis)
	return bodypart.getLength()

func getFluidType(fluidSource):
	if(fluidSource == FluidSource.Penis):
		return "Cum"
	if(fluidSource == FluidSource.Vagina):
		return "GirlCum"
	if(fluidSource == FluidSource.Strapon):
		return "CumLube"
	if(fluidSource == FluidSource.Breasts):
		return "Milk"
	if(fluidSource == FluidSource.Pissing):
		return "Piss"
		
	return null

func getFluidAmount(fluidSource):
	if(fluidSource == FluidSource.Penis):
		if(hasBodypart(BodypartSlot.Penis)):
			var penis:BodypartPenis = getBodypart(BodypartSlot.Penis)
			return penis.getFluidProduction().getFluidAmount()
		return RNG.randf_range(100.0, 500.0)
	if(fluidSource == FluidSource.Vagina):
		return RNG.randf_range(50.0, 200.0)
	if(fluidSource == FluidSource.Strapon):
		return RNG.randf_range(100.0, 500.0)
	if(fluidSource == FluidSource.Pissing):
		return RNG.randf_range(100.0, 500.0)
	if(fluidSource == FluidSource.Breasts):
		if(hasBodypart(BodypartSlot.Breasts)):
			var breasts:BodypartBreasts = getBodypart(BodypartSlot.Breasts)
			return breasts.getFluidProduction().getFluidAmount()
		return 0.0
		
	return 0.0

func getFluidDNA(fluidSource):
	var fluidDNA = FluidDNA.new()
	fluidDNA.charID = getID()
	fluidDNA.virility = 0.0
	fluidDNA.species = getSpecies()
	
	# Fluids produced by your balls can always get someone pregnant
	if(fluidSource == FluidSource.Penis):
		fluidDNA.virility = getVirility()
	
	# Cum can get you pregnant even if it was generated elsewhere
	var fluidType = getFluidType(fluidSource)
	if(fluidType != null):
		var fluidObject = GlobalRegistry.getFluid(fluidType)
		if(fluidObject != null && fluidObject.canImpregnate()):
			fluidDNA.virility = getVirility()
	
	return fluidDNA

func getFemininity() -> int:
	return 50

func getThickness() -> int:
	return 50

func getFeminityAdjective():
	var fem = getFemininity()
	
	if(fem <= 33):
		return RNG.pick(["manly", "masculine"])

	if(fem >= 66):
		return RNG.pick(["girly", "feminine"])

	return RNG.pick(["androgynous"])
	
func getThicknessAdjective():
	var thick = getThickness()
	
	if(thick <= 10):
		return RNG.pick(["soft", "thin", "skinny", "athletic"])
	if(thick <= 35):
		return RNG.pick(["slim", "fit"])
	if(thick <= 75):
		return RNG.pick(["average", "round"])
	else:
		return RNG.pick(["soft", "plush", "thick", "wide"])

func onLevelChange():
	emit_signal("levelChanged")

func onSkillLevelChange(skillID):
	emit_signal("skillLevelChanged", skillID)

# Bodyparts stuff

func updateAppearance():
	#print(getName()+" UPDATED APPEARENCE "+Util.getStackFunction(3))
	emit_signal("bodypart_changed")

func resetSlots():
	for slot in BodypartSlot.getAll():
		if(bodyparts.has(slot) && bodyparts[slot] != null):
			bodyparts[slot].queue_free()
		bodyparts[slot] = null
	processingBodyparts.clear()

func giveBodypart(bodypart: Bodypart, emitSignal = true):
	if(bodypart == null):
		Log.printerr("Trying to give a null bodypart to "+str(self))
		return
	
	var slot = bodypart.getSlot()
	if(bodyparts.has(slot) && bodyparts[slot] != null):
		removeBodypart(slot, false)
		
	bodyparts[slot] = bodypart
	bodypartStorageNode.add_child(bodypart)
	bodypart.name = bodypart.visibleName
	bodypart.character = weakref(self)
	if(bodypart.needsProcessing):
		processingBodyparts.append(bodypart)
	
	if(emitSignal):
		emit_signal("bodypart_changed")

func giveBodypartUnlessSame(bodypart: Bodypart):
	var slot = bodypart.getSlot()
	if(bodyparts.has(slot) && bodyparts[slot] != null):
		if(bodypart.id == bodyparts[slot].id):
			bodypart.queue_free()
			return false
	giveBodypart(bodypart)
	return true

func hasBodypart(slot):
	if(bodyparts.has(slot) && bodyparts[slot] != null):
		return true
	return false
	
func getBodypart(slot):
	if(!bodyparts.has(slot)):
		Log.printerr("Trying to get bodypart from slot "+str(slot)+" when it doesn't exist.")
		return null
	return bodyparts[slot]

func getBodyparts():
	return bodyparts
	
func removeBodypart(slot, emitSignal = true):
	if(bodyparts.has(slot) && bodyparts[slot] != null):
		var bodypart = bodyparts[slot]
		bodypart.queue_free()
		
		if(processingBodyparts.has(bodypart)):
			processingBodyparts.erase(bodypart)
	bodyparts[slot] = null
	
	if(emitSignal):
		emit_signal("bodypart_changed")

func clearOrificeFluids():
	if(hasBodypart(BodypartSlot.Vagina)):
		getBodypart(BodypartSlot.Vagina).clearOrificeFluids()
	if(hasBodypart(BodypartSlot.Anus)):
		getBodypart(BodypartSlot.Anus).clearOrificeFluids()
	if(hasBodypart(BodypartSlot.Head)):
		getBodypart(BodypartSlot.Head).clearOrificeFluids()

func clearOrificeFluidsCheckBlocked():
	var success = true
	
	if(hasBodypart(BodypartSlot.Vagina)):
		if(!hasReachableVagina()):
			success = false
		else:
			getBodypart(BodypartSlot.Vagina).clearOrificeFluids()
	if(hasBodypart(BodypartSlot.Anus)):
		if(!hasReachableAnus()):
			success = false
		else:
			getBodypart(BodypartSlot.Anus).clearOrificeFluids()
	if(hasBodypart(BodypartSlot.Head)):
		getBodypart(BodypartSlot.Head).clearOrificeFluids()
		
	return success

func cummedInBodypartBy(bodypartSlot, characterID, sourceType = null, amountToTransfer = 1.0):
	var result = cummedInBodypartByAdvanced(bodypartSlot, characterID, {}, sourceType, amountToTransfer)

	return result["loadSize"]

func cummedInBodypartByAdvanced(bodypartSlot, characterID, advancedData:Dictionary={}, sourceType = null, amountToTransfer = 1.0):
	var noData = {loadSize=0.0,condomBroke=false}
	if(!hasBodypart(bodypartSlot)):
		return noData
	
	var resultAmount = 0.0
	var condomBroke = false
	
	var ch = GlobalRegistry.getCharacter(characterID)

	if(advancedData.has("condomBroke") && advancedData["condomBroke"]):
		condomBroke = true
	elif(advancedData.has("condom")):
		var condomBreakChance = advancedData["condom"]
		if(ch.shouldCondomBreakWhenFucking(self, condomBreakChance)):
			condomBroke = true
		else:
			return noData
	
	if(sourceType == null):
		if(ch.isWearingStrapon()): # Strapons are preffered because we could be wearing one while having a chastity cage
			sourceType = FluidSource.Strapon
		else:
			sourceType = FluidSource.Penis
	
	if(sourceType == FluidSource.Penis && ch.hasBodypart(BodypartSlot.Penis)):
		var thebodypart = getBodypart(bodypartSlot)
		var usedBodypart = ch.getBodypart(BodypartSlot.Penis)
		
		var fluids = usedBodypart.getFluids()
		
		if(fluids != null):
			resultAmount = fluids.transferTo(thebodypart, amountToTransfer)
	elif(sourceType == FluidSource.Strapon && ch.isWearingStrapon()):
		var thebodypart = getBodypart(bodypartSlot)
		var strapon = ch.getWornStrapon()
		
		var fluids = strapon.getFluids()
		if(fluids != null):
			resultAmount = fluids.transferTo(thebodypart, amountToTransfer)
	else:
		var thebodypart = getBodypart(bodypartSlot)
		resultAmount = ch.getFluidAmount(sourceType) * amountToTransfer
		thebodypart.addFluidOrifice(ch.getFluidType(sourceType), resultAmount, ch.getFluidDNA(sourceType))
	
	if(sourceType in [FluidSource.Penis, FluidSource.Strapon]):
		skillsHolder.receivedCreampie(characterID)
		if(ch != null && resultAmount > 0.0):
			ch.getSkillsHolder().cameInsideSomeone(getID())
	
	if(!advancedData.has("noEvent") || !advancedData["noEvent"]):
		if(sourceType == FluidSource.Penis):
			var event = SexEventHelper.create(SexEvent.HoleCreampied, characterID, getID(), {
				hole = bodypartSlot,
				loadSize = resultAmount,
				knotted = (advancedData.has("knotted") && advancedData["knotted"]),
				engulfed = (advancedData.has("engulfed") && advancedData["engulfed"]),
				condomBroke = condomBroke,
			})
			ch.sendSexEvent(event)
			sendSexEvent(event)
		if(sourceType == FluidSource.Strapon):
			var event = SexEventHelper.create(SexEvent.StraponCreampied, characterID, getID(), {
				hole = bodypartSlot,
				loadSize = resultAmount,
				knotted = (advancedData.has("knotted") && advancedData["knotted"]),
				engulfed = (advancedData.has("engulfed") && advancedData["engulfed"]),
			})
			ch.sendSexEvent(event)
			sendSexEvent(event)
	
	return {loadSize=resultAmount,condomBroke=condomBroke}
	
func cummedInVaginaBy(characterID, sourceType = null, amountToTransfer = 1.0):
	return cummedInBodypartBy(BodypartSlot.Vagina, characterID, sourceType, amountToTransfer)

func cummedInAnusBy(characterID, sourceType = null, amountToTransfer = 1.0):
	return cummedInBodypartBy(BodypartSlot.Anus, characterID, sourceType, amountToTransfer)

func cummedInMouthBy(characterID, sourceType = null, amountToTransfer = 1.0):
	return cummedInBodypartBy(BodypartSlot.Head, characterID, sourceType, amountToTransfer)

func cummedInVaginaByAdvanced(characterID, advancedData:Dictionary={}, sourceType = null, amountToTransfer = 1.0):
	return cummedInBodypartByAdvanced(BodypartSlot.Vagina, characterID, advancedData, sourceType, amountToTransfer)

func cummedInAnusByAdvanced(characterID, advancedData:Dictionary={}, sourceType = null, amountToTransfer = 1.0):
	return cummedInBodypartByAdvanced(BodypartSlot.Anus, characterID, advancedData, sourceType, amountToTransfer)

func cummedInMouthByAdvanced(characterID, advancedData:Dictionary={}, sourceType = null, amountToTransfer = 1.0):
	return cummedInBodypartByAdvanced(BodypartSlot.Head, characterID, advancedData, sourceType, amountToTransfer)

func rubsVaginasWith(characterID, chanceToStealCum = 100, showMessages = true):
	if(!RNG.chance(chanceToStealCum) || !OPTIONS.isContentEnabled(ContentType.CumStealing)):
		return
	
	if(!hasBodypart(BodypartSlot.Vagina)):
		return
	var ch = GlobalRegistry.getCharacter(characterID)
	if(ch == null || !ch.hasBodypart(BodypartSlot.Vagina)):
		return
	
	var orifice: Orifice = getBodypart(BodypartSlot.Vagina).getOrifice()
	var npcOrifice: Orifice = ch.getBodypart(BodypartSlot.Vagina).getOrifice()
	if(orifice == null || npcOrifice == null):
		return
	
	var success = orifice.shareFluids(npcOrifice, RNG.randf_range(0.2, 0.4))
	if(showMessages && success):
		emit_signal("exchangedCumDuringRubbing", getName(), ch.getName())

	if(true):
		var event = SexEventHelper.create(SexEvent.RubbedVaginas, getID(), characterID, {
			sharedFluids = success,
		})
		ch.sendSexEvent(event)
		sendSexEvent(event)

func getGenitalElasticity():
	var value = 0.0
	value += buffsHolder.getGenitalElasticity()
	return value
	
func getGenitalResistance():
	var value = 0.0
	value += buffsHolder.getGenitalResistance()
	return value

func getOrificeMinLooseness(orificeType):
	var value = 0.0
	value += buffsHolder.getOrificeMinLooseness(orificeType)
	return value
	
func getOrificePreventedFromRecovering(orificeType):
	if(buffsHolder.getOrificePreventedFromRecovering(orificeType)):
		return true
	
	return false
	
func getOrificeBlocked(orificeType):
	return buffsHolder.getOrificeBlocked(orificeType)

func gotOrificeStretchedWith(bodypartSlot, insertionSize, showMessages = true, stretchMult = 1.0):
	if(!hasBodypart(bodypartSlot)):
		return
	var thebodypart = getBodypart(bodypartSlot)
	
	var orifice: Orifice = thebodypart.getOrifice()
	if(orifice == null):
		return
	var oldLooseness = orifice.getLooseness()
	thebodypart.handleInsertion(insertionSize, stretchMult)
	var newLooseness = orifice.getLooseness()
	if(newLooseness > oldLooseness && showMessages):
		emit_signal("orificeBecomeMoreLoose", thebodypart.getOrificeName(), newLooseness, oldLooseness)

func gotOrificeStretchedBy(bodypartSlot, characterID, showMessages = true, stretchMult = 1.0):
	if(!hasBodypart(bodypartSlot)):
		return
	
	var ch = GlobalRegistry.getCharacter(characterID)
	assert(ch != null)
	gotOrificeStretchedWith(bodypartSlot, ch.getPenisSize(), showMessages, stretchMult)

func getPenetrationFreeRoom(bodypartSlot, insertionSize):
	if(!hasBodypart(bodypartSlot)):
		return 0.0
	var thebodypart = getBodypart(bodypartSlot)
	
	var orifice: Orifice = thebodypart.getOrifice()
	if(orifice == null):
		return 0.0
	
	var goodSize = orifice.getComfortableInsertion()
	
	var diff = goodSize - insertionSize
	return diff

func getPenetrationFreeRoomBy(bodypartSlot, characterID):
	var ch = GlobalRegistry.getCharacter(characterID)
	assert(ch != null)
	return getPenetrationFreeRoom(bodypartSlot, ch.getPenisSize())

func getPenetrateChance(bodypartSlot, insertionSize):
	if(!hasBodypart(bodypartSlot)):
		return 0.0
	var thebodypart = getBodypart(bodypartSlot)
	
	var orifice: Orifice = thebodypart.getOrifice()
	if(orifice == null):
		return 0.0
	
	var goodSize = orifice.getComfortableInsertion()
	
	var diff = insertionSize - goodSize
	if(diff <= 0.0):
		return 100.0
	
	return max(500.0 / (5.0 + diff), 30.0)

func getPenetrateChanceBy(bodypartSlot, characterID, isKnotting = false):
	var ch = GlobalRegistry.getCharacter(characterID)
	assert(ch != null)
	if(isKnotting && hasPerk(Perk.CumUniqueBiology)):
		return 100.0
	return getPenetrateChance(bodypartSlot, ch.getPenisSize())

func getKnottingChanceBy(bodypartSlot, characterID):
	return getPenetrateChanceBy(bodypartSlot, characterID, true)

func gotFuckedBy(bodypartSlot, characterID, showMessages = true, fireSexEvent = true):
	if(!hasBodypart(bodypartSlot)):
		return
	
	var ch = GlobalRegistry.getCharacter(characterID)
	assert(ch != null)
	gotOrificeStretchedWith(bodypartSlot, ch.getPenisSize(), showMessages)
	addStamina(buffsHolder.getCustom(BuffAttribute.StaminaRecoverAfterSex))
	ch.addStamina(ch.getBuffsHolder().getCustom(BuffAttribute.StaminaRecoverAfterSex))
	if(fireSexEvent):
		var event = SexEventHelper.create(SexEvent.HolePenetrated, characterID, getID(), {
			hole = bodypartSlot,
			engulfed = false,
			strapon = ch.isWearingStrapon(),
		})
		ch.sendSexEvent(event)
		sendSexEvent(event)

func gotVaginaFuckedBy(characterID, showMessages = true):
	return gotFuckedBy(BodypartSlot.Vagina, characterID, showMessages)

func gotAnusFuckedBy(characterID, showMessages = true):
	return gotFuckedBy(BodypartSlot.Anus, characterID, showMessages)

func gotThroatFuckedBy(characterID, showMessages = true):
	return gotFuckedBy(BodypartSlot.Head, characterID, showMessages)

func getExposure():
	return buffsHolder.getExposure()

# PREGNANCY STUFF

func getBaseFertility() -> float:
	return 1.0

func getFertility():
	if(hasPerk(Perk.StartInfertile)):
		return 0.0
	
	var value = getBaseFertility()
	
	value += buffsHolder.getFertility()
	
	value *= (1.0 + buffsHolder.getCustom(BuffAttribute.FinalFertilityModifier))
	
	return value

func getBaseVirility() -> float:
	return 1.0

func getVirility():
	if(hasPerk(Perk.StartMaleInfertility)):
		return 0.0
	
	var value = getBaseFertility()
	
	value += buffsHolder.getVirility()
	
	value *= (1.0 + buffsHolder.getCustom(BuffAttribute.FinalVirilityModifier))
	
	return value
	
func getBaseEggsMod() -> float:
	return 1.0

func getEggsBonusMod():
	var value = getBaseEggsMod()
	
	value += buffsHolder.getEggsBonusMod()
	
	return value
	
func getMinEggsAmount():
	var value = buffsHolder.getMinEggsAmount()
	
	return max(value, 1) 

func getCrossSpeciesCompatibility():
	var value = 0.0
	
	value += buffsHolder.getCrossSpeciesCompatibility()
	
	if(hasPerk(Perk.FertilityBroodmother) && value < 1.0):
		return 1.0
	
	return value

func onFluidObsorb(orificeType, cumType, howMuch, fluidDNA):
	if(menstrualCycle != null):
		menstrualCycle.obsorbCum(cumType, howMuch, fluidDNA, orificeType)

func getMenstrualCycle():
	return menstrualCycle

func isPregnant():
	if(menstrualCycle != null):
		return menstrualCycle.isPregnant()
	return false

func isVisiblyPregnant():
	if(menstrualCycle != null):
		return menstrualCycle.isVisiblyPregnant()
	return false

func isVisiblyPregnantFromPlayer():
	if(menstrualCycle != null):
		return menstrualCycle.isVisiblyPregnantFromPlayer()
	return false

func isHeavilyPregnant():
	if(menstrualCycle != null):
		return menstrualCycle.getPregnancyProgress() > 0.66
	return false

func isReadyToGiveBirth():
	if(menstrualCycle != null):
		return menstrualCycle.isReadyToGiveBirth()
	return false

func giveBirth():
	if(menstrualCycle == null):
		return []
	
	clearOrificeFluids()
	var bornChildren = getMenstrualCycle().giveBirth()
	for child in bornChildren:
		GM.CS.addChild(child)
	
	return bornChildren

func forceOvulate():
	if(menstrualCycle != null):
		return menstrualCycle.forceOvulate()
	return false

func forceIntoHeat():
	if(menstrualCycle != null):
		menstrualCycle.forceIntoHeat()

func forceImpregnateBy(otherCharacterID):
	if(menstrualCycle != null):
		return menstrualCycle.forceImpregnateBy(otherCharacterID)
	return false

func getPregnancyProgress():
	if(menstrualCycle != null):
		return menstrualCycle.getPregnancyProgress()
	return 0.0

func isInHeat():
	if(menstrualCycle != null):
		return menstrualCycle.isInHeat()
	return false

func onGivingBirth(_impregnatedEggCells: Array, _newkids: Array):
	var amountPerOrifice = {}
	for egg in _impregnatedEggCells:
		if(!amountPerOrifice.has(egg.getOrifice())):
			amountPerOrifice[egg.getOrifice()] = 0
		amountPerOrifice[egg.getOrifice()] += 1
	
	# This is meh
	var mapping = {
		OrificeType.Vagina: BodypartSlot.Vagina,
		OrificeType.Anus: BodypartSlot.Anus,
		OrificeType.Throat: BodypartSlot.Head,
	}
	
	for orificeType in mapping:
		if(!amountPerOrifice.has(orificeType)):
			continue
		
		var amountToStretch = sqrt(amountPerOrifice[orificeType]) * 30.0
		
		gotOrificeStretchedWith(mapping[orificeType], amountToStretch)

# END OF PREGNANCY STUFF

func hasPenis():
	return hasBodypart(BodypartSlot.Penis)

func hasReachablePenis():
	if(buffsHolder.hasBuff(Buff.ChastityPenisBuff)):
		return false
	return hasPenis()

func hasVagina():
	return hasBodypart(BodypartSlot.Vagina)

func hasReachableVagina():
	if(buffsHolder.hasBuff(Buff.ChastityVaginaBuff)):
		return false
	return hasVagina()

func hasAnus():
	return true

func hasReachableAnus():
	if(buffsHolder.hasBuff(Buff.ChastityAnusBuff)):
		return false
	return hasAnus()

func hasHair():
	return hasBodypart(BodypartSlot.Hair) && getBodypart(BodypartSlot.Hair).id != "baldhair"

func hasTail():
	return hasBodypart(BodypartSlot.Tail)
	
func hasHorns():
	return hasBodypart(BodypartSlot.Horns)

func hasNonFlatBreasts():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return false
	var breasts = getBodypart(BodypartSlot.Breasts)
	
	var size = breasts.getSize()
	
	if(size > BreastsSize.FLAT):
		return true
	else:
		return false

func hasBigBreasts():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return false
	var breasts = getBodypart(BodypartSlot.Breasts)
	
	var size = breasts.getSize()
	
	if(size > BreastsSize.C):
		return true
	else:
		return false

func hasSmallBreasts():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return true
	var breasts = getBodypart(BodypartSlot.Breasts)
	
	var size = breasts.getSize()
	
	if(size <= BreastsSize.B):
		return true
	else:
		return false

func isLactating():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return false
	var breasts: BodypartBreasts = getBodypart(BodypartSlot.Breasts)
	var production: FluidProduction = breasts.getFluidProduction()
	if(production == null):
		return false
	return production.shouldProduce()
	
func canBeMilked():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return false
	var breasts: BodypartBreasts = getBodypart(BodypartSlot.Breasts)
	var production: FluidProduction = breasts.getFluidProduction()
	if(production == null):
		return false
	return production.getFluidAmount() > 0.0

func hasBreastsFullOfMilk():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return false
	var breasts: BodypartBreasts = getBodypart(BodypartSlot.Breasts)
	var production: FluidProduction = breasts.getFluidProduction()
	if(production == null):
		return false
	return production.getFluidLevel() >= 1.0

func milk(howmuch = 1.0):
	if(!hasBodypart(BodypartSlot.Breasts)):
		return 0.0
	var breasts: BodypartBreasts = getBodypart(BodypartSlot.Breasts)
	var production: FluidProduction = breasts.getFluidProduction()
	if(production == null):
		return 0.0
	var howMuchMilk = production.drain(howmuch)
	production.afterMilked()
	if(!hasPerk(Perk.MilkNoSoreNipples) && howmuch >= 0.5):
		addEffect(StatusEffect.SoreNipplesAfterMilking)
	if(isPlayer()):
		addSkillExperience(Skill.Milking, 20)
	return howMuchMilk

func breastFedBy(characterID, amountToTransfer = 1.0):
	var ch = GlobalRegistry.getCharacter(characterID)
	
	if(ch.hasBodypart(BodypartSlot.Breasts)):
		var thebodypart = getBodypart(BodypartSlot.Head)
		var usedBodypart = ch.getBodypart(BodypartSlot.Breasts)
		
		var fluids = usedBodypart.getFluids()
		
		if(fluids != null && thebodypart != null):
			fluids.transferTo(thebodypart, amountToTransfer)
		
		var production: FluidProduction = usedBodypart.getFluidProduction()
		if(production != null):
			production.afterMilked()
		
	if(!ch.hasPerk(Perk.MilkNoSoreNipples) && amountToTransfer >= 0.5):
		ch.addEffect(StatusEffect.SoreNipplesAfterMilking)
			
func induceLactation():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return false
	
	var breasts = getBodypart(BodypartSlot.Breasts)
	breasts.induceLactation()

func stimulateLactation():
	if(!hasBodypart(BodypartSlot.Breasts)):
		return false
	
	var breasts: BodypartBreasts = getBodypart(BodypartSlot.Breasts)
	var production: Lactation = breasts.getFluidProduction()
	if(production == null):
		return false
	if(production.has_method("stimulate")):
		return production.stimulate()
	if(isPlayer()):
		addSkillExperience(Skill.Milking, 10)
	return false

func canBeSeedMilked():
	if(!hasBodypart(BodypartSlot.Penis)):
		return false
	var penis: BodypartPenis = getBodypart(BodypartSlot.Penis)
	var production: FluidProduction = penis.getFluidProduction()
	if(production == null):
		return false
	return production.getFluidAmount() > 0.0

func milkSeed(howmuch = 1.0):
	if(!hasBodypart(BodypartSlot.Penis)):
		return 0.0
	var penis: BodypartPenis = getBodypart(BodypartSlot.Penis)
	var production: FluidProduction = penis.getFluidProduction()
	if(production == null):
		return 0.0
	var howMuchSeed = production.drain(howmuch)
	production.afterMilked()
	return howMuchSeed

func getCumInflationLevel():
	if(!OPTIONS.isContentEnabled(ContentType.CumInflation)):
		return 0.0
	
	var bodypartsToCalculate = [BodypartSlot.Head, BodypartSlot.Vagina, BodypartSlot.Anus]
	var totalAmount = 0.0

	for bodypartSlot in bodypartsToCalculate:
		if(!hasBodypart(bodypartSlot)):
			continue
		var bodypart:Bodypart = getBodypart(bodypartSlot)
		var orifice: Orifice = bodypart.getOrifice()
		if(orifice == null):
			continue
		
		totalAmount += orifice.getFluidAmount()
		
	# If we have more than 3L inside of us, anything extra makes us inflated
	var threshold = 3000.0
	var tooMuch = max(totalAmount - threshold, 0.0)
	
	return max(tooMuch / 2000.0, 0.0)
# Doll stuff

func getDollParts() -> Dictionary:
	var parts = {}
	for bodypartSlot in bodyparts:
		if(bodyparts[bodypartSlot] == null):
			continue
		var bodypart: Bodypart = bodyparts[bodypartSlot]
		
		var partSlot = bodypart.getSlot()
		if(partSlot == null || partSlot == ""):
			continue
		
		var partScene = bodypart.getDoll3DScene()
		if(partScene == null || partScene == ""):
			continue
		
		parts[partSlot] = partScene
	return parts

func updateLeaking(doll: Doll3D):
	if(hasEffect(StatusEffect.BreastsFull)):
		doll.setBreastsLeaking(true)
	else:
		doll.setBreastsLeaking(false)
		
	if(hasEffect(StatusEffect.HasCumInsideVagina) && !buffsHolder.hasBuff(Buff.BlocksVaginaLeakingBuff)):
		doll.setPussyLeaking(true)
	else:
		doll.setPussyLeaking(false)

	if(hasEffect(StatusEffect.HasCumInsideAnus) && !buffsHolder.hasBuff(Buff.BlocksAnusLeakingBuff)):
		doll.setAnusLeaking(true)
	else:
		doll.setAnusLeaking(false)

func softUpdateDoll(doll: Doll3D):
	var skinData = {}
	var bodySkinData = getSkinData()
	var fieldsToCheckSkin = ["skin", "r", "g", "b"]
	for bodypartSlot in bodyparts:
		var bodypart = getBodypart(bodypartSlot)
		if(bodypart == null):
			continue
		if(bodypart.supportsSkin()):
			var bodypartSkinData = bodypart.getSkinData()
			for field in fieldsToCheckSkin:
				if(!bodypartSkinData.has(field) || bodypartSkinData[field] == null):
					if(bodySkinData.has(field)):
						bodypartSkinData[field] = bodySkinData[field]
			
			skinData[bodypartSlot] = bodypartSkinData
	doll.setSkinData(skinData)
	if(hasEffect(StatusEffect.CoveredInCum)):
		doll.setCumAmount(getOutsideMessinessLevel())
		var dominantFluidID = getFluids().getDominantFluidID()
		if(dominantFluidID != null):
			var fluidObject = GlobalRegistry.getFluid(dominantFluidID)
			if(fluidObject != null):
				doll.setCumColor(fluidObject.getCumOverlayColor())
		else:
			doll.setCumColor(Color.white)
	else:
		doll.setCumAmount(0)
	doll.updateMaterials()
	
	doll.setArmsCuffed(false)
	doll.setLegsCuffed(false)
	doll.setState("mouth", "")
	doll.setState("muzzle", "")
	doll.setState("gloves", "")
	doll.setState("armalpha", "")
	if(bodypartHasTrait(BodypartSlot.Legs, PartTrait.LegsPlanti)):
		doll.setState("legstype", "planti")
	elif(bodypartHasTrait(BodypartSlot.Legs, PartTrait.LegsDigi)):
		doll.setState("legstype", "digi")
	elif(bodypartHasTrait(BodypartSlot.Legs, PartTrait.LegsHoofs)):
		doll.setState("legstype", "hoofs")
	else:
		doll.setState("legstype", "")
	updateLeaking(doll)
	
	if(isReadyToPenetrate()):
		doll.setState("cock", "")
	else:
		doll.setState("cock", "limp")
	
	var breastsScale = 1.0
	if(hasBodypart(BodypartSlot.Breasts)):
		var breasts = getBodypart(BodypartSlot.Breasts)
		if(breasts.has_method("getBreastsScale")):
			breastsScale = breasts.getBreastsScale()
		doll.breastScale = breasts.getBreastsAdjustScale()
	else:
		doll.breastScale = 0.0
	doll.setBreastsScale(breastsScale)
	
	if(hasBodypart(BodypartSlot.Head)):
		var thehead = getBodypart(BodypartSlot.Head)
		if(thehead.has_method("getHeadLength")):
			doll.headLength = thehead.getHeadLength()
		else:
			doll.headLength = 0.0
	else:
		doll.headLength = 0.0
	
	var penisScale = 1.0
	var ballsScale = 1.0
	if(hasBodypart(BodypartSlot.Penis)):
		var penis = getBodypart(BodypartSlot.Penis)
		if(penis.has_method("getPenisScale")):
			penisScale = penis.getPenisScale()
		if(penis.has_method("getBallsScale")):
			ballsScale = penis.getBallsScale()
	doll.setPenisScale(penisScale)
	doll.setBallsScale(ballsScale)
	
	if(hasNonFlatBreasts()):
		doll.setState("breasts", "nonflat")
	else:
		doll.setState("breasts", "flat")

	var pregnancyValue = getPregnancyProgress()
	
	var thicknessNorm = getThickness() / 100.0
	var femNorm = getFemininity() / 100.0
	var pregnancyAddition = 0.0
	if(femNorm < 0.5):
		pregnancyAddition = -0.1 * (1.0 - (femNorm * 2.0))
	
	pregnancyValue += pregnancyAddition
	
	var cumInflationLevel = getCumInflationLevel()
	pregnancyValue += clamp(cumInflationLevel / 2.0, 0.0, 1.0)
	
	doll.setPregnancy(clamp(pregnancyValue, -0.5, 1.1))
	
	if(thicknessNorm <= 0.5):
		doll.setButtScale(1.0 - 0.2 * (1.0 - thicknessNorm * 2))
		doll.setThighThickness(- 0.4 * (1.0 - thicknessNorm * 2))
	else:
		doll.setButtScale(1.0 + (thicknessNorm - 0.5)/1.5)
		doll.setThighThickness((thicknessNorm - 0.5))
	
	doll.selfChains = []
	var wearingItems = getInventory().getAllEquippedItems()
	for inventorySlot in wearingItems:
		var item = wearingItems[inventorySlot]
		if(item == null):
			continue
		
		# Add a check here that the item is actually visible first?
		item.updateDoll(doll)
		
		var newChains = item.getChains()
		if(newChains != null):
			for selfChain in newChains:
				doll.selfChains.append([selfChain[0], selfChain[1], "self", selfChain[2]])
			#doll.selfChains.append_array(newChains)
	doll.call_deferred("checkChains")

func updateDoll(doll: Doll3D):
	softUpdateDoll(doll)
	
	var parts = getDollParts()
	
	var newAlphas = {}
	var newAttachmentAlphas = {}

	var exposedBodyparts = doll.getExposedBodyparts()

	var partsScenes = {}
	var equippedItems = getInventory().getAllEquippedItems()
	for inventorySlot in equippedItems:
		var item = equippedItems[inventorySlot]
		if(!item.shouldBeVisibleOnDoll(self, doll)):
			continue
		
		var blocksBodyparts = item.coversBodyparts()
		if(!(item.alwaysVisible() && !doll.isOnlyPenis) && exposedBodyparts!=null && exposedBodyparts.size() > 0 && blocksBodyparts != null):
			var shouldBeSkipped = false
			for exposedBodypart in exposedBodyparts:
				if(blocksBodyparts.has(exposedBodypart)):
					shouldBeSkipped = true
					break
			if(shouldBeSkipped):
				continue
		
		var alphaStuff = item.getHidesParts(self)
		if(alphaStuff != null):
			for zone in alphaStuff:
				newAlphas[zone] = true
				
		var alphaStuff2 = item.getHidesAttachments(self)
		if(alphaStuff2 != null):
			for zone in alphaStuff2:
				newAttachmentAlphas[zone] = true
		
		var riggedScenes = item.getRiggedParts(self)
		if(riggedScenes == null):
			 continue
			
		for zone in riggedScenes:
			parts[zone] = riggedScenes[zone]
	
	for inventorySlot in equippedItems:
		var item = equippedItems[inventorySlot]
		
		var scenes = item.getUnriggedParts(self)
		if(scenes == null):
			 continue
		
		for zone in scenes:
			if(!partsScenes.has(zone)):
				partsScenes[zone] = []
			partsScenes[zone].append_array(scenes[zone])

	doll.setHiddenParts(newAlphas)
	doll.setHiddenAttachmentZones(newAttachmentAlphas)
	doll.setParts(parts)
	doll.setUnriggedParts(partsScenes)
	
func getSkillExperienceMult(skill):
	var mult = 0.0

	mult += buffsHolder.getSkillExperienceMult(skill)

	return mult

func getBestZoneForTallymark(zonelist):
	if(zonelist is int):
		return zonelist
	if(zonelist.size() == 0):
		return null
	
	var marks = {}
	if(hasEffect(StatusEffect.HasTallyMarks)):
		marks = getEffect(StatusEffect.HasTallyMarks).marks
	
	var possible = []
	for zone in zonelist:
		var zonestr = str(zone)
		var currentAmount = 0
		if(marks.has(zonestr)):
			currentAmount = marks[zonestr]
		
		var value:float = 1.0
		if(currentAmount >= 1 && currentAmount < 20):
			value = 1000.0 / float(currentAmount)
		possible.append([zone, value])
	return RNG.pickWeightedPairs(possible)

func addTallymark(zone):
	addEffect(StatusEffect.HasTallyMarks, [zone])

func addTallymarkPickBestZone(zonelist):
	var bestZone = getBestZoneForTallymark(zonelist)
	addEffect(StatusEffect.HasTallyMarks, [bestZone])
	return bestZone

func addTallymarkFace():
	return addTallymarkPickBestZone([
		BodyWritingsZone.CheekLeft,
		BodyWritingsZone.CheekRight,
	])

func addTallymarkCrotch():
	return addTallymarkPickBestZone([
		BodyWritingsZone.LowerAbdomen,
		BodyWritingsZone.HipLeft,
		BodyWritingsZone.HipRight,
		BodyWritingsZone.ButtcheekLeft,
		BodyWritingsZone.ButtcheekRight,
		BodyWritingsZone.ThighLeft,
		BodyWritingsZone.ThighRight,
	])

func addTallymarkButt():
	return addTallymarkCrotch()

func hasTallymarks():
	return hasEffect(StatusEffect.HasTallyMarks)

func clearTallymarks():
	removeEffect(StatusEffect.HasTallyMarks)

func addBodywriting(zone, writingID):
	addEffect(StatusEffect.HasBodyWritings, [zone, writingID])

func addBodywritingRandom():
	var zone = BodyWritingsZone.getRandomZone()
	addBodywriting(zone, BodyWritings.getRandomWritingIDForZone(zone))

func hasBodywritings():
	return hasEffect(StatusEffect.HasBodyWritings)

func clearBodywritings():
	removeEffect(StatusEffect.HasBodyWritings)

func hasBoundArms():
	return buffsHolder.hasBuff(Buff.RestrainedArmsBuff)

func hasBlockedHands():
	return buffsHolder.hasBuff(Buff.BlockedHandsBuff)

func hasBoundLegs():
	return buffsHolder.hasBuff(Buff.RestrainedLegsBuff)

func isBlindfolded():
	return buffsHolder.hasBuff(Buff.BlindfoldBuff)

func isBitingBlocked():
	return buffsHolder.hasBuff(Buff.GagBuff) || buffsHolder.hasBuff(Buff.RingGagBuff) || buffsHolder.hasBuff(Buff.MuzzleBuff)

func isGagged():
	return buffsHolder.hasBuff(Buff.GagBuff) || buffsHolder.hasBuff(Buff.RingGagBuff)

func isOralBlocked():
	return buffsHolder.hasBuff(Buff.GagBuff) || buffsHolder.hasBuff(Buff.MuzzleBuff)

func isMuzzled():
	return buffsHolder.hasBuff(Buff.MuzzleBuff)

func invCanEquipSlot(slot):
	if(slot == InventorySlot.Penis && !hasPenis()):
		return false
	if(slot == InventorySlot.Vagina && !hasVagina()):
		return false
	
	return true

func getRestraintResistance():
	return 0.9

func getRestraintStrugglePower():
	return 1.0

func getRestraintStrugglingMinigameResult():
	return RNG.randf_range(0.8, 1.1)

func processStruggleTurn(isActivelyStruggling = false):
	var texts = []
	var damage = 0.0
	var lockDamage = 0.0
	var addLust = 0
	var addPain = 0
	var addStamina = 0
	
	for item in getInventory().getEquppedRestraints():
		var restraintData: RestraintData = item.getRestraintData()
		var struggleData = restraintData.processStruggleTurn(self, isActivelyStruggling).build()
		
		if(struggleData == null):
			continue
			
		if(struggleData.has("damage")):
			damage += struggleData["damage"]
		if struggleData.has("lockDamage"):
			lockDamage += struggleData["lockDamage"]
		if(struggleData.has("lust")):
			addLust += struggleData["lust"]
		if(struggleData.has("pain")):
			addPain += struggleData["pain"]
		if(struggleData.has("stamina")):
			addStamina += struggleData["stamina"]
		if(struggleData.has("text") && struggleData["text"] != ""):
			texts.append(struggleData["text"])
			#additionalStruggleText += struggleData["text"] + "\n\n"
		
	return {"damage": damage, "lockDamage": lockDamage, "lust": addLust, "pain": addPain, "stamina": addStamina, "text": Util.join(texts, "\n\n")}

func processLockpickTurn(_isActive = true):
	var texts = []
	var damage = 0.0
	var lockDamage = 0.0
	var addLust = 0
	var addPain = 0
	var addStamina = 0
	
	for item in getInventory().getEquppedRestraints():
		var restraintData: RestraintData = item.getRestraintData()
		var result = restraintData.processLockpickTurn(self, _isActive)
	
		if result == null:
			continue
		
		if result.has("damage"):
			damage += result["damage"]
		if result.has("lockDamage"):
			lockDamage += result["lockDamage"]
		if result.has("lust"):
			addLust += result["lust"]
		if result.has("pain"):
			addPain += result["pain"]
		if result.has("stamina"):
			addStamina += result["stamina"]
		if result.has("text"):
			texts.append(result["text"])
		
	return {"damage": damage, "lockDamage": lockDamage, "lust": addLust, "pain": addPain, "stamina": addStamina, "text": Util.join(texts, "\n\n")}

func processCutTurn(_isActive = true):
	var texts = []
	var damage = 0.0
	var lockDamage = 0.0
	var addLust = 0
	var addPain = 0
	var addStamina = 0
	
	for item in getInventory().getEquppedRestraints():
		var restraintData: RestraintData = item.getRestraintData()
		var result = restraintData.processCutTurn(self, _isActive)
	
		if result == null:
			continue
		
		if result.has("damage"):
			damage += result["damage"]
		if result.has("lockDamage"):
			lockDamage += result["lockDamage"]
		if result.has("lust"):
			addLust += result["lust"]
		if result.has("pain"):
			addPain += result["pain"]
		if result.has("stamina"):
			addStamina += result["stamina"]
		if result.has("text"):
			texts.append(result["text"])
		
	return {"damage": damage, "lockDamage": lockDamage, "lust": addLust, "pain": addPain, "stamina": addStamina, "text": Util.join(texts, "\n\n")}


func getCustomAttribute(id):
	return buffsHolder.getCustom(id)

func getBlockArmor() -> int:
	return 20 + buffsHolder.getCustom(BuffAttribute.BlockArmor)

func getDefocusArmor() -> int:
	return 20 + buffsHolder.getCustom(BuffAttribute.DefocusArmor)

func isBodypartCovered(bodypartSlot):
	var equippedItems = inventory.getAllEquippedItems()
	for inventorySlot in equippedItems:
		var item = equippedItems[inventorySlot]
		if(item.coversBodypart(bodypartSlot)):
			return true

	return false

func afterOrgasm(_isSexEngine = false):
	if(!_isSexEngine):
		cumOnFloor()
		addLust(-lust)
	
	if(hasBodypart(BodypartSlot.Penis)):
		var penis:BodypartPenis = getBodypart(BodypartSlot.Penis)
		var production: FluidProduction = penis.getFluidProduction()
		if(production != null):
			production.fillPercent(buffsHolder.getCustom(BuffAttribute.CumGenerationAfterOrgasm))

func cumOnFloor(_characterID: String = ""):
	if(hasBodypart(BodypartSlot.Penis)):
		var penis:BodypartPenis = getBodypart(BodypartSlot.Penis)
		var production: FluidProduction = penis.getFluidProduction()
		if(production != null):
			if(getWornCondom() != null):
				return cumInItem(getWornCondom())
			if(getWornPenisPump() != null):
				var result = cumInItem(getWornPenisPump()) # Collect some into the penis pump
				var returnValue = penis.getFluidProduction().drain() # Waste the rest
				
				if(_characterID != ""):
					var event = SexEventHelper.create(SexEvent.PenisPumpMilked, _characterID, getID(), {
						loadSize = result,
					})
					sendSexEvent(event)
					if(_characterID != getID()):
						var otherChar = GlobalRegistry.getCharacter(_characterID)
						if(otherChar != null):
							otherChar.sendSexEvent(event)
				return result + returnValue
			
			var returnValue = penis.getFluidProduction().drain()
			return returnValue

func cumInItem(theItem, sourceType = FluidSource.Penis, amountToTransfer = 1.0):
	if(theItem.getFluids() == null):
		return 0.0
	
	if(sourceType == FluidSource.Penis && hasBodypart(BodypartSlot.Penis)):
		var penis:BodypartPenis = getBodypart(BodypartSlot.Penis)
		var production: FluidProduction = penis.getFluidProduction()
		if(production != null):
			if(theItem.has_method("markLastUser")):
				theItem.markLastUser(getName())
			var returnValue = penis.getFluids().transferTo(theItem, amountToTransfer)
			return returnValue
	else:
		return theItem.getFluids().addFluid(getFluidType(sourceType), getFluidAmount(sourceType) * amountToTransfer, getFluidDNA(sourceType))

func createFilledCondom():
	var theCondom = GlobalRegistry.createItem("UsedCondom")
	cumInItem(theCondom)
	return theCondom

func lustStateFullyUndress():
	var items = getInventory().getAllEquippedItems()
	for itemSlot in items:
		var lustState = items[itemSlot].getItemState()
		if(lustState != null):
			lustState.remove()

func afterSexEnded(sexInfo):
	if(sexInfo.getTimesCame() > 0):
		addLust(-getLust())
		
		if(isPlayer()):
			addStamina(buffsHolder.getCustom(BuffAttribute.StaminaRecoverAfterSex))
			addSkillExperience(Skill.SexSlave, 30)
	if(!isPlayer()):
		addLust(-getLust())
		addPain(-getPain())
		addStamina(getMaxStamina())
	consciousness = 1.0
	arousal = 0.0
		
	for effectID in statusEffects.keys():
		var effect = statusEffects[effectID]
		if(effect.isSexEngineOnly):
			removeEffect(effectID)
		
	var items = getInventory().getAllEquippedItems()
	for itemSlot in items:
		var item = items[itemSlot]
		item.resetLustState()
		item.onSexEnd()
		
	if(personalityChangesAfterSex() && personality != null && fetishHolder != null):
		var resultText = sexInfo.affectPersonality(personality, fetishHolder)
		if(resultText != null && resultText != ""):
			GM.main.addMessage(resultText)
		
	updateAppearance()

func createVoice():
	sexVoice = SexVoice.new()
	sexVoice.setCharacter(self)

func getVoice() -> SexVoice:
	return sexVoice

func getFirstItemThatCoversBodypart(bodypartSlot):
	return getInventory().getFirstItemThatCoversBodypart(bodypartSlot)
	
func getWornCondom():
	if(getInventory().hasSlotEquipped(InventorySlot.Penis)):
		var item = getInventory().getEquippedItem(InventorySlot.Penis)
		if(item.id == "UsedCondom"):
			return item
	return null

func getWornPenisPump():
	if(getInventory().hasSlotEquipped(InventorySlot.Penis)):
		var item = getInventory().getEquippedItem(InventorySlot.Penis)
		if(item.hasTag(ItemTag.PenisPump)):
			return item
	return null

func isWearingCondom():
	return getWornCondom() != null

func getArousal() -> float:
	return clamp(arousal, 0.0, 1.0)

func addArousal(adda:float):
	arousal += adda
	#arousal = clamp(arousal, 0.0, 1.0)

func setArousal(newa:float):
	arousal = clamp(newa, 0.0, 1.0)

func getConsciousness() -> float:
	return consciousness

func addConsciousness(newc:float):
	consciousness += newc
	consciousness = clamp(consciousness, 0.0, 1.0)

func isReadyToPenetrate() -> bool:
	return getLustLevel() >= 0.5 || getLust() >= 50 || getArousal() >= 0.4 || isWearingStrapon()

func isWearingChastityCage() -> bool:
	# Having a chastity cage also means that you have a penis
	if(!hasBodypart(BodypartSlot.Penis)):
		return false
	
	if(!getInventory().hasSlotEquipped(InventorySlot.Penis)):
		return false
	
	var item = getInventory().getEquippedItem(InventorySlot.Penis)
	if(item.hasTag(ItemTag.ChastityCage)):
		return true
	return false

#example return values: some cum | a mixture of cum and girlcum | a mixture of cum, black goo and girlcum
func getBodypartContentsStringList(bodypartID):
	if(!hasBodypart(bodypartID)):
		return "some cum"
	var bodypart = getBodypart(bodypartID)
	var orifice = bodypart.getOrifice()
	if(orifice == null):
		return "some cum"
	
	var messFluids = orifice.getFluidList()
	if(messFluids == null || messFluids.size() == 0):
		return "some cum"
	
	var processedFluidNames = []
	for fluidID in messFluids:
		processedFluidNames.append(BodilyFluids.getFluidName(fluidID))
	
	if(processedFluidNames.size() == 1):
		return "some "+processedFluidNames[0]
	
	return "a mixture of "+Util.humanReadableList(processedFluidNames)

func bodypartTransferFluidsTo(bodypartID, otherCharacterID, otherBodypartID, fraction = 0.5, minAmount = 0.0):
	if(!hasBodypart(bodypartID)):
		return false
	var bodypart = getBodypart(bodypartID)
	var orifice = bodypart.getOrifice()
	if(orifice == null):
		return false
	
	var otherCharacter = GlobalRegistry.getCharacter(otherCharacterID)
	if(otherCharacter == null):
		return false
	if(!otherCharacter.hasBodypart(otherBodypartID)):
		return false
	var otherBodypart = otherCharacter.getBodypart(otherBodypartID)
	var otherOrifice = otherBodypart.getOrifice()
	if(otherOrifice == null):
		return false
	
	return orifice.transferTo(otherOrifice, fraction, minAmount) > 0.0

func bodypartTransferFluidsToAmount(bodypartID, otherCharacterID, otherBodypartID, fraction = 0.5, minAmount = 0.0):
	if(!hasBodypart(bodypartID)):
		return 0.0
	var bodypart = getBodypart(bodypartID)
	var orifice = bodypart.getOrifice()
	if(orifice == null):
		return 0.0
	
	var otherCharacter = GlobalRegistry.getCharacter(otherCharacterID)
	if(otherCharacter == null):
		return 0.0
	if(!otherCharacter.hasBodypart(otherBodypartID)):
		return 0.0
	var otherBodypart = otherCharacter.getBodypart(otherBodypartID)
	var otherOrifice = otherBodypart.getOrifice()
	if(otherOrifice == null):
		return 0.0
	
	return orifice.transferTo(otherOrifice, fraction, minAmount)

func bodypartShareFluidsWith(bodypartID, otherCharacterID, otherBodypartID, fraction = 0.5):
	if(!hasBodypart(bodypartID)):
		return false
	var bodypart = getBodypart(bodypartID)
	var orifice = bodypart.getOrifice()
	if(orifice == null):
		return false
	
	var otherCharacter = GlobalRegistry.getCharacter(otherCharacterID)
	if(otherCharacter == null):
		return false
	if(!otherCharacter.hasBodypart(otherBodypartID)):
		return false
	var otherBodypart = otherCharacter.getBodypart(otherBodypartID)
	var otherOrifice = otherBodypart.getOrifice()
	if(otherOrifice == null):
		return false
	
	return orifice.shareFluids(otherOrifice, fraction)

func processSexTurn():
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.processSexTurn()
		
	#buffsHolder.calculateBuffs()

func addTimedBuffs(buffs: Array, seconds):
	for newbuff in buffs:
		var foundBuff = false
		for oldbuff in timedBuffs:
			if(newbuff.id == oldbuff.id && oldbuff.canCombine(newbuff)):
				oldbuff.combine(newbuff)
				foundBuff = true
				break
		if(!foundBuff):
			timedBuffs.append(newbuff)
	
	if(seconds > timedBuffsDurationSeconds):
		timedBuffsDurationSeconds = seconds

func addTimedBuffsTurns(buffs: Array, turns):
	if(!GM.main.supportsBattleTurns()):
		return
	
	for newbuff in buffs:
		var foundBuff = false
		for oldbuff in timedBuffsTurns:
			if(newbuff.id == oldbuff.id && oldbuff.canCombine(newbuff)):
				oldbuff.combine(newbuff)
				foundBuff = true
				break
		if(!foundBuff):
			timedBuffsTurns.append(newbuff)
	
	if(turns > timedBuffsDurationTurns):
		timedBuffsDurationTurns = turns

func updateNonBattleEffects():
	buffsHolder.calculateBuffs()

func saveBuffsData(buffs):
	var data = []
	
	for buff in buffs:
		var buffData = {
			"id": buff.id,
			"buffdata": buff.saveData(),
		}
		data.append(buffData)
	return data

func loadBuffsData(data):
	var result = []
	
	for buffFullData in data:
		var id = SAVE.loadVar(buffFullData, "id", "error")
		var buffdata = SAVE.loadVar(buffFullData, "buffdata", {})
		
		var buff: BuffBase = GlobalRegistry.createBuff(id)
		buff.loadData(buffdata)
		result.append(buff)
	return result

func bodypartHasTrait(bodypartSlot, traitID):
	if(!hasBodypart(bodypartSlot)):
		return false
	
	var bodypart = getBodypart(bodypartSlot)
	return bodypart.hasTrait(traitID)

func hasAnyWomb():
	if(menstrualCycle == null):
		return false
	return menstrualCycle.hasAnyWomb()

func hasWombIn(bodypartSlot):
	if(!hasBodypart(bodypartSlot)):
		return false
	return getBodypart(bodypartSlot).hasWomb()

func getDefaultArtwork(_variant = []):
	return "res://Images/UI/GenericFace.png"

func hasIllegalItems():
	return getInventory().hasIllegalItems()

func personalityChangesAfterSex():
	return false

func getCharacterType():
	return CharacterType.Generic

func getBodypartLewdSizeAdjective(bodypartSlot):
	if(!hasBodypart(bodypartSlot)):
		return "ERROR:NO BODYPART IN SLOT " + str(bodypartSlot)
	return getBodypart(bodypartSlot).getLewdSizeAdjective()
	
func getBodypartLewdAdjective(bodypartSlot):
	if(!hasBodypart(bodypartSlot)):
		return "ERROR:NO BODYPART IN SLOT " + str(bodypartSlot)
	return getBodypart(bodypartSlot).getLewdAdjective()

func getBodypartLewdName(bodypartSlot):
	if(!hasBodypart(bodypartSlot)):
		return "ERROR:NO BODYPART IN SLOT " + str(bodypartSlot)
	return getBodypart(bodypartSlot).getLewdName()

func getBodypartLewdDescriptionAndName(bodypartSlot):
	if(!hasBodypart(bodypartSlot)):
		return "ERROR:NO BODYPART IN SLOT " + str(bodypartSlot)
	return getBodypart(bodypartSlot).getLewdDescriptionAndName()

func getBodypartLewdDescriptionAndNameWithA(bodypartSlot):
	if(!hasBodypart(bodypartSlot)):
		return "ERROR:NO BODYPART IN SLOT " + str(bodypartSlot)
	return getBodypart(bodypartSlot).getLewdDescriptionAndNameWithA()

func isDynamicCharacter():
	return false

func canWearBreastPump():
	if(getInventory().hasSlotEquipped(InventorySlot.UnderwearTop)):
		return false
	
	return true

func canWearStrapon():
	if(hasPenis() && !isWearingChastityCage()):
		return false
	
	if(getInventory().hasSlotEquipped(InventorySlot.Strapon)):
		return false
	
	return true

func hasStrapons():
	return getInventory().getItemsWithTag(ItemTag.Strapon).size() > 0

func hasChastityCages():
	return getInventory().getItemsWithTag(ItemTag.ChastityCage).size() > 0

func getStrapons():
	return getInventory().getItemsWithTag(ItemTag.Strapon)

func isWearingStrapon():
	return getWornStrapon() != null

func isWearingLoadedStrapon():
	var theStrapon = getWornStrapon()
	if(theStrapon == null):
		return false
	var fluids = theStrapon.getFluids()
	if(fluids == null):
		return false
	return !fluids.isEmpty()

func getWornStrapon():
	if(getInventory().hasSlotEquipped(InventorySlot.Strapon)):
		var item = getInventory().getEquippedItem(InventorySlot.Strapon)
		if(item.hasTag(ItemTag.Strapon)):
			return item
	return null

func getStraponContentsReadableString():
	var strapon = getWornStrapon()
	if(strapon == null):
		return "cum"
	var fluids = strapon.getFluids()
	if(fluids == null):
		return false
	return Util.humanReadableList(fluids.getFluidListNames())

func removeStrapon():
	var theStrapon = getWornStrapon()
	if(theStrapon == null):
		return null
	return getInventory().removeEquippedItem(theStrapon)

func unequipStrapon():
	var theStrapon = getWornStrapon()
	if(theStrapon == null):
		return null
	return getInventory().unequipItem(theStrapon)

func doPainfullyStretchHole(_bodypart, _who = "pc"):
	pass

func doWound(_who = "pc"):
	pass

func unequipAllRestraints():
	for item in inventory.getEquppedRestraints():
		if(item.isImportant()):
			continue
		
		inventory.unequipItem(item)

func removeAllRestraints():
	for item in inventory.getEquppedRestraints():
		if(item.isImportant()):
			continue
		
		inventory.removeEquippedItem(item)

func getFluids():
	return bodyFluids

func clearBodyFluids():
	bodyFluids.clear()
	
func coverBodyWithFluid(fluidType, amount, fluidDNA = null):
	bodyFluids.addFluid(fluidType, amount, fluidDNA)
	
func cummedOnBy(characterID, sourceType = null, howMuchPercent = 1.0):
	var resultAmount = 0.0
	
	var ch = GlobalRegistry.getCharacter(characterID)
	if(sourceType == null):
		if(ch.getGender() == Gender.Female):
			sourceType = FluidSource.Vagina
		else:
			sourceType = FluidSource.Penis
	
	if(sourceType == FluidSource.Penis && ch.hasBodypart(BodypartSlot.Penis)):
		var usedBodypart = ch.getBodypart(BodypartSlot.Penis)
		var fluids = usedBodypart.getFluids()
		
		if(fluids != null):
			resultAmount = fluids.transferTo(bodyFluids, howMuchPercent)
	else:
		resultAmount = ch.getFluidAmount(sourceType)*howMuchPercent
		coverBodyWithFluid(ch.getFluidType(sourceType), resultAmount, ch.getFluidDNA(sourceType))
	
	if(true):
		var event = SexEventHelper.create(SexEvent.ReceivedFluidsOnBody, characterID, getID(), {
			fluidSource = sourceType,
			loadSize = resultAmount,
		})
		ch.sendSexEvent(event)
		sendSexEvent(event)
	
func pissedOnBy(_characterID, howMuch = 1.0):
	cummedOnBy(_characterID, FluidSource.Pissing, howMuch)
	
	#addEffect(StatusEffect.DrenchedInPiss)

func getOutsideMessinessLevel():
	var fluidAmount = bodyFluids.getFluidAmount()
	if(fluidAmount <= 0.0):
		return 0
	elif(fluidAmount < 100.0):
		return 1
	elif(fluidAmount < 300.0):
		return 2
	elif(fluidAmount < 500.0):
		return 3
	elif(fluidAmount < 1000.0):
		return 4
	else:
		return 5

func isCoveredInFluids():
	if(bodyFluids.isEmpty()):
		return false
	return true

func afterTakingAShower():
	#addStamina(30)
	clearBodyFluids()
	clearBodywritings()
	clearTallymarks()

func isTooLewd(ignoreHeat = true):
	var theExposure = getExposure()
	if(ignoreHeat && hasEffect(StatusEffect.InHeat)):
		theExposure -= 50
	
	if(theExposure > 0):
		return true
	return false

func shouldCondomBreakWhenFucking(characterPenetrated, chance: float = 20.0, showMessages = true) -> bool:
	if(!OPTIONS.isContentEnabled(ContentType.RiskyCondoms)):
		return false
	
	var character
	if(characterPenetrated is String):
		character = GlobalRegistry.getCharacter(characterPenetrated)
	else:
		character = characterPenetrated
	
	if(character.hasPerk(Perk.FertilityDesireToBreed)):
		if(RNG.chance(chance)):
			character.addPain(-20)
			if(showMessages && character.isPlayer()):
				GM.main.addMessage("You didn't even sabotage that condom.. but it still feels good..")
			return true
		
		chance = clamp((chance * 3.0), 30, 95) #limits max chance to break to 95%
		if(RNG.chance(chance) && !character.hasBlockedHands()):
			character.addPain(-20)
			if(showMessages && character.isPlayer()):
				GM.main.addMessage("Your hands sneakily sabotage the condom.. feels good..")
			return true
		return false
	
	return RNG.chance(chance)

func getBaseSkinID():
	return pickedSkin

func getBaseSkinColors():
	return [pickedSkinRColor, pickedSkinGColor, pickedSkinBColor]

func getSkinData():
	var theColors = getBaseSkinColors()
	return {
		"skin": getBaseSkinID(),
		"r": theColors[0],
		"g": theColors[1],
		"b": theColors[2],
	}

func applyRandomColors():
	var species = getSpecies()
	if(species.size() > 0):
		var skinColors = GlobalRegistry.getSpecies(RNG.pick(species)).generateSkinColors()
		pickedSkinRColor = skinColors[0]
		pickedSkinGColor = skinColors[1]
		pickedSkinBColor = skinColors[2]

func applyRandomSkin():
	var species = getSpecies()
	var possibleSkins = []
	for speciesOne in species:
		var theSpecies = GlobalRegistry.getSpecies(speciesOne)
		var skinType = theSpecies.getSkinType()
		
		for skinID in GlobalRegistry.getSkins():
			var theSkin = GlobalRegistry.getSkin(skinID)
			var fittingSkinTypes = theSkin.getFittingSkinTypes()
			if(fittingSkinTypes is Dictionary && fittingSkinTypes.has(skinType)):
				possibleSkins.append([skinID, fittingSkinTypes[skinType]])
		
	var newSkin = RNG.pickWeightedPairs(possibleSkins)
	
	if(newSkin != null):
		pickedSkin = newSkin

func applyRandomSkinAndColors():
	applyRandomSkin()
	applyRandomColors()

func applyRandomSkinAndColorsAndParts():
	applyRandomSkinAndColors()
	
	for bodypartID in bodyparts:
		if(bodyparts[bodypartID] == null):
			continue
		bodyparts[bodypartID].generateRandomColors(self)
		bodyparts[bodypartID].generateRandomSkinIfCan(self)

func getStatusEffectImmunity(statusEffectID):
	return buffsHolder.getStatusEffectImmunity(statusEffectID)

func checkSkins(applyRandomSkinOnFail = false):
	var theSkin = GlobalRegistry.getSkin(pickedSkin)
	if(theSkin == null):
		if(applyRandomSkinOnFail):
			applyRandomSkin()
		else:
			pickedSkin = "EmptySkin"
	
	for bodypartSlot in bodyparts:
		if(!hasBodypart(bodypartSlot)):
			continue
		
		var bodypart = getBodypart(bodypartSlot)
		if(bodypart.pickedSkin == null):
			continue
		
		if(bodypart.hasCustomSkinPattern()):
			var thePartSkin = GlobalRegistry.getPartSkin(bodypart.id, bodypart.pickedSkin)
			if(thePartSkin == null):
				bodypart.pickedSkin = null
		else:
			theSkin = GlobalRegistry.getSkin(bodypart.pickedSkin)
			if(theSkin == null):
				bodypart.pickedSkin = null

func applyBodypartsSkinData(theSkinData):
	if(theSkinData != null):
		for bodypartSlot in theSkinData:
			if(!hasBodypart(bodypartSlot)):
				continue
			var bodypart = getBodypart(bodypartSlot)
			var bodypartSkinData = theSkinData[bodypartSlot]
			if(bodypartSkinData.has("skin")):
				bodypart.pickedSkin = bodypartSkinData["skin"]
			if(bodypartSkinData.has("r")):
				bodypart.pickedRColor = bodypartSkinData["r"]
			if(bodypartSkinData.has("g")):
				bodypart.pickedGColor = bodypartSkinData["g"]
			if(bodypartSkinData.has("b")):
				bodypart.pickedBColor = bodypartSkinData["b"]

func sendSexEvent(event):
	onSexEvent(event)

func onSexEvent(_event : SexEvent):
	if(_event == null):
		Log.error("GOT A NULL SEX EVENT")
		return
	print(getID()+" GOT SEX EVENT "+str(_event.type)+" SOURCE:"+str(_event.sourceCharID)+" TARGET:"+str(_event.targetCharID)+" "+str(_event.data))

	getSkillsHolder().onSexEvent(_event)
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.onSexEvent(_event)

func onFightStart(_contex = {}):
	beforeFightStarted() # Legacy
	
	getSkillsHolder().onFightStart(_contex)
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.onFightStart(_contex)

func processBattleTurnContex(_contex = {}):
	processBattleTurn() # Legacy
	
	getSkillsHolder().processBattleTurnContex(_contex)
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.processBattleTurnContex(_contex)

func onFightEnd(_contex = {}):
	afterFightEnded() # Legacy
	
	getSkillsHolder().onFightEnd(_contex)
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.onFightEnd(_contex)

func onSexStarted(_contex = {}):
	getSkillsHolder().onSexStarted(_contex)
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.onSexStarted(_contex)
	
func processSexTurnContex(_contex = {}):
	processSexTurn() # Legacy
	
	getSkillsHolder().processSexTurnContex(_contex)
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.processSexTurnContex(_contex)

func onSexEnded(_contex = {}):
	getSkillsHolder().onSexEnded(_contex)
	for effectID in statusEffects.keys():
		if(!statusEffects.has(effectID)):
			continue
		var effect = statusEffects[effectID]
		effect.onSexEnded(_contex)
	if(hasEnslaveQuest()):
		getEnslaveQuest().onSexEnded(_contex)
	if(isSlaveToPlayer()):
		getNpcSlavery().onSexEnded(_contex)
		
func getForcedObedienceLevel() -> float:
	return buffsHolder.getCustom(BuffAttribute.ForcedObedience)

func isWearingPortalPanties():
	if(getInventory().hasSlotEquipped(InventorySlot.UnderwearBottom)):
		var item = getInventory().getEquippedItem(InventorySlot.UnderwearBottom)
		if(item.hasTag(ItemTag.PortalPanties)):
			return true
	return false

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

func getUndressMessage(withS):
	var res = []
	var slotsToCheck = [InventorySlot.Body, InventorySlot.UnderwearTop, InventorySlot.UnderwearBottom]
	
	for slot in slotsToCheck:
		if(getInventory().hasSlotEquipped(slot)):
			var item = getInventory().getEquippedItem(slot)
			res.append(item.getTakingOffStringLong(withS))
	
	if(res.size() == 0):
		if(withS):
			return "takes all your clothes off"
		else:
			return "take all your clothes off"
	return Util.humanReadableList(res, "and also")

func isWearingInvisiblePortalPanties():
	return false

func getPortalSexHoleAvailable(_bodypartSlot):
	return false

func getWornHypnovisor():
	if(getInventory().hasSlotEquipped(InventorySlot.Eyes)):
		var item = getInventory().getEquippedItem(InventorySlot.Eyes)
		if(item.hasTag(ItemTag.Hypnovisor)):
			return item
	return null

func isWearingHypnovisor():
	return getWornHypnovisor() != null

func hasEnslaveQuest():
	return false

func getEnslaveQuest() -> NpcEnslavementQuest:
	return null

func isSlaveToPlayer():
	return false

func getNpcSlavery() -> NpcSlave:
	return null

func isFullyNaked():
	var slotsToBeFullyNaked = [InventorySlot.Body, InventorySlot.UnderwearBottom, InventorySlot.UnderwearTop]
	
	for slot in slotsToBeFullyNaked:
		if(inventory.hasSlotEquipped(slot)):
			return false
	
	return true

func getExposedPrivates():
	var possiblePrivates = [BodypartSlot.Breasts, BodypartSlot.Penis, BodypartSlot.Vagina, BodypartSlot.Anus]
	var result = []
	var coveredParts = {}
	
	var equippedItems = inventory.getAllEquippedItems()
	for inventorySlot in equippedItems:
		var item = equippedItems[inventorySlot]
		var itemCovers = item.coversBodyparts()
		for itemCover in itemCovers:
			coveredParts[itemCover] = true
	
	for possiblePrivatePart in possiblePrivates:
		if(!hasBodypart(possiblePrivatePart)):
			continue
		
		var bodypart = getBodypart(possiblePrivatePart)
		if(bodypart.safeWhenExposed()):
			continue
		
		if(!coveredParts.has(possiblePrivatePart) || !coveredParts[possiblePrivatePart]):
			result.append(possiblePrivatePart)
		
	return result

func isWearingAnyUnderwear():
	return inventory.hasSlotEquipped(InventorySlot.UnderwearBottom) || inventory.hasSlotEquipped(InventorySlot.UnderwearTop)

func isInventorySlotBlocked(invslot):
	var items = getInventory().getAllEquippedItems()
	for itemSlot in items:
		var item:ItemBase = items[itemSlot]
		var itemState = item.getItemState()
		if(itemState != null && (invslot in itemState.blocksInventorySlots())):
			return true
	return false
