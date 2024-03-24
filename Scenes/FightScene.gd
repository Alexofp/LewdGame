extends SceneBase

var enemyID: String = ""
var enemyCharacter: BaseCharacter

var whatPlayerDid: String = ""
var whatEnemyDid: String = ""
var whatHappened: String = ""
var battleState = ""
var battleEndedHow = ""
var savedAIAttackID = ""
var battleName = ""
var currentAttackerID = ""
var currentReceiverID = ""
var enemyAIStrategy: AIStrategyBase
var restraintIdsForcedByPC = []
var enemySurrendered = false
var lastPlayerAttackData = null
var restraintsPickedCategory = ""

func _init():
	sceneID = "FightScene"
	showFightUI = true

func _initScene(_args = []):
	enemyID = _args[0]
	enemyCharacter = GlobalRegistry.getCharacter(enemyID)
	addCharacter(enemyID)
	
	if(_args.size() > 1):
		battleName = _args[1]
		
	enemyAIStrategy = enemyCharacter.getAiStrategy(battleName)
	enemyAIStrategy.battleName = battleName
	enemyAIStrategy.onBattleStart(GM.pc)
	
	enemyCharacter.onFightStart(getContexForEnemy())
	GM.pc.onFightStart(getContexForPC())
	if(GM.pc.getLustCombatState() != null):
		GM.pc.getLustCombatState().setEnemyID(enemyID)

func _run():
	if(state == ""):
		saynn(enemyCharacter.getFightIntro(battleName))
		#setState("fighting")
	elif(state == "fighting"):
		#say("And so the fight continues")
		pass
		
	if(state == "lost" || state == "win"):		
		saynn("The fight has ended")
	
	if(state == "physattacks"):
		saynn("Pick the attack to use")
		
		addAttackButtons(Attack.Category.Physical)
		
		addButton("Back", "Back to fighting", "return")
	
	if(state == "lustattacks"):
		saynn("Pick how you wanna tease the enemy")
		
		var enemyLustInterests = enemyCharacter.getLustInterests()
		if(!enemyLustInterests.hasAnyInterests()):
			sayn("You have a feeling that teasing won't have any effect on "+enemyCharacter.getName())
		else:
			var whatPlayerKnows = enemyLustInterests.getPlayerKnowledge()
			
			sayn("What you learned about "+enemyCharacter.getName()+"'s likes/dislikes:")
			if(whatPlayerKnows.size() > 0):
				for topicID in whatPlayerKnows:
					var topic = GlobalRegistry.getLustTopic(topicID)
					sayn("- "+enemyCharacter.getName() + " [color="+Interest.getColorString(whatPlayerKnows[topicID])+"]" + Interest.getVisibleName(whatPlayerKnows[topicID])+"[/color] seeing "+str(topic.getVisibleName(topicID)))
			else:
				sayn("- Nothing yet")
		
		var lustCombatState:LustCombatState = GM.pc.getLustCombatState()
		addLustActionsButtons(lustCombatState, lustCombatState.getActionsSorted())
		
		setPlayerAsAttacker()
		sayn("")
		for activity in lustCombatState.getAllText():
			sayn(activity)
		#addAttackButtons(Attack.Category.Lust)
		
		addButton("Back", "Back to fighting", "return")
	
	if(state == "specialattacks"):
		saynn("Pick the attack to use")
		
		addAttackButtons(Attack.Category.Special)
		
		addButton("Back", "Back to fighting", "return")
	
	if(state == "inventory"):
		saynn("Pick the item to use")
	
		var playerInventory = GM.pc.getInventory()
		var usableItems = playerInventory.getAllCombatUsableItems()
		
		for item in usableItems:
			var intoxic = item.addsIntoxicationToPC()
			
			if(intoxic <= 0 || GM.pc.canIntoxicateMore(intoxic)):
				addButton(item.getVisibleName(), item.getCombatDescription(), "useitem", [item])
			else:
				addDisabledButton(item.getVisibleName(), "[color=red]Too intoxicated to use this[/color]\n"+item.getCombatDescription())
	
		addButton("Back", "Back to fighting", "return")
	
	if(state == "bdsm_attacks"):
		saynn("Pick what restraint you wanna force onto your enemy")
		
		if(!GM.pc.isBlindfolded() || GM.pc.canHandleBlindness()):
			for item in enemyCharacter.getInventory().getEquppedRestraints():
				var restraintData: RestraintData = item.getRestraintData()
				
				sayn(item.getVisibleName()+", restraint level: "+restraintData.getVisibleLevel(false))
				#sayn("- Durability: "+restraintData.getVisibleDurability())
				saynn("- Tightness: "+restraintData.getVisibleTightness()+" ("+restraintData.getTightnessPercentString()+")")

		else:
			saynn("You can't judge enemy's restraints while blind")
		
		var isInCategory = (restraintsPickedCategory != "")
		var usableItems
		var dupe = []
		if(enemyCharacter.isDynamicCharacter()):
			usableItems = GM.pc.getInventory().getAllCombatUsableRestraints()
		else:
			usableItems = GM.pc.getInventory().getAllCombatUsableRestraintsForStaticNpc()
		var countsByItemID = {}
		if(isInCategory):
			var newUsable = []
			for item in usableItems:
				if(item.id == restraintsPickedCategory):
					if !item.getRestraintData().getLevel() in dupe:
						newUsable.append(item)
					dupe.append(item.getRestraintData().getLevel())
			usableItems = newUsable
		else:
			for item in usableItems:
				if(!countsByItemID.has(item.id)):
					countsByItemID[item.id] = 1
					dupe.append(item.getRestraintData().getLevel())
				else:
					countsByItemID[item.id] += 1
		
			for categoryID in countsByItemID:
				if(countsByItemID[categoryID] <= 1):
					continue
				var itemRef:ItemBase = GlobalRegistry.getItemRef(categoryID)
				if(itemRef == null):
					continue
				
				addButton(str(countsByItemID[categoryID])+"x"+itemRef.getVisibleName(), itemRef.getCombatDescription(), "openrestraintscategory", [categoryID])
				
		for item in usableItems:
			if(!isInCategory && countsByItemID.has(item.id) && countsByItemID[item.id] > 1):
				continue
			
			var itemSlot = item.getClothingSlot()
			
			if(!enemyCharacter.invCanEquipSlot(itemSlot)):
				addDisabledButton(item.getVisibleName(), "Unable to force this restraint on them")
			elif(enemyCharacter.getInventory().hasSlotEquipped(itemSlot) && enemyCharacter.getInventory().getEquippedItem(itemSlot).isRestraint()):
				addDisabledButton(item.getVisibleName(), "They are wearing this type of restraint already")
			else:
				var restraintData:RestraintData = item.getRestraintData()
				if(restraintData == null):
					continue
				var pcAccuracy = GM.pc.getRestraintForcingSuccessChanceMod()
					
				var chanceToForce = pcAccuracy
				if(enemyCharacter.getStamina() > 0):
					 chanceToForce *= restraintData.getFinalChanceToForceARestraint(enemyCharacter)

				addButton(item.getVisibleName(), "Available: " + str(dupe.count(restraintData.getLevel())) + "\n" + "Restraint level: "+str(restraintData.getLevel()) + "\n" + "Success chance: "+ str(Util.roundF(chanceToForce*100.0, 1))+"%" + "\n\n" + item.getCombatDescription(), "forcerestraint", [item])
			
		addButton("Back", "Back to fighting", "closerestraintsmenu")
	
	if(state == "playerMustDodge"):
		if(whatPlayerDid != ""):
			saynn(whatPlayerDid)
			
		if(whatHappened != ""):
			saynn(whatHappened)
	
	if(state == "" || state == "fighting" || state == "lost" || state == "win"):	
		if(whatPlayerDid != ""):
			saynn(whatPlayerDid)
			
		if(whatEnemyDid != ""):
			saynn(whatEnemyDid)
			
		if(whatHappened != ""):
			saynn(whatHappened)
			
	if(state == "fighting"):
		saynn(enemyCharacter.getFightState(battleName))
		
		saynn(GM.pc.getFightState(battleName))
		
		var lustCombatState:LustCombatState = GM.pc.getLustCombatState()
		for activity in lustCombatState.getAllText():
			sayn(activity)
			
	if(state == "playerMustDodge"):
		var attack: Attack = GlobalRegistry.getAttack(savedAIAttackID)
		
		setEnemyAsAttacker()
		if(GM.pc.isBlindfolded() && !GM.pc.canHandleBlindness() && !attack.canSeeAnticipationTextWhenBlind()):
			saynn(GM.ui.processString(attack.canBlindAnticipationText(enemyCharacter, GM.pc)))
		else:
			saynn(GM.ui.processString(attack.getAnticipationText(enemyCharacter, GM.pc)))
		addButton("Do nothing", "You don't counter the attack in any way", "dodge_donothing")
		addButtonWithChecks("Dodge", "You dodge a physical attack completely spending 30 stamina in the process", "dodge_dodge", [], [ButtonChecks.HasStamina, ButtonChecks.NotCollapsed])
		addButtonWithChecks("Block", "You gain "+str(GM.pc.getBlockArmor())+" additional physical armor against the attack while spending 15 stamina", "dodge_block", [], [ButtonChecks.HasStamina])
		addButtonWithChecks("Defocus", "You try to distract yourself from the fight, gaining "+str(GM.pc.getDefocusArmor())+" lust armor and spending 15 stamina", "dodge_defocus", [], [ButtonChecks.HasStamina])
		if(GM.pc.hasPerk(Perk.CombatDoubleDown)):
			if(lastPlayerAttackData != null):
				var pcAttack:Attack = GlobalRegistry.getAttack(lastPlayerAttackData["attackID"])
				
				if(pcAttack.canUse(GM.pc, enemyCharacter, lastPlayerAttackData)):
					addButtonWithChecks("Double down", "Spend 10 stamina to do the same attack that you did a second time before the enemy attacks you", "dodge_doubledown", [], [ButtonChecks.HasStamina])
				else:
					addDisabledButton("Double down", "You can't double down on this attack")
			else:
				addDisabledButton("Double down", "You can only double down on a basic physical attack")
				
	if(state == "" || state == "fighting"):		
		addButtonWithChecks("Physical Attack", "Show a list of physical attacks that you can do", "physattacks", [], [ButtonChecks.NotStunned])
		addButtonWithChecks("Lust Attack", "Show a list of lewd actions that you can do", "lustattacks", [], [ButtonChecks.NotStunned])
		
		if(pcHasAnyAttacksOfCategory(Attack.Category.Special)):
			addButtonWithChecks("Special", "Show a list of your special moves", "specialattacks", [], [ButtonChecks.NotStunned])
		else:
			addDisabledButton("Special", "You don't know any special moves")
		
		#addButton("Inspect", "Look closer", "inspect")
		if(GM.pc.getInventory().hasRemovableRestraints()):
			addButtonWithChecks("Struggle", "Struggle against your restraints", "struggle", [], [ButtonChecks.NotStunned])
		else:
			addDisabledButton("Struggle", "You don't have any restraints that you can struggle out of")
		addButton("Wait", "Do nothing", "wait")
		
		#if(GM.pc.getInventory().getAllCombatUsableItems().size() > 0):
		#	addButton("Inventory", "Use an item fron your inventory", "inventory")
		#else:
		#	addDisabledButton("Inventory", "You don't have anything you can use in combat")
		addButton("Inventory", "Look at your inventory", "openinventory")
		
		if(GM.pc.hasEffect(StatusEffect.Collapsed)):
			if(GM.pc.canStandUpCombat()):
				addButtonWithChecks("Get up", "spends the whole turn", "getup", [], [ButtonChecks.NotStunned])
			else:
				addDisabledButton("Get up", "You can't stand up now")
		else:
			addDisabledButton("Get up", "You're already standing")
		
		if(GM.pc.hasPerk(Perk.BDSMRigger)):
			addButtonWithChecks("Bondage", "Pick which restraint you wanna try to force onto your enemy", "bdsm_attacks", [], [ButtonChecks.NotHandsBlocked, ButtonChecks.NotArmsRestrained])
		
		addButtonAt(14, "Submit", "Give up", "submit")
		
	if(state == "lost" || state == "win"):
		if(enemyCharacter.isDynamicCharacter() && restraintIdsForcedByPC.size() > 0 && state == "win"):
			addButton("Recover restraints", "the battle has ended", "endbattle", [true])
			addButton("Keep restraints", "the battle has ended", "endbattle", [false])
		else:
			addButton("Continue", "the battle has ended", "endbattle", [true])
		
	if(state == "lustCombatAboutToCum"):
		saynn(whatPlayerDid)
		
		saynn("You're about to cum..")
		
		var lustCombatState:LustCombatState = GM.pc.getLustCombatState()
		addLustActionsButtons(lustCombatState, lustCombatState.getOrgasmActionsSorted())
		
	if(state == "lustCombatAfterCame"):
		saynn(whatPlayerDid)
		
		addButton("Continue", "You're not done yet", "")
		addButton("Stop", "That's enough for now..", "endthescene")

func _react(_action: String, _args):
	if(_action == "struggle"):
		runScene("StrugglingScene", [true], "struggle_scene")
		return
		
	if(_action == "openinventory"):
		runScene("InventoryScene", [true], "inventory_scene")
		return
		
	if(_action == "physattacks" || _action == "lustattacks" || _action == "specialattacks" || _action == "selfhumattacks" || _action == "humattacks" || _action == "inventory"):
		setState(_action)
		return
		
	if(_action == "return"):
		setState("fighting")
		return
	
	if(_action == "doattack"):
		setState("fighting")
		beforeTurnChecks()
		
		var attackData = _args[0]
		whatPlayerDid += doPlayerAttack(attackData)
		whatEnemyDid += aiTurn()

		afterTurnChecks()
		return
		
	if(_action == "useitem"): # UNUSED
		setState("fighting")
		beforeTurnChecks()
		
		setPlayerAsAttacker()
		var item = _args[0]
		whatPlayerDid += GM.ui.processString(item.useInCombatWithBuffs(GM.pc, enemyCharacter))
		whatEnemyDid += aiTurn()

		afterTurnChecks()
		return
		
	if(_action == "openrestraintscategory"):
		restraintsPickedCategory = _args[0]
		return
	
	if(_action == "closerestraintsmenu"):
		if(restraintsPickedCategory != ""):
			restraintsPickedCategory = ""
		else:
			setState("fighting")
		return
		
	if(_action == "forcerestraint"):
		restraintsPickedCategory = ""
		setState("fighting")
		beforeTurnChecks()
		
		setPlayerAsAttacker()
		
		var accuracy = GM.pc.getRestraintForcingSuccessChanceMod()
		if(!RNG.chance(accuracy * 100.0)):
			whatPlayerDid += "You tried to force a restraint onto your enemy but you missed!"
		else:
			var item:ItemBase = _args[0]
			var restraintData:RestraintData = item.getRestraintData()
			var finalSuccessChance = restraintData.getFinalChanceToForceARestraint(enemyCharacter)
			
			if(!RNG.chance(finalSuccessChance * 100.0) && enemyCharacter.getStamina() > 0):
				enemyCharacter.addStamina(-10)
				whatPlayerDid += GM.ui.processString("You try to force a restraint onto {receiver.name} but {receiver.he} avoided your attempt!")
			
				playAnimation(StageScene.Duo, "", {npc=enemyID, npcAction="dodge"})
			else:
				GM.pc.addSkillExperience(Skill.BDSM, restraintData.getLevel() * 3)
				whatPlayerDid += GM.ui.processString(item.getForcedOnMessage(false))
				
				restraintIdsForcedByPC.append(item.getUniqueID())
				GM.pc.getInventory().removeItem(item)
				enemyCharacter.getInventory().forceEquipByRemoveOther(item, GM.pc)
				enemyCharacter.getBuffsHolder().calculateBuffs()
				#enemyCharacter.updateNonBattleEffects()

				if restraintData.canBeLocked() && RNG.chance(20): 
					restraintData.lockIt()
				
				var restraintsAmount = enemyCharacter.getInventory().getEquppedRestraints().size()
				if(enemyCharacter.shouldReactToRestraint(restraintData.getRestraintType(), restraintsAmount, true)):
					var reaction = enemyCharacter.reactRestraint(restraintData.getRestraintType(), restraintsAmount, true)
					if(reaction != null && reaction != ""):
						whatPlayerDid += "\n" + "[say="+str(enemyID)+"]"+str(reaction)+"[/say]"
		
		whatEnemyDid += aiTurn()

		afterTurnChecks()
		return
	
	if(_action == "getup"):
		beforeTurnChecks()
		
		whatPlayerDid += doPlayerAttack({"attackID": "trygetupattack"})
		
		whatEnemyDid += aiTurn()

		afterTurnChecks()
		return

	if(_action == "wait"):
		beforeTurnChecks()
		
		whatPlayerDid = "You decide to wait for a good moment to attack"
		
		whatEnemyDid += aiTurn()
		
		afterTurnChecks()
		return
		
	if(_action == "dodge_donothing" || _action == "dodge_dodge" || _action == "dodge_block" || _action == "dodge_defocus" || _action == "dodge_doubledown"):
		setState("fighting")
		whatHappened = ""
		if(_action == "dodge_donothing"):
			whatPlayerDid = "You decide to let the attack happen"
		if(_action == "dodge_dodge"):
			whatPlayerDid = "You focus on enemy's next attack and try to dodge it"
			GM.pc.setFightingStateDodging()
			GM.pc.addStamina(-30)
		if(_action == "dodge_block"):
			whatPlayerDid = "You try to block the next attack"
			GM.pc.setFightingStateBlocking()
			GM.pc.addStamina(-15)
		if(_action == "dodge_defocus"):
			whatPlayerDid = "You try to get distracted"
			GM.pc.setFightingStateDefocusing()
			GM.pc.addStamina(-15)
		if(_action == "dodge_doubledown"):
			whatPlayerDid = doPlayerAttack(lastPlayerAttackData)
			GM.pc.addStamina(-10)
		
			var won = checkEnd()
			if(won == "lost"):
				setState("lost")
				return
			if(won == "win"):
				setState("win")
				return
		
		var attack: Attack = GlobalRegistry.getAttack(savedAIAttackID)
		if(attack == null):
			assert(false, "Bad attack: "+savedAIAttackID)
			
		setEnemyAsAttacker()
		
		var result = attack.doAttack(enemyCharacter, GM.pc)
		result["text"] = GM.ui.processString(result["text"])
		
		playAnimation(StageScene.Duo, result["receiverAnimation"], {npc=enemyID, npcAction=result["attackerAnimation"]})
		
		whatEnemyDid += result["text"]
		savedAIAttackID = ""
		
		GM.pc.setFightingStateNormal()
		
		afterTurnChecks()
		return
	
	if(_action == "submit"):
		setState("lost")
		whatHappened = "You give up the fight willingly and submit to your enemy\n"
		battleState = "lost"
		playAnimation(StageScene.Solo, "kneel")
		return
	
	if(_action == "endbattle"):
		if(restraintIdsForcedByPC.size() > 0 && _args.size() > 0 && _args[0]):
			#var recoverChance = GM.pc.getBuffsHolder().getCustom(BuffAttribute.RestraintRecovery) * 100.0
			
			for itemUniqueID in restraintIdsForcedByPC:
				var item:ItemBase = enemyCharacter.getInventory().getItemByUniqueID(itemUniqueID)
				
				if(item == null):
					continue
				
				if(true):#if(RNG.chance(recoverChance)):
					enemyCharacter.getInventory().removeItem(item)
					enemyCharacter.getInventory().removeEquippedItem(item)
					var restraintData:RestraintData = item.getRestraintData()
					if(restraintData != null):
						restraintData.onStruggleRemoval()
					
					GM.pc.getInventory().addItem(item)
					addMessage("You recovered "+item.getAStackName())
				else:
					addMessage("You lost "+item.getAStackName())
			if(!enemyCharacter.isDynamicCharacter()):
				enemyCharacter.resetEquipment()
		
		enemyCharacter.onFightEnd(getContexForEnemy())
		GM.pc.onFightEnd(getContexForPC())
		if(battleEndedHow == ""):
			battleEndedHow = "pain"
		if(battleState == "win"):
			var loot = enemyCharacter.getLoot(battleName)
			if((loot.has("credits") && loot["credits"] > 0) || (loot.has("items") && loot["items"].size() > 0)):
				runScene("LootingScene", [loot], "lootingscene")
			else:
				endScene([battleState, battleEndedHow])
		else:
			endScene([battleState, battleEndedHow])
		return
	
	if(_action == "doLustAction"):
		setState("fighting")
		var actionData = _args[0]
		if(!(actionData["id"] in GlobalRegistry.getOrgasmLustActions())):
			beforeTurnChecks()
		setPlayerAsAttacker()
		
		var lustCombatState:LustCombatState = GM.pc.getLustCombatState()
		
		var result = lustCombatState.doAction(actionData)
		whatPlayerDid = GM.ui.processString(result["text"]).trim_suffix("\n\n")
		if("lust" in result):
			GM.pc.addLust(result["lust"])
			if(GM.pc.getLustLevel() >= 1.0 && ("cantCum" in result) && result["cantCum"]):
				GM.pc.addLust(-1)
		if("pain" in result):
			GM.pc.addPain(result["pain"])
		
		if("lustInterests" in result):
			var actionLustInterests = result["lustInterests"]
			var isTease = false
			if("isTease" in result):
				isTease = true
			
			var maxUnlocks = 1
			if(GM.pc.hasPerk(Perk.SexBetterTease)):
				maxUnlocks = 2
			
			var lustInterests: LustInterests = enemyCharacter.getLustInterests()
			var teaseData = lustInterests.reactLustAction(GM.pc, actionLustInterests, maxUnlocks)
			#var damageMult = teaseData["value"]
			var positiveDamage = teaseData["positiveValue"]
			var negativeDamage = teaseData["negativeValue"]
			var learned = teaseData["learned"]
			#var alreadyKnownTopics = teaseData["alreadyKnownTopics"]
			
			var pcDamageMult = GM.pc.getDamageMultiplier(DamageType.Lust) + 1.0
			var damageBalanceMod = negativeDamage/pcDamageMult + positiveDamage*pcDamageMult
			if(damageBalanceMod > 0.0):
				damageBalanceMod = pow(damageBalanceMod, 0.7)
			if(damageBalanceMod < 0.0):
				damageBalanceMod = -pow(abs(damageBalanceMod), 0.7)
			var theDamage = damageBalanceMod*10.0*RNG.randf_range(0.9, 1.1)
			
			var extraText = ""
			if(isTease && enemyCharacter.getLustLevel() < 0.6 && theDamage > 0.0):
				theDamage *= 1.5
			if(isTease && enemyCharacter.getLustLevel() >= 0.6):
				theDamage *= 1.0
				extraText = "[b]Teasing is less effective when the enemy is horny![/b] "
			
			var damage = enemyCharacter.receiveDamage(DamageType.Lust, int(round(theDamage)))
			
			whatPlayerDid += "\n\n"
			whatPlayerDid += enemyCharacter.lustDamageReaction(damage, GM.pc)
			whatPlayerDid += "\n"
			whatPlayerDid += extraText + enemyCharacter.getName()+" received [color="+DamageType.getColorString(DamageType.Lust)+"]"+str(damage)+" "+DamageType.getBattleName(DamageType.Lust)+"[/color]"
			
			if(learned.size() > 0):
				var npcReaction = enemyCharacter.interestVerbalReaction(learned[0][0])
				if(npcReaction != null && npcReaction != ""):
					whatPlayerDid += "\n\n"+"[say="+enemyCharacter.getID()+"]" +str(npcReaction)+"[/say]"
				
				whatPlayerDid += "\n[i]You learned more about what "+enemyCharacter.getName()+" likes[/i]"
		
		#processTime(30)
		
		#if("came" in result):
		#	setState("lustCombatAfterCame")
		#	afterTurnChecks()
		#	return
		
		if("lostBattle" in result):
			GM.pc.addLust(GM.pc.lustThreshold())
			afterTurnChecks()
			return
			
		if(GM.pc.getLustLevel() >= 1.0):
			setState("lustCombatAboutToCum")
			#afterTurnChecks()
			return
			
		whatEnemyDid += aiTurn()
			
		afterTurnChecks()
		return
	
	setState(_action)

func addLustActionsButtons(lustCombatState:LustCombatState, theActions):
	for actionData in theActions:
		var lustAction:LustAction = GlobalRegistry.getLustAction(actionData["id"])
		
		if(!lustAction.shouldShow(lustCombatState, actionData)):
			continue
		var canDo = lustAction.canDo(lustCombatState, actionData)
		var reasonWhyCant = "You can't do this right now"
		if(canDo is Array):
			if(canDo.size() > 1):
				reasonWhyCant = canDo[1]
			canDo = canDo[0]
		
		if(canDo):
			addButton(lustAction.getVisibleName(lustCombatState, actionData), lustAction.getVisibleDescription(lustCombatState, actionData), "doLustAction", [actionData])
		else:
			addDisabledButton(lustAction.getVisibleName(lustCombatState, actionData), reasonWhyCant)
	

func doPlayerAttack(attackData):
	lastPlayerAttackData = attackData
	var attackID = attackData["attackID"]
	
	var attack: Attack = GlobalRegistry.getAttack(attackID)
	if(attack == null):
		assert(false, "Bad attack: "+attackID)
	
	setPlayerAsAttacker()
	
	var result = attack.doAttack(GM.pc, enemyCharacter, attackData)
	result["text"] = GM.ui.processString(result["text"])
	
	playAnimation(StageScene.Duo, result["attackerAnimation"], {npc=enemyID, npcAction=result["receiverAnimation"]})
	
	var expData = attack.getExperience()
	for expAdd in expData:
		GM.pc.addSkillExperience(expAdd[0], expAdd[1])
	
	return result["text"]
	
func aiTurn():
	if(enemyCharacter.getPain() >= enemyCharacter.painThreshold() || enemyCharacter.getLust() >= enemyCharacter.lustThreshold()):
		return ""
	
	setEnemyAsAttacker()
	var enemyText = "It's "+enemyCharacter.getName()+"'s turn\n"
	if(enemyAIStrategy != null):
		var strategyText = enemyAIStrategy.turnPassed(GM.pc)
		if(strategyText != null && strategyText != ""):
			enemyText += GM.ui.processString(strategyText) + "\n\n"
	
	var actionData = enemyAIStrategy.getNextActionFinal(GM.pc)
	var actionType = actionData["action"]
	
	if(actionType == "struggle"):
		var item:ItemBase = actionData["item"]
		var restraintData = item.getRestraintData()
		
		var minigameStatus = 1.0
		if(restraintData.shouldDoStruggleMinigame(enemyCharacter)):
			minigameStatus = clamp(enemyCharacter.getRestraintStrugglingMinigameResult(), 0.0, 1.0) * 2.0 * enemyCharacter.getRestraintStrugglePower()
		
		var animToPlay = restraintData.getResistAnimation()
		if(animToPlay != null && animToPlay != ""):
			playAnimation(StageScene.Duo, "", {npc=enemyID, npcAction=animToPlay})
		
		var damage = 0.0
		var addLust = 0
		var addPain = 0
		var addStamina = 0
		
		var struggleData = restraintData.doStruggle(enemyCharacter, minigameStatus).build()
		if(struggleData.has("damage")):
			damage = struggleData["damage"] * minigameStatus
		if(struggleData.has("lust") && struggleData["lust"] > 0):
			addLust = struggleData["lust"]
		if(struggleData.has("pain") && struggleData["pain"] > 0):
			addPain = struggleData["pain"]
		if(struggleData.has("stamina") && struggleData["stamina"] != 0):
			addStamina = struggleData["stamina"]
		
		var struggleText = GM.ui.processString(struggleData["text"], {"user":"attacker"})
		enemyText += struggleText + "\n\n"
		
		if(damage != 0.0):
			restraintData.takeDamage(damage)
			enemyText += ("{attacker.name} made "+str(Util.roundF(damage*100.0, 1))+"% of progress\n")
		if(addLust != 0):
			addLust = enemyCharacter.receiveDamage(DamageType.Lust, addLust)
			enemyText += ("{attacker.name} received "+str(addLust)+" lust\n")
		if(addPain != 0):
			addPain = enemyCharacter.receiveDamage(DamageType.Physical, addPain)
			enemyText += ("{attacker.name} received "+str(addPain)+" pain\n")
		if(addStamina != 0):
			enemyCharacter.addStamina(-addStamina)
			
			if(addStamina < 0):
				enemyText += ("{attacker.name} gained "+str(-addStamina)+" stamina\n")
			else:
				enemyText += ("{attacker.name} used "+str(addStamina)+" stamina\n")
		
		if(restraintData.shouldBeRemoved()):
			enemyText += "[b]"+restraintData.getRemoveMessage()+"[/b]\n"
			restraintData.onStruggleRemoval()
			enemyCharacter.getInventory().removeEquippedItem(item)
			
			var recoverChance = GM.pc.getBuffsHolder().getCustom(BuffAttribute.RestraintRecovery) * 100.0
			if(!restraintData.alwaysBreaksWhenStruggledOutOf() && RNG.chance(recoverChance)):
				GM.pc.getInventory().addItem(item)
				addMessage("You recovered "+item.getAStackName())
			#elif(recoverChance > 0):
			#	addMessage("You lost "+item.getAStackName())
			
		var restraintsAmount = enemyCharacter.getInventory().getEquppedRestraints().size()
		if(enemyCharacter.shouldReactToRestraint(restraintData.getRestraintType(), restraintsAmount, false)):
			var reaction = enemyCharacter.reactRestraint(restraintData.getRestraintType(), restraintsAmount, false)
			if(reaction != null && reaction != ""):
				enemyText += "[say="+str(enemyID)+"]"+str(reaction)+"[/say]"

		enemyText = enemyText.rstrip("\n")
		
	elif(actionType == "attack"):
	
		var attackID: String = actionData["attackID"]
		var attack: Attack = GlobalRegistry.getAttack(attackID)

		if(attack == null):
			Log.printerr("Bad attack "+str(attackID))
			attackID = "blunderAttack"
			attack = GlobalRegistry.getAttack(attackID)
			
		if(!attack.canBeDodgedByPlayer(enemyCharacter, GM.pc)):	
			
			var result = attack.doAttack(enemyCharacter, GM.pc)
			result["text"] = GM.ui.processString(result["text"])
				
			playAnimation(StageScene.Duo, result["receiverAnimation"], {npc=enemyID, npcAction=result["attackerAnimation"]})
			
			enemyText += result["text"]
		else:
			savedAIAttackID = attackID
			setState("playerMustDodge")
	elif(actionType == "wait"):
		enemyText += "{attacker.name} decided to wait"
	elif(actionType == "stunned"):
		enemyText += "{attacker.name} couldn't do anything because {attacker.he} was stunned"
	elif(actionType == "surrender"):
		if(actionData.has("reason")):
			enemyText += "{attacker.name} surrendered. Reason: "+str(actionData["reason"])
		else:
			enemyText += "{attacker.name} surrendered"
		enemySurrendered = true
	else:
		enemyText += "{attacker.name} couldn't decide what to do"
	
	return enemyText

func getContexForPC():
	return {
		"whoID": "pc",
		"enemyID": enemyID,
	}
	
func getContexForEnemy():
	return {
		"whoID": enemyID,
		"enemyID": "pc",
	}

func beforeTurnChecks(pcWasStruggling = false):
	whatPlayerDid = ""
	whatEnemyDid = ""
	whatHappened = ""
	lastPlayerAttackData = null
	
	GM.pc.processBattleTurnContex(getContexForPC())
	enemyCharacter.processBattleTurnContex(getContexForEnemy())
	
	if(true):
		var turnData = GM.pc.processStruggleTurn(pcWasStruggling)
		var addLust = turnData["lust"]
		var addPain = turnData["pain"]
		var addStamina = turnData["stamina"]
		var additionalStruggleText = turnData["text"]
		
		if(addLust != 0):
			addLust = GM.pc.receiveDamage(DamageType.Lust, addLust)
			addMessage("You received "+str(addLust)+" lust")
		if(addPain != 0):
			addPain = GM.pc.receiveDamage(DamageType.Physical, addPain)
			addMessage("You received "+str(addPain)+" pain")
		if(addStamina != 0):
			GM.pc.addStamina(-addStamina)
			if(addStamina < 0):
				addMessage("You gained "+str(-addStamina)+" stamina")
			else:
				addMessage("You used "+str(addStamina)+" stamina")
		
		if(additionalStruggleText != null && additionalStruggleText != ""):
			whatHappened += "[i]"+GM.ui.processString(additionalStruggleText, {"user":"pc"})+"[/i]\n"
	
	if(true):
		var turnData = enemyCharacter.processStruggleTurn(true)
		var addLust = turnData["lust"]
		var addPain = turnData["pain"]
		var addStamina = turnData["stamina"]
		var additionalStruggleText = turnData["text"]
		
		if(addLust != 0):
			addLust = enemyCharacter.receiveDamage(DamageType.Lust, addLust)
			addMessage("Enemy received "+str(addLust)+" lust")
		if(addPain != 0):
			addPain = enemyCharacter.receiveDamage(DamageType.Physical, addPain)
			addMessage("Enemy received "+str(addPain)+" pain")
		if(addStamina != 0):
			enemyCharacter.addStamina(-addStamina)
			if(addStamina < 0):
				addMessage("Enemy gained "+str(-addStamina)+" stamina")
			else:
				addMessage("Enemy used "+str(addStamina)+" stamina")
		
		if(additionalStruggleText != null && additionalStruggleText != ""):
			whatHappened += "[i]"+GM.ui.processString(additionalStruggleText, {"user": enemyID})+"[/i]\n"
	
	whatHappened = whatHappened.rstrip("\n")
	if(state == ""):
		setState("fighting")

func afterTurnChecks():
	#GM.pc.processBattleTurn()
	#enemyCharacter.processBattleTurn()
	#enemyCharacter.updateNonBattleEffects()
	#GM.pc.updateNonBattleEffects()
	
	var won = checkEnd()
	if(won == "lost"):
		setState("lost")
	if(won == "win"):
		setState("win")

func checkEnd():
	if(enemySurrendered):
		if(whatHappened != ""):
			whatHappened += "\n"
		whatHappened += "Enemy surrendered, you win the fight\n"
		battleState = "win"
		battleEndedHow = "surrendered"
		return "win"
	if(enemyCharacter.getPain() >= enemyCharacter.painThreshold()):
		if(whatHappened != ""):
			whatHappened += "\n"
		whatHappened += "Enemy is in too much pain to continue\n"
		battleState = "win"
		battleEndedHow = "pain"
		return "win"
	if(enemyCharacter.getLust() >= enemyCharacter.lustThreshold()):
		if(whatHappened != ""):
			whatHappened += "\n"
		whatHappened += "Enemy is too aroused to continue\n"
		battleState = "win"
		battleEndedHow = "lust"
		return "win"
	if(GM.pc.getPain() >= GM.pc.painThreshold()):
		if(whatHappened != ""):
			whatHappened += "\n"
		whatHappened += "You succumb to pain\n"
		battleState = "lost"
		battleEndedHow = "pain"
		playAnimation(StageScene.Solo, "defeat")
		return "lost"
	if(GM.pc.getLust() >= GM.pc.lustThreshold()):
		if(whatHappened != ""):
			whatHappened += "\n"
		whatHappened += "You're too aroused to continue\n"
		battleState = "lost"
		battleEndedHow = "lust"
		playAnimation(StageScene.Solo, "defeat")
		return "lost"
	
	return ""

func pcHasAnyAttacksOfCategory(category):
	var playerAttacks = GM.pc.getAttacks(battleName)
	for attackID in playerAttacks:
		if(attackID is Dictionary):
			attackID = attackID["attackID"]
		var attack: Attack = GlobalRegistry.getAttack(attackID)
		if(attack == null):
			assert(false, "Bad attack: "+attackID)
		if(attack.category == category):
			return true
	return false
	

func addAttackButtons(category):
	var playerAttacks = GM.pc.getAttacks(battleName)
	for attackDataOrString in playerAttacks:
		var attackID
		var attackData : Dictionary
		
		if(attackDataOrString is String):
			attackData = {"attackID" : attackDataOrString}
			attackID = attackDataOrString
		else:
			attackData = attackDataOrString
			attackID = attackDataOrString["attackID"]
		
		var attack: Attack = GlobalRegistry.getAttack(attackID)
		if(attack == null):
			assert(false, "Bad attack: "+attackID)
		if(attack.category != category):
			continue
			
		var desc = attack.getRequirementsColorText(GM.pc, enemyCharacter)
		desc += attack.getVisibleDesc(attackData)
			
		if(attack.canUse(GM.pc, enemyCharacter, attackData)):
			addButton(attack.getVisibleName(attackData),  desc, "doattack", [attackData])
		else:
			addDisabledButton(attack.getVisibleName(attackData),  desc)

func setPlayerAsAttacker():
	currentAttackerID = "pc"
	currentReceiverID = enemyID

func setEnemyAsAttacker():
	currentAttackerID = enemyID
	currentReceiverID = "pc"

func resolveCustomCharacterName(_charID):
	if(_charID == "attacker" && currentAttackerID != ""):
		return currentAttackerID
	if(_charID in ["receiver", "reciever"] && currentReceiverID != ""):
		return currentReceiverID
	
	return null

func _react_scene_end(_tag, _result):
	if(_tag == "struggle_scene"):
		if(_result is Array && _result.size() > 0 && _result[0] == false):
			return
		
		setState("fighting")
		beforeTurnChecks(true)
		
		whatEnemyDid += aiTurn()

		afterTurnChecks()
	
	if(_tag == "inventory_scene"):
		if(_result is Array && _result.size() > 0 && _result[0] == false):
			return
		
		setState("fighting")
		beforeTurnChecks(true)
		
		whatEnemyDid += aiTurn()

		afterTurnChecks()
		
	if(_tag == "lootingscene"):
		endScene([battleState, battleEndedHow])

func supportsBattleTurns():
	return true

func saveData():
	var data = .saveData()
	
	data["enemyID"] = enemyID
	data["whatPlayerDid"] = whatPlayerDid
	data["whatEnemyDid"] = whatEnemyDid
	data["whatHappened"] = whatHappened
	data["battleState"] = battleState
	data["battleEndedHow"] = battleEndedHow
	data["savedAIAttackID"] = savedAIAttackID
	data["battleName"] = battleName
	data["currentAttackerID"] = currentAttackerID
	data["currentReceiverID"] = currentReceiverID
	data["restraintIdsForcedByPC"] = restraintIdsForcedByPC
	data["enemySurrendered"] = enemySurrendered
	data["lastPlayerAttackData"] = lastPlayerAttackData
	data["restraintsPickedCategory"] = restraintsPickedCategory
	
	if(enemyAIStrategy != null):
		data["enemyStrategyData"] = enemyAIStrategy.saveData()
	
	return data
	
func loadData(data):
	.loadData(data)
	
	enemyID = SAVE.loadVar(data, "enemyID", "")
	whatPlayerDid = SAVE.loadVar(data, "whatPlayerDid", "")
	whatEnemyDid = SAVE.loadVar(data, "whatEnemyDid", "")
	whatHappened = SAVE.loadVar(data, "whatHappened", "")
	battleState = SAVE.loadVar(data, "battleState", "")
	battleEndedHow = SAVE.loadVar(data, "battleEndedHow", "")
	savedAIAttackID = SAVE.loadVar(data, "savedAIAttackID", "")
	enemyCharacter = GlobalRegistry.getCharacter(enemyID)
	battleName = SAVE.loadVar(data, "battleName", "")
	currentAttackerID = SAVE.loadVar(data, "currentAttackerID", "")
	currentReceiverID = SAVE.loadVar(data, "currentReceiverID", "")
	restraintIdsForcedByPC = SAVE.loadVar(data, "restraintIdsForcedByPC", [])
	enemySurrendered = SAVE.loadVar(data, "enemySurrendered", false)
	lastPlayerAttackData = SAVE.loadVar(data, "lastPlayerAttackData", null)
	restraintsPickedCategory = SAVE.loadVar(data, "restraintsPickedCategory", "")
	
	enemyAIStrategy = enemyCharacter.getAiStrategy(battleName)
	enemyAIStrategy.battleName = battleName
	enemyAIStrategy.setCharacterID(enemyID)
	enemyAIStrategy.loadData(SAVE.loadVar(data, "enemyStrategyData", {}))

func getDebugActions():
	return [
		{
			"id": "instantWin",
			"name": "Instant win",
			"args": [
			],
		},
		{
			"id": "healEnemy",
			"name": "Heal enemy",
			"args": [
			],
		},
	]

func doDebugAction(_id, _args = {}):
	if(_id == "instantWin"):
		enemyCharacter.addLust(enemyCharacter.lustThreshold())
		GM.main.pickOption("wait", [])
	if(_id == "healEnemy"):
		enemyCharacter.addPain(-enemyCharacter.painThreshold())
		enemyCharacter.addLust(-enemyCharacter.lustThreshold())
