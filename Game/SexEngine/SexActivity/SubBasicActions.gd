extends SexActivityBase

func _init():
	id = "SubBasicActions"
	startedByDom = false
	startedBySub = true

func getGoals():
	return {
	}

func getSupportedSexTypes():
	return {
		SexType.DefaultSex: true,
		SexType.StocksSex: true,
		SexType.SlutwallSex: true,
	}

func isStocksSex():
	return getSexEngine().getSexTypeID() == SexType.StocksSex

func getActivityBaseScore(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	return 0.0

func getStartActions(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var sub:BaseCharacter = _subInfo.getChar()
	#var dom:BaseCharacter = _domInfo.getChar()
	var actions = []
	
	if(!_sexEngine.hasTag(_subInfo.charID, SexActivityTag.PreventsSubTeasing) && !_sexEngine.hasTag(_subInfo.charID, SexActivityTag.MouthUsed)):
		actions.append({
			name = "Tease",
			desc = "Tease them",
			args = ["tease"],
			score = _subInfo.getComplyScore() * 0.1 + _subInfo.getResistScore() * 0.05 + max(0.0, _subInfo.personalityScore({PersonalityStat.Impatient: 0.1})),
			category = getCategory(),
			#chance = getApologySuccessChance(_domInfo, _subInfo),
		})
		
	var resistScore = _subInfo.getResistScore() * (0.15 + _subInfo.personalityScore({PersonalityStat.Subby: -0.1, PersonalityStat.Mean: 0.1, PersonalityStat.Coward: -0.05}))
		
	if(!_sexEngine.hasTag(_subInfo.charID, SexActivityTag.PreventsSubViolence)):
		if(getSexType() != SexType.SlutwallSex):
			if(!_subInfo.getChar().hasBoundArms() && !isStocksSex()):
				actions.append({
					name = "Punch",
					desc = "Hit them!",
					args = ["punch"],
					score = resistScore,
					category = getCategory(),
					#chance = getApologySuccessChance(_domInfo, _subInfo),
				})
			elif(!_subInfo.getChar().hasBoundLegs()):
				actions.append({
					name = "Kick",
					desc = "Hit them!",
					args = ["kick"],
					score = resistScore/1.5,
					category = getCategory(),
					#chance = getApologySuccessChance(_domInfo, _subInfo),
				})
	
	if(sub.getInventory().hasRemovableRestraints() && sub.getStamina() > 0):
		actions.append({
			name = "Restraints",
			desc = "Struggle against your restraints",
			args = ["struggle"],
			score = _subInfo.getResistScore() - _subInfo.getComplyScore()*_subInfo.fetishScore({Fetish.Bondage: 1.0}),
			category = getCategory(),
		})
	
	if(_domInfo.isAngry() && !_sexEngine.hasTag(_subInfo.charID, SexActivityTag.MouthUsed)):
		actions.append({
			name = "Apologize",
			desc = "Try to calm them down",
			args = ["apologize"],
			score = _subInfo.getAboutToPassOutScore() + _subInfo.personalityScore({PersonalityStat.Coward: 0.2, PersonalityStat.Brat: -0.1, PersonalityStat.Subby: 0.2}),
			category = getCategory(),
			chance = getApologySuccessChance(_domInfo, _subInfo),
		})
	
	return actions

func getVisibleName():
	return "Basic actions"

func getCategory():
	return []

func getDomTags():
	return []

func getSubTags():
	return []

func getApologySuccessChance(_domInfo, _subInfo):
	var theChance = 90.0 - _domInfo.personalityScore({PersonalityStat.Mean: 1.0}) * 20.0
	if(_subInfo.getChar().isGagged()):
		theChance *= 0.5
	if(getSexType() == SexType.SlutwallSex):
		theChance *= 0.6
	return clamp(theChance, 5, 100)

func startActivity(_args):
	state = ""
	var actionID = _args[0]
	
	if(actionID in ["struggle"]):
		endActivity()
		var sub = getSub()
		var possible = []
		var trivial = []
		
		for item in getSub().getInventory().getEquppedRestraints():
			var restraintData: RestraintData = item.getRestraintData()
			
			if(restraintData == null || !restraintData.canStruggle() || restraintData.isLocked()):
				continue
			
			if(!restraintData.shouldDoStruggleMinigame(sub)):
				trivial.append(item)
			else:
				possible.append(item)
		
		var pickedItem
		var minigameStatus
		if(trivial.size() > 0):
			pickedItem = RNG.pick(trivial)
			minigameStatus = 1.0
		elif(possible.size() > 0):
			pickedItem = RNG.pick(possible)
			minigameStatus = min(RNG.randf_range(0.6, 1.1), 1.0)
			if(subInfo.isScared()): # The subs fuck up more if scared
				minigameStatus = min(minigameStatus, min(1.0, RNG.randf_range(0.6, 1.1)))
		else:
			return
		
		var text = ""
		var restraintData: RestraintData = pickedItem.getRestraintData()
		var struggleData = restraintData.doStruggle(sub, minigameStatus).build()
		
		var struggleText = GM.ui.processString(struggleData["text"], {"user":subID})
		text += struggleText
		
		if(struggleData.has("damage")):
			var damage = struggleData["damage"] * minigameStatus
			restraintData.takeDamage(damage)
			text += ("\n{sub.You} made "+str(Util.roundF(damage*100.0, 1))+"% of progress, "+str(Util.roundF(max(0.0, restraintData.getTightness()*100.0), 1))+"% left.")
		if(struggleData.has("lust") && struggleData["lust"] > 0):
			subInfo.addLust(struggleData["lust"])
		if(struggleData.has("pain") && struggleData["pain"] > 0):
			subInfo.addPain(struggleData["pain"])
			subInfo.addFear(struggleData["pain"]/40.0)
		if(struggleData.has("stamina") && struggleData["stamina"] != 0):
			sub.addStamina(-struggleData["stamina"])
		
		if(restraintData.shouldBeRemoved()):
			text += "\n[b]"+restraintData.getRemoveMessage()+"[/b]"
			restraintData.onStruggleRemoval()
			sub.getInventory().removeEquippedItem(pickedItem)
		
		return {text=text, subSay=subReaction(SexReaction.ResistingRestraints, 30)}
	
	if(actionID in ["apologize"]):
		endActivity()
		var text = RNG.pick([
			"{sub.You} {sub.youVerb('try', 'tries')} to apologize.",
			"{sub.You} {sub.youVerb('attempt')} to apologize for {sub.yourHis} actions.",
		])
		if(!RNG.chance(getApologySuccessChance(domInfo, subInfo))):
			if(RNG.chance(30)):
				domInfo.addAnger(0.1)
				text += RNG.pick([
					" That only made {dom.youHim} more angry.",
					" That only made {dom.youHim} more eager for violence.",
				])
		else:
			domInfo.addAnger(-0.3)
		
		return {text = text, subSay=subReaction(SexReaction.Apologizing)}
	
	if(actionID in ["tease"]):
		endActivity()
		var possible = [
			"{sub.You} {sub.youVerb('tease')} {dom.youHim} with {sub.yourHis} body.",
		]
		if(isStocksSex()):
			possible = [
				"{sub.You} {sub.youVerb('tease')} {dom.youHim} with {sub.yourHis} body while still trapped in stocks.",
				"{sub.You} {sub.youVerb('wiggle')} {sub.yourHis} lower part of the body seductively.",
			]
		if(getSub().isGagged()):
			possible.append_array([
				"{sub.You} {sub.youVerb('mumble')} something incoherent {dom.youHim}.",
			])
		else:
			possible.append_array([
				"{sub.You} {sub.youVerb('smile')} "+RNG.pick(["seductively", "playfully", "teasingly"])+" at {dom.youHim}.",
				"{sub.You} {sub.youVerb('bite')} {sub.yourHis} lip "+RNG.pick(["seductively", "playfully", "teasingly"])+".",
			])
		if(getSub().bodypartHasTrait(BodypartSlot.Tail, PartTrait.TailFlexible)):
			possible.append_array([
				"{sub.You} {sub.youVerb('sway')} {sub.yourHis} tail seductively at {dom.youHim}.",
			])
		if(getSub().hasBigBreasts()):
			possible.append_array([
				"{sub.You} {sub.youVerb('bounce')} slightly, making {sub.yourHis} "+RNG.pick(["tits", "breasts"])+" jiggle.",
			])
		if(getSexType() == SexType.SlutwallSex):
			possible = [
				"{sub.You} {sub.youVerb('tease')} {dom.youHim} with {sub.yourHis} body while still trapped in the slutwall.",
				"{sub.You} {sub.youVerb('wiggle')} {sub.yourHis} lower part of the body seductively.",
			]
			if(getSub().bodypartHasTrait(BodypartSlot.Tail, PartTrait.TailFlexible)):
				possible.append_array([
					"{sub.You} {sub.youVerb('sway')} {sub.yourHis} tail seductively at {dom.youHim}.",
				])
			
		var text = RNG.pick(possible)
		
		affectDom(1.0, 0.2, 0.0)
		return {text=text,
		subSay=subReaction(SexReaction.Teasing)}
		
	if(actionID in ["punch", "kick"]):
		endActivity()
		var text
		if(actionID == "punch"):
			text = RNG.pick([
				"{sub.You} {sub.youVerb('punch', 'punches')} {dom.youHim}!",
			])
		else:
			text = RNG.pick([
				"{sub.You} {sub.youVerb('kick')} {dom.youHim}!",
			])
		domInfo.addAnger(0.2 + 0.1 * domInfo.fetishScore({Fetish.Masochism: -1.0}))
		var howMuchPainAdded = RNG.randi_range(4, 6)
		domInfo.addPain(howMuchPainAdded)
		sendSexEvent(SexEvent.PainInflicted, subID, domID, {pain=howMuchPainAdded,isDefense=true,intentional=true})
		
		return {text=text, subSay=subReaction(SexReaction.ActivelyResisting, 50)}
