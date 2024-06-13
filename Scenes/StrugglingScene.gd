extends "res://Scenes/SceneBase.gd"
var unlockedRestraintID = ""
var actionText = ""
var struggleText = ""
var additionalStruggleText = ""
var canKeepTheRestraint = false
var keptRestraintID = ""
var keyGameTries: int = 3
var keyGameValue: int = 50
var keyText = ""
var fightMode = false
var restraintID = ""
var shouldPlayAnimations = true

#var minigameScene = preload("res://Game/Minigames/Struggling/StrugglingGame.tscn")
var minigameScene = preload("res://Game/Minigames/ClickAtTheRightTime/ClickAtTheRightTime.tscn")
var pickMinigameScene = preload("res://Game/Minigames/ClickAtTheRightTime/ClickAtTheRightTime.tscn")
var cutMinigameScene = preload("res://Game/Minigames/ClickAtTheRightTime/ClickAtTheRightTime.tscn")

func _init():
	sceneID = "StrugglingScene"

func _initScene(_args = []):
	if(_args.size() > 0):
		fightMode = _args[0]
	if(_args.size() > 1):
		shouldPlayAnimations = _args[1]
	
	var allItems = GM.pc.getInventory().getAllEquippedItems()
	for itemSlot in allItems:
		var item: ItemBase = allItems[itemSlot]
		if(item.isRestraint()):
			item.getRestraintData().resetOnNewTry()

func _run():
	if(state == ""):
		if(shouldPlayAnimations):
			playAnimation(StageScene.Solo, "stand")
		
		var isBlind = GM.pc.isBlindfolded()
		saynn("Pick the restraint you wanna focus on. Keep in mind that some restraints will be harder to remove depending on what you have on. Crying from pain or moaning loudly from an orgasm will probably attract someone")
		
		if(GM.pc.getInventory().hasItemID("restraintkey") || GM.pc.getInventory().hasItemID("lockPicker") || GM.pc.getInventory().hasItemID("safetyCutter")):
			addButtonAt(13, "Use tool", "Use one of your tool to unlock something", "usetool")
		else:
			addDisabledButtonAt(13, "Use tool", "You don't have any usable tool")
		addButtonAt(14, "Give up", "Stop struggling", "endthescenedidnothing")
		
		for item in GM.pc.getInventory().getEquppedRestraints():
			var restraintData: RestraintData = item.getRestraintData()
			
			sayn(item.getVisibleName()+", restraint level: "+restraintData.getVisibleLevel(isBlind))
			#sayn("- Durability: "+restraintData.getVisibleDurability())
			if restraintData.isLocked():
				sayn("- Tightness: "+restraintData.getVisibleTightness()+" ("+restraintData.getTightnessPercentString()+")")
				saynn("- Is locked: "+restraintData.getVisibleLockStrength()+" ("+restraintData.getLockPercentString()+")")
			else:
				saynn("- Tightness: "+restraintData.getVisibleTightness()+" ("+restraintData.getTightnessPercentString()+")")
			
			if(!restraintData.canStruggle()):
				continue
			
			if(GM.pc.getStamina() > 0):
				addButton(item.getVisibleName(), "Focus on this restraint", "startStruggleAgainst", [item.getUniqueID()])
			else:
				addDisabledButton(item.getVisibleName(), "You are out of stamina")

		
		#generateActions()

	if(state == "usetool"):
		var keyAmount = GM.pc.getInventory().getAmountOf("restraintkey")
		var pickerAmount = GM.pc.getInventory().getAmountOf("lockPicker")
		var cutterAmount = GM.pc.getInventory().getAmountOf("safetyCutter")
		if keyAmount > 0:
			saynn("You have "+str(keyAmount)+" "+Util.multipleOrSingularEnding(keyAmount, "key")+". Each one can unlock one piece of gear.")
			addButton("Key", "Use one of your key to unlock something", "usekey")
		if pickerAmount > 0:
			saynn("You have "+str(pickerAmount)+" "+Util.multipleOrSingularEnding(keyAmount, "lock pick")+". Each one can pick a lock on one piece of gear.")
			addButton("Picker", "Use one of your lock pick to pick some lock", "usepicker")
		if cutterAmount > 0:
			saynn("You have "+str(cutterAmount)+" "+Util.multipleOrSingularEnding(keyAmount, "safety cutter")+". Each one can cut one piece of gear.")
			addButton("Cutter", "Use one of your safety cutter to cut something", "usecutter")

		saynn("Which one do you wanna use?")
		addButton("Back", "You don't wanna use anything", "")

	if(state == "usepicker"):
		var pickerAmount = GM.pc.getInventory().getAmountOf("lockPicker")
		saynn("You have "+str(pickerAmount)+" "+Util.multipleOrSingularEnding(pickerAmount, "lock pick")+". Each one can pick a lock on one piece of gear.")
		saynn("Which restraint do you wanna lockpick.")

		for item in GM.pc.getInventory().getEquppedRestraints():
			var restraintData: RestraintData = item.getRestraintData()
			if(!restraintData.canUnlockWithKey()):
				addDisabledButton(item.getVisibleName(), "This restraint doesn't seem to have a keyhole")
				continue
			addButton(item.getVisibleName(), item.getVisisbleDescription(), "dolockpick", [item.getUniqueID()])
		addButton("Back", "You don't wanna lockpick anything", "usetool")

	if(state == "usecutter"):
		var cutterAmount = GM.pc.getInventory().getAmountOf("safetyCutter")
		saynn("You have "+str(cutterAmount)+" "+Util.multipleOrSingularEnding(cutterAmount, "safety cutter")+". Each one can cut one piece of gear.")
		saynn("Which restraint do you wanna cut.")

		for item in GM.pc.getInventory().getEquppedRestraints():
			var restraintData: RestraintData = item.getRestraintData()
			if(!restraintData.canBeCut()):
				addDisabledButton(item.getVisibleName(), "this type of restriction doesn't seem to have a good place to cut")
				continue
			addButton(item.getVisibleName(), item.getVisisbleDescription(), "docut", [item.getUniqueID()])
		addButton("Back", "You don't wanna cut anything", "usetool")

		
	if(state == "usekey"):
		var keyAmount = GM.pc.getInventory().getAmountOf("restraintkey")
		saynn("You have "+str(keyAmount)+" "+Util.multipleOrSingularEnding(keyAmount, "key")+". Each one can unlock one piece of gear.")
		saynn("Which restraint do you wanna unlock.")

		for item in GM.pc.getInventory().getEquppedRestraints():
			var restraintData: RestraintData = item.getRestraintData()
			if(!restraintData.canUnlockWithKey()):
				addDisabledButton(item.getVisibleName(), "This restraint doesn't seem to have a keyhole")
				continue
			addButton(item.getVisibleName(), item.getVisisbleDescription(), "dounlock", [item.getUniqueID()])
		addButton("Back", "You don't wanna unlock anything", "usetool")
	
	if state == "pickminigame":
		var item = GM.pc.getInventory().getItemByUniqueID(restraintID)
		var restraintData: RestraintData = item.getRestraintData()
		
		if(shouldPlayAnimations):
			var animToPlay = restraintData.getResistAnimation()
			if(animToPlay != null && animToPlay != ""):
				playAnimation(StageScene.Solo, animToPlay)
		
		var game = pickMinigameScene.instance()
		GM.ui.addCustomControl("minigame", game)		

		game.setDifficulty(restraintData.getLevel())
		game.connect("minigameCompleted", self, "onPickMinigameCompleted")
		addButton("Give up", "Give it up and lose 10 stamina", "giveupstruggle")
	
	if state == "cutminigame":
		var item = GM.pc.getInventory().getItemByUniqueID(restraintID)
		var restraintData: RestraintData = item.getRestraintData()
		
		if(shouldPlayAnimations):
			var animToPlay = restraintData.getResistAnimation()
			if(animToPlay != null && animToPlay != ""):
				playAnimation(StageScene.Solo, animToPlay)
		
		var game = pickMinigameScene.instance()
		GM.ui.addCustomControl("minigame", game)		

		game.setDifficulty(restraintData.getLevel())
		game.connect("minigameCompleted", self, "onCutMinigameCompleted")
		addButton("Give up", "Give it up and lose 10 stamina", "giveupstruggle")
	
	
	if(state == "keyminigame"):
		saynn("Since you can't use your fingers you have to carefully balance the key between your palms and guide it towards the lock.")
		
		saynn("To succsessfully unlock the restraint you have to guess a number between 1 and 15. You have "+str(keyGameTries)+" "+Util.multipleOrSingularEnding(keyGameTries, "try", "tries")+" left")

		if(keyText != ""):
			saynn(keyText)

		#addTextbox("key_number")
		
		#addButton("Guess", "Try and guess this number", "key_guess")
		for _i in range(1, 16):
			addButton(str(_i), "Try this number", "key_guess", [_i])

	if(state == "keyminigameFailed"):
		saynn("Oops, you dropped the key and it broke. There goes that.")
		
		addButton("Continue", "Heck", "checkifokay")

	if(state == "startStruggleAgainst"):
		var item = GM.pc.getInventory().getItemByUniqueID(restraintID)
		var restraintData: RestraintData = item.getRestraintData()
		
		if(shouldPlayAnimations):
			var animToPlay = restraintData.getResistAnimation()
			if(animToPlay != null && animToPlay != ""):
				playAnimation(StageScene.Solo, animToPlay)
		
		var game = minigameScene.instance()
		GM.ui.addCustomControl("minigame", game)
		if(OPTIONS.isHardStruggleEnabled()):
			game.setHardStruggleEnabled(true)
		if(GM.pc.hasPerk(Perk.BDSMInstantEscape) && game.has_method("instantEscapePerk")):
			game.instantEscapePerk()
		if(GM.pc.isBlindfolded() && game.has_method("setIsBlindfolded")):
			game.setIsBlindfolded(true)
		if(GM.pc.hasPerk(Perk.BDSMPerfectStreak) && game.has_method("setHasAdvancedPerk")):
			game.setHasAdvancedPerk(true)
		
		game.setDifficulty(restraintData.getLevel())
		game.connect("minigameCompleted", self, "onMinigameCompleted")
		addButton("Give up", "Give up the struggle and lose 10 stamina", "giveupstruggle")


	if state == "struggleAgainst" || state == "pickSomething" || state == "cutSomething":
		saynn(struggleText)
		
		if(additionalStruggleText != ""):
			saynn(additionalStruggleText)
		
		if(canKeepTheRestraint):
			saynn("Do you wanna keep it?")
			
			addButton("Keep it", "Keep the restraint in your inventory", "checkifokay")
			addButton("No", "Throw it away", "getridandcheckifokay")
		else:
			addButton("Continue", "Okay", "checkifokay")


	if(state == "orgasm"):
		saynn("It's too much, you arch your back and moan loudly as you cum. You were so loud that someone might have heard that. (Temporary text)")
		
		addButton("Continue", "Oh no", "spottedcheck")

	if(state == "notspotted"):
		saynn("Seems like no one saw or heard you. Phew")
		
		if(GM.pc.getPain() >= GM.pc.painThreshold()):
			saynn("But you can't continue, you're in too much pain")
			
			addButton("Continue", "Aw", "endthescene")
		else:
			addButton("Continue", "Good", "")
		
	if(state == "toolusty"):
		saynn("You are too aroused to be able to escape from restraints")
		
		addButton("Continue", "Oh no", "endthescene")#"spottedcheck")
		
	if(state == "toopainful"):
		saynn("It's too painful! You let out a desperate cry. You were so loud that someone might have heard that. (Temporary text)")

		addButton("Continue", "Oh no", "endthescene")
		
	if(state == "unlockedGear"):
		saynn("You successfully unlocked the restraint. The key snaps in half, rendering it useless")
		
		addButton("Continue", "Good", "checkifokay")

func onMinigameCompleted(result):
	GM.main.pickOption("struggleAgainst", [restraintID, result])

func onPickMinigameCompleted(result):
	GM.main.pickOption("pickSomething", [restraintID, result])

func onCutMinigameCompleted(result):
	GM.main.pickOption("cutSomething", [restraintID, result])

		
func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
		
	if(_action == "endthescenedidnothing"):
		endScene([false])
		return
		
	if(_action == "giveupstruggle"):
		GM.pc.addStamina(-10)
		restraintID = ""
		setState("")
		return
		
	if(_action == "startStruggleAgainst"):
		var item = GM.pc.getInventory().getItemByUniqueID(_args[0])
		var restraintData: RestraintData = item.getRestraintData()
		
		if(!restraintData.shouldDoStruggleMinigame(GM.pc)):
			_action = "struggleAgainst"
		else:
			restraintID = _args[0]

	if(_action == "struggleAgainst"):
		var item = GM.pc.getInventory().getItemByUniqueID(_args[0])
		var restraintData: RestraintData = item.getRestraintData()
		var minigameStatus = 1.0
		var finalMinigameStatus = 1.0
		
		var instantUnlock = false
		var fatallFail = false
		if(_args.size() > 1):
			finalMinigameStatus = float(_args[1])
			
			if(float(_args[1]) >= 100.0):
				instantUnlock = true
				finalMinigameStatus = 1.0
			var minigameResult = float(_args[1])
			minigameStatus = pow(minigameResult, 1.5) * 2.0
			if(minigameResult >= 1.0 && GM.pc.hasPerk(Perk.BDSMBetterStruggling)):
				minigameStatus *= 2.0
			if float(_args[1]) < 0.0:
				fatallFail = true
				minigameStatus = -pow(-minigameResult, 1.5) * 2.0
				finalMinigameStatus = 0.0
		
		var damage = 0.0
		var lockDamage = 0.0
		var addLust = 0
		var addPain = 0
		var addStamina = 0

		var struggleData
		if fatallFail:
			struggleData = restraintData.doFailingStruggle(GM.pc, minigameStatus)
		else:
			struggleData = restraintData.doStruggle(GM.pc, minigameStatus)
		
		if(struggleData.has("damage")):
			damage = struggleData["damage"] * abs(minigameStatus)
			if(damage > 0.0 && instantUnlock):
				damage = 1.0
		if struggleData.has("lockDamage"):
			lockDamage = struggleData["lockDamage"]
		if(struggleData.has("lust") && struggleData["lust"] > 0):
			addLust = struggleData["lust"]
		if(struggleData.has("pain") && struggleData["pain"] > 0):
			addPain = struggleData["pain"]
		if(struggleData.has("stamina") && struggleData["stamina"] != 0):
			addStamina = struggleData["stamina"]
		
		struggleText = struggleData["text"]
		
		if(!fightMode):
			var turnData = GM.pc.processStruggleTurn(true)
			damage += turnData["damage"]
			lockDamage += turnData["lockDamage"]
			addLust += turnData["lust"]
			addPain += turnData["pain"]
			addStamina += turnData["stamina"]
			additionalStruggleText = turnData["text"]
			
		# less xp without progression more in combat
		if(!instantUnlock && damage > 0.0 && damage < 1.0):
			var mult = 4
			if fightMode:
				mult = 5
			GM.pc.addSkillExperience(Skill.BDSM, restraintData.getLevel() * mult)

		if damage > 0 && restraintData.isLocked():
			var con = 3.0 + restraintData.getLevel()
			damage = damage/con
			if damage > 1.0/con:
				damage = 1.0/con
			addMessage("Surely it would have been done better if only it was not locked.")
			
		if(fatallFail):
			addMessage("You tried really hard but you completely failed.")
		if(damage < 0.0):
			restraintData.takeDamage(damage)
			addMessage("You lost "+str(Util.roundF(-damage*100.0, 1))+"% of progress")
		if(damage > 0.0):
			restraintData.takeDamage(damage)
			addMessage("You made "+str(Util.roundF(damage*100.0, 1))+"% of progress ("+str(Util.roundF(finalMinigameStatus*100.0, 1))+"% efficiency)")
		if(lockDamage > 0.0):
			restraintData.takeLockDamage(lockDamage)
			addMessage("You also made "+str(Util.roundF(lockDamage*100.0, 1))+"% of progress with lock ("+str(Util.roundF(finalMinigameStatus*100.0, 1))+"% efficiency)")
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
		
		canKeepTheRestraint = false
		if(restraintData.shouldBeRemoved()):
			struggleText += "\n[b]"+restraintData.getRemoveMessage()+"[/b]"
			restraintData.onStruggleRemoval()
			GM.pc.getInventory().removeEquippedItem(item)
			
			if restraintData.alwaysBreaksWhenStruggledOutOf():
				canKeepTheRestraint = false
			elif restraintData.alwaysSavedWhenStruggledOutOf():
				canKeepTheRestraint = true
			else:
				# strugling can damage the bondage gear
				var _newLevel = int(RNG.randf_rangeAdv(0, restraintData.getLevel()))
				if GM.pc.hasPerk(Perk.BDSMCollector) && RNG.chance(50):
					 _newLevel = restraintData.getLevel()

				if _newLevel >= 1:
					canKeepTheRestraint = true
					restraintData.setLevel(_newLevel)
					GM.pc.getInventory().addItem(item)
					keptRestraintID = item.getUniqueID()
		
		processTime(1*60)


	if _action == "pickSomething":
		var item = GM.pc.getInventory().getItemByUniqueID(_args[0])
		var restraintData: RestraintData = item.getRestraintData()
		var minigameStatus = 1.0
		
		if(_args.size() > 1):
			minigameStatus = float(_args[1])
					
		var damage = 0.0
		var lockDamage = 0.0
		var addLust = 0
		var addPain = 0
		var addStamina = 0

		var _data = restraintData.doLockpick(GM.pc, minigameStatus)

		if _data.has("damage"):
			damage = _data["damage"]
		if _data.has("lockDamage"):
			lockDamage = _data["lockDamage"]
		if _data.has("lust"):
			addLust = _data["lust"]
		if _data.has("pain"):
			addPain = _data["pain"]
		if _data.has("stamina"):
			addStamina = _data["stamina"]
		
		struggleText = _data["text"]
		
		if(!fightMode):
			var _turnData = GM.pc.processLockpickTurn(true)
			damage += _turnData["damage"]
			lockDamage += _turnData["lockDamage"]
			addLust += _turnData["lust"]
			addPain += _turnData["pain"]
			addStamina += _turnData["stamina"]
			additionalStruggleText = _turnData["text"]
			
		# no xp without progression more in combat
		if lockDamage > 0.0:
			var mult = 3
			if fightMode:
				mult = 5
			GM.pc.addSkillExperience(Skill.BDSM, restraintData.getLevel() * mult)
			
		if lockDamage < 0.0:
			restraintData.takeLockDamage(lockDamage)
			addMessage("You lost "+str(Util.roundF(-lockDamage*100.0, 1))+"% of progress")
		if lockDamage > 0.0:
			restraintData.takeLockDamage(lockDamage)
			addMessage("You made "+str(Util.roundF(lockDamage*100.0, 1))+"% of progress ("+str(Util.roundF(minigameStatus*100.0, 1))+"% efficiency)")
		if damage > 0.0:
			restraintData.takeDamage(lockDamage)
			addMessage("You made "+str(Util.roundF(damage*100.0, 1))+"% of progress ("+str(Util.roundF(minigameStatus*100.0, 1))+"% efficiency)")
		if addLust != 0:
			addLust = GM.pc.receiveDamage(DamageType.Lust, addLust)
			addMessage("You received "+str(addLust)+" lust")
		if addPain != 0:
			addPain = GM.pc.receiveDamage(DamageType.Physical, addPain)
			addMessage("You received "+str(addPain)+" pain")
		if addStamina != 0:
			GM.pc.addStamina(-addStamina)
			if addStamina < 0:
				addMessage("You gained "+str(-addStamina)+" stamina")
			else:
				addMessage("You used "+str(addStamina)+" stamina")
		
		if(!restraintData.isLocked()):
			struggleText += "\n[b]"+restraintData.getLockpickedMessage()+"[/b]"
			restraintData.onLockPicked()
		
		processTime(1*60)


	if _action == "cutSomething":
		var item = GM.pc.getInventory().getItemByUniqueID(_args[0])
		var restraintData: RestraintData = item.getRestraintData()
		var minigameStatus = 1.0
		
		if(_args.size() > 1):
			minigameStatus = float(_args[1])
					
		var damage = 0.0
		var lockDamage = 0.0
		var addLust = 0
		var addPain = 0
		var addStamina = 0

		var _data = restraintData.doCut(GM.pc, minigameStatus)

		if _data.has("damage"):
			damage = _data["damage"]
		if _data.has("lockDamage"):
			lockDamage = _data["lockDamage"]
		if _data.has("lust"):
			addLust = _data["lust"]
		if _data.has("pain"):
			addPain = _data["pain"]
		if _data.has("stamina"):
			addStamina = _data["stamina"]
		
		struggleText = _data["text"]
		
		if(!fightMode):
			var _turnData = GM.pc.processLockpickTurn(true)
			damage += _turnData["damage"]
			lockDamage += _turnData["lockDamage"]
			addLust += _turnData["lust"]
			addPain += _turnData["pain"]
			addStamina += _turnData["stamina"]
			additionalStruggleText = _turnData["text"]
			
		# no xp without progression more in combat
		if damage > 0.0:
			var mult = 3
			if fightMode:
				mult = 5
			GM.pc.addSkillExperience(Skill.BDSM, restraintData.getLevel() * mult)

		if damage < 0.0:
			restraintData.takeDamage(damage)
			addMessage("You lost "+str(Util.roundF(-damage*100.0, 1))+"% of progress")
		if damage > 0.0:
			restraintData.takeDamage(damage)
			addMessage("You made "+str(Util.roundF(damage*100.0, 1))+"% of progress ("+str(Util.roundF(minigameStatus*100.0, 1))+"% efficiency)")
		if lockDamage > 0.0:
			restraintData.takeLockDamage(lockDamage)
			addMessage("You made "+str(Util.roundF(lockDamage*100.0, 1))+"% of progress ("+str(Util.roundF(minigameStatus*100.0, 1))+"% efficiency)")
		if addLust != 0:
			addLust = GM.pc.receiveDamage(DamageType.Lust, addLust)
			addMessage("You received "+str(addLust)+" lust")
		if addPain != 0:
			addPain = GM.pc.receiveDamage(DamageType.Physical, addPain)
			addMessage("You received "+str(addPain)+" pain")
		if addStamina != 0:
			GM.pc.addStamina(-addStamina)
			if addStamina < 0:
				addMessage("You gained "+str(-addStamina)+" stamina")
			else:
				addMessage("You used "+str(addStamina)+" stamina")
		
		canKeepTheRestraint = false
		if restraintData.shouldBeRemoved():
			struggleText += "\n[b]"+restraintData.getRemoveMessage()+"[/b]"
			restraintData.onStruggleRemoval()
			GM.pc.getInventory().removeEquippedItem(item)
			
			if restraintData.alwaysBreaksWhenStruggledOutOf():
				canKeepTheRestraint = false
			elif restraintData.alwaysSavedWhenStruggledOutOf():
				canKeepTheRestraint = true
			# ripping usually destroys the bondage gear
			elif GM.pc.hasPerk(Perk.BDSMCollector) && RNG.chance(50):
				var _newLevel = int(RNG.randf_rangeAdv(-1, restraintData.getLevel()))
				if _newLevel >= 1:
					canKeepTheRestraint = true
					restraintData.setLevel(restraintData.getLevel())
					GM.pc.getInventory().addItem(item)
					keptRestraintID = item.getUniqueID()
		
		processTime(1*60)

		
	if(_action == "getridandcheckifokay"):
		var item = GM.pc.getInventory().getItemByUniqueID(keptRestraintID)
		if(item != null):
			GM.pc.getInventory().removeItem(item)
		
	if(_action == "checkifokay" || _action == "getridandcheckifokay"):
		if(fightMode):
			endScene()
			return
		
		#if(GM.pc.getLust() >= GM.pc.lustThreshold()):
		#	setState("toolusty")
			#setState("orgasm")
			#GM.pc.orgasmFrom("pc")
		#	return
		#if(GM.pc.getPain() >= GM.pc.painThreshold()):
		#	setState("toopainful")
		#	return
		setState("")
		return
		
	if(_action == "spottedcheck"):
		setState("notspotted")
		return


	if(_action == "dolockpick"):
		restraintID = _args[0]
		var item = GM.pc.getInventory().getItemByUniqueID(restraintID)
		var _restraintData: RestraintData = item.getRestraintData()
		
		GM.pc.getInventory().removeXOfOrDestroy("lockPicker", 1)
		keyText = ""
		setState("pickminigame")
		return


	if(_action == "docut"):
		restraintID = _args[0]
		var item = GM.pc.getInventory().getItemByUniqueID(restraintID)
		var _restraintData: RestraintData = item.getRestraintData()
		
		GM.pc.getInventory().removeXOfOrDestroy("safetyCutter", 1)
		keyText = ""
		setState("cutminigame")
		return
		
	if(_action == "dounlock"):
		unlockedRestraintID = _args[0]
		var item = GM.pc.getInventory().getItemByUniqueID(unlockedRestraintID)
		var restraintData: RestraintData = item.getRestraintData()
		
		GM.pc.getInventory().removeXOfOrDestroy("restraintkey", 1)
		if(!GM.pc.hasBlockedHands() && !GM.pc.hasBoundArms()):
			if(restraintData == null || restraintData.alwaysBreaksWhenStruggledOutOf()):
				GM.pc.getInventory().removeEquippedItem(item)
			else:
				GM.pc.getInventory().unequipItem(item)
			setState("unlockedGear")
		else:
			keyGameTries = 3
			if(GM.pc.hasPerk(Perk.BDSMBetterKeys)):
				keyGameTries += 2
			keyGameValue = RNG.randi_range(1, 15)
			keyText = ""
			setState("keyminigame")
		return
		
	if(_action == "key_guess"):
		
#		var textboxText = getTextboxData("key_number")
#		if(textboxText == "" || !textboxText.is_valid_integer()):
#			keyText = ""
#			setState("keyminigame")
#			return
		
		var number = _args[0]#int(textboxText)
		if(number == keyGameValue):
			var item = GM.pc.getInventory().getItemByUniqueID(unlockedRestraintID)
			var restraintData: RestraintData = item.getRestraintData()
			if(restraintData == null || restraintData.alwaysBreaksWhenStruggledOutOf()):
				GM.pc.getInventory().removeEquippedItem(item)
			else:
				GM.pc.getInventory().unequipItem(item)
			setState("unlockedGear")
			return
		
		var diff = abs(number - keyGameValue)
		if(number > keyGameValue):
			if(diff >= 8):
				keyText = str(number)+" is not even close. You almost dropped the key right there"
			elif(diff >= 5):
				keyText = str(number)+" is way too much"
			elif(diff >= 3):
				keyText = str(number)+" is too much"
			elif(diff >= 2):
				keyText = str(number)+" is too much but you feel that you're pretty close"
			else:
				keyText = str(number)+" is very close."
		if(number < keyGameValue):
			if(diff >= 8):
				keyText = str(number)+" is not even close. You almost dropped the key right there"
			elif(diff >= 5):
				keyText = str(number)+" is way too little"
			elif(diff >= 3):
				keyText = str(number)+" is too little"
			elif(diff >= 2):
				keyText = str(number)+" is too little but you feel that you're pretty close"
			else:
				keyText = str(number)+" is very close."
		
		keyGameTries -= 1
		if(keyGameTries <= 0):
			setState("keyminigameFailed")
		else:
			setState("keyminigame")
		return
		
	setState(_action)

func resolveCustomCharacterName(_charID):
	if(_charID == "user"):
		return "pc"

func saveData():
	var data = .saveData()
	
	data["unlockedRestraintID"] = unlockedRestraintID
	data["actionText"] = actionText
	data["struggleText"] = struggleText
	data["additionalStruggleText"] = additionalStruggleText
	data["canKeepTheRestraint"] = canKeepTheRestraint
	data["keptRestraintID"] = keptRestraintID
	data["keyGameTries"] = keyGameTries
	data["keyGameValue"] = keyGameValue
	data["keyText"] = keyText
	data["fightMode"] = fightMode
	data["restraintID"] = restraintID
	data["shouldPlayAnimations"] = shouldPlayAnimations
	
	return data
	
func loadData(data):
	.loadData(data)
	
	unlockedRestraintID = SAVE.loadVar(data, "unlockedRestraintID", "")
	actionText = SAVE.loadVar(data, "actionText", "")
	struggleText = SAVE.loadVar(data, "struggleText", "")
	additionalStruggleText = SAVE.loadVar(data, "additionalStruggleText", "")
	canKeepTheRestraint = SAVE.loadVar(data, "canKeepTheRestraint", false)
	keptRestraintID = SAVE.loadVar(data, "keptRestraintID", "")
	keyGameTries = SAVE.loadVar(data, "keyGameTries", 3)
	keyGameValue = SAVE.loadVar(data, "keyGameValue", 7)
	keyText = SAVE.loadVar(data, "keyText", "")
	fightMode = SAVE.loadVar(data, "fightMode", false)
	restraintID = SAVE.loadVar(data, "restraintID", "")
	shouldPlayAnimations = SAVE.loadVar(data, "shouldPlayAnimations", true)
