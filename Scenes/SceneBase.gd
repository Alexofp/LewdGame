extends Node
class_name SceneBase

#signal sayText(text)
#signal clearText
#signal answered
#signal clearButtons
#signal addButton(text, method, tooltip)
#signal addDisabledButton(text, tooltip)
signal sceneEnded(result)
var state: String = ""
var sceneID: String = "UNREGISTERED_SCENE"
var currentCharactersVariants: Dictionary = {}
var sceneTag = ""
#var currentCharacter: String = ""
var sceneEndedFlag = false
var sceneEndedArgs
var showFightUI = false
var sceneSavedItemsInv:LightInventory = LightInventory.new()
var uniqueSceneID: int = -1
var parentSceneUniqueID: int = -1
var showedDeveloperCommentary = false #No need to save this one

func _run():
	pass

func _react(_action: String, _args):
	pass
	
	#if(has_method(method)):
	#	GM.ui.clearText()
	#	GM.ui.clearButtons()
		
	#	callv(method, [_args])
	#else:
	#	print("Error: method with the name '"+method+"' is not found in "+name + " ("+sceneID+")")

func _react_scene_end(_tag, _result):
	pass

func _initScene(_args = []):
	pass

func _reactInit():
	pass

# Utility
func initScene(args = []):
	clearCharacter()
	_initScene(args)
	_reactInit()
	
	#checkSceneEnded()

func run():
	GM.pc.updateNonBattleEffects()
	for id in currentCharactersVariants:
		var character = GlobalRegistry.getCharacter(id)
		if(!character):
			continue
		character.updateNonBattleEffects()
	
	GM.ui.clearText()
	GM.ui.clearButtons()
	GM.ui.clearUItextboxes()
	_run()
	GM.ES.triggerRun(Trigger.SceneAndStateHook, [sceneID, state])
	
	if(showFightUI):
		GM.ui.getCharactersPanel().switchToFightMode()
	else:
		GM.ui.getCharactersPanel().switchToNormalMode()

	# add exit scene button if there is no other way to continue
	if !GM.ui.hasButtons():
		GM.ui.addButton("EXIT", "End scene", "endthescene")
		Log.warning("Default exit in scene: " + sceneID)
		
	GM.pc.updateEffectPanel(GM.ui.getPlayerStatusEffectsPanel())
	GM.ui.updateCharactersInPanel()
	GM.ui.setSceneCreator(getSceneCreator(), shouldShowDevCommentaryIcon())
	GM.ui.setSceneArtWork(Images.getSceneArt(self))
	GM.ui.setBigAnswersMode(shouldDisplayBigButtons())

	
	checkSceneEnded()
		
func checkSceneEnded():
	if(sceneEndedFlag):
		_onSceneEnd()
		GM.main.removeScene(self, sceneEndedArgs)
		emit_signal("sceneEnded", sceneEndedArgs)
		print("removing scene "+name)
		
		if(!sceneSavedItemsInv.isEmpty()):
			var newItems = []
			while(!sceneSavedItemsInv.isEmpty()):
				var theItem = sceneSavedItemsInv.items.front()
				sceneSavedItemsInv.removeItem(theItem)
				newItems.append(theItem)
			
			runScene("LootingScene", [{"items": newItems}])
			sceneSavedItemsInv.items.clear()
		
		queue_free()

func addItemToSavedItems(theItem):
	if(theItem == null):
		return
	if(sceneSavedItemsInv.hasItem(theItem)):
		return
	sceneSavedItemsInv.addItem(theItem)

func addFilledCondomToLootIfPerk(theItem):
	if(GM.pc.hasPerk(Perk.CumKeepCondoms)):
		addItemToSavedItems(theItem)

func react(_action: String, _args):
	var result = _react(_action, _args)
	#checkSceneEnded()
	return result

func setState(newState: String):
	state = newState

func getState() -> String:
	return state

func say(_text: String):
	if(GM.ui):
		GM.ui.say(_text)
	#emit_signal("sayText", _text)

func sayn(_text: String):
	say(_text+"\n")

func saynn(_text: String):
	say(_text+"\n\n")

func addCharacter(id: String, variant: Array = []):
	if(id == ""):
		return
	currentCharactersVariants[id] = variant
	GM.main.startUpdatingCharacter(id)
	if(GM.main.getCurrentScene() == self):
		GM.ui.addCharacterToPanel(id, variant)

func removeCharacter(id: String):
	var _ok = currentCharactersVariants.erase(id)
	if(GM.main.getCurrentScene() == self):
		GM.ui.removeCharacterFromPanel(id)

func hasCharacter(id: String):
	if(currentCharactersVariants.has(id)):
		return true
	return false

func updateCharacter():
	if(GM.main.getCurrentScene() == self):
		GM.ui.clearCharactersPanel()
		for id in currentCharactersVariants:
			var character = GlobalRegistry.getCharacter(id)
			if(!character):
				continue
			GM.ui.addCharacterToPanel(id, currentCharactersVariants[id])

func clearCharacter():
	currentCharactersVariants.clear()
	if(GM.main.getCurrentScene() == self):
		GM.ui.clearCharactersPanel()

func _onSceneEnd():
	pass

func endScene(result = []):
	sceneEndedFlag = true
	sceneEndedArgs = result
	checkSceneEnded()

func runScene(id: String, args = [], tag = ""):
	var scene = GM.main.runScene(id, args, uniqueSceneID)
	scene.sceneTag = tag

func react_scene_end(_tag, _result):
	print(name+": My parent scene has ended")
	#updateCharacter()
	_react_scene_end(_tag, _result)
	#checkSceneEnded()

func addNextButton(method: String, args = []):
	if(GM.ui):
		GM.ui.addButton("Next", "", method, args)
	#addButton("Next")

func addButton(text: String, tooltip: String = "", method: String = "", args = []):
	GM.ui.addButton(text, tooltip, method, args)
	#emit_signal("addButton", text, method, tooltip)
	
func addDisabledButton(text: String, tooltip: String = ""):
	GM.ui.addDisabledButton(text, tooltip)
	#emit_signal("addDisabledButton", text, tooltip)

func addButtonAt(index:int, text: String, tooltip: String = "", method: String = "", args = []):
	GM.ui.addButtonAt(index, text, tooltip, method, args)
	
func addDisabledButtonAt(index:int, text: String, tooltip: String = ""):
	GM.ui.addDisabledButtonAt(index, text, tooltip)

func addButtonUnlessLate(text: String, tooltip: String = "", method: String = "", args = [], latetext: String = "It's way too late for that"):
	if(GM.main.isVeryLate()):
		addDisabledButton(text, latetext)
	else:
		addButton(text, tooltip, method, args)

func addButtonWithChecks(text: String, tooltip: String, method: String, args, checks: Array):
	var badCheck = ButtonChecks.check(checks)
	if(badCheck == null):
		addButton(text, ButtonChecks.getPrefix(checks) + tooltip, method, args)
	else:
		var reasonText = ButtonChecks.getReasonText(badCheck)
		if(reasonText != ""):
			reasonText = "["+reasonText+"] "
		addDisabledButton(text, ButtonChecks.getPrefix(checks) + reasonText +tooltip)

func addButtonWithChecksAt(index:int, text: String, tooltip: String, method: String, args, checks: Array):
	var badCheck = ButtonChecks.check(checks)
	if(badCheck == null):
		addButtonAt(index, text, ButtonChecks.getPrefix(checks) + tooltip, method, args)
	else:
		var reasonText = ButtonChecks.getReasonText(badCheck)
		if(reasonText != ""):
			reasonText = "["+reasonText+"] "
		addDisabledButtonAt(index, text, ButtonChecks.getPrefix(checks) + reasonText +tooltip)

func addTextbox(id):
	return GM.ui.addUITextbox(id)

func addBigTextbox(id):
	return GM.ui.addBigUITextbox(id)

func getTextboxData(id):
	return GM.ui.getUIdata(id)

func addMessage(text: String):
	GM.main.addMessage(text)

func addExperienceToPlayer(ex: int, showMessage: bool = true):
	if(showMessage):
		addMessage("You received "+str(ex)+" experience")
	GM.pc.addExperience(ex)

func friskPlayer():
	var foundAnything = false
	for item in GM.pc.getInventory().getItemsWithTag(ItemTag.Illegal):
		addMessage(item.getStackName()+" was taken away")
		foundAnything = true
	for item in GM.pc.getInventory().getEquippedItemsWithTag(ItemTag.Illegal):
		addMessage(item.getStackName()+" was taken away")
		foundAnything = true
	return foundAnything

func processTime(seconds: int):
	GM.main.processTime(seconds)

func startNewDay():
	return GM.main.startNewDay()

func setFlag(flagID, value):
	GM.main.setFlag(flagID, value)

func getFlag(flagID, defaultValue = null):
	return GM.main.getFlag(flagID, defaultValue)

func increaseFlag(flagID, addvalue = 1):
	GM.main.increaseFlag(flagID, addvalue)

func setModuleFlag(moduleID, flagID, value):
	GM.main.setModuleFlag(moduleID, flagID, value)

func increaseModuleFlag(moduleID, flagID, addvalue = 1):
	GM.main.increaseModuleFlag(moduleID, flagID, addvalue)

func getModuleFlag(moduleID, flagID, defaultValue = null):
	return GM.main.getModuleFlag(moduleID, flagID, defaultValue)

func resolveCustomCharacterName(_charID):
	return null

func supportsBattleTurns():
	return false

func supportsSexEngine():
	return false

func setLocationName(locationName: String):
	GM.main.setLocationName(locationName)

func aimCamera(roomID: String):
	GM.main.aimCamera(roomID)

func aimCameraAndSetLocName(roomID: String):
	GM.main.aimCameraAndSetLocName(roomID)

func getCharacter(charID: String) -> BaseCharacter:
	return GlobalRegistry.getCharacter(charID)

func getModule(modID: String):
	return GlobalRegistry.getModule(modID)

func getDebugActions():
	return []

func doDebugAction(_id, _args = {}):
	pass

func getSceneCreator():
	var registryCreator = GlobalRegistry.getSceneCreator(sceneID)
	
	if(registryCreator != null && registryCreator != ""):
		return str(registryCreator)
	return null

func playAnimation(theSceneID, theActionID, args = {}):
	if(GM.main != null):
		GM.main.playAnimation(theSceneID, theActionID, args)

func playAnimationForceReset(theSceneID, theActionID, args = {}):
	if(GM.main != null):
		GM.main.playAnimationForceReset(theSceneID, theActionID, args)

func getDevCommentary():
	return null

func markShownDevCommentary():
	showedDeveloperCommentary = true

func hasDevCommentary():
	var devComs = getDevCommentary()
	if(devComs == null || devComs == ""):
		return false
	return true

func shouldShowDevCommentaryIcon():
	if(!OPTIONS.developerCommentaryEnabled()):
		return false
	if(showedDeveloperCommentary):
		return false
	return hasDevCommentary()

func shouldDisplayBigButtons():
	return false

func getSceneCompanions():
	return []

func saveData():
	var data = {}
	data["state"] = state
	data["currentCharactersVariants"] = currentCharactersVariants
	data["sceneTag"] = sceneTag
	data["sceneEndedFlag"] = sceneEndedFlag
	data["sceneEndedArgs"] = sceneEndedArgs
	data["sceneSavedItemsInv"] = sceneSavedItemsInv.saveData()
	data["uniqueSceneID"] = uniqueSceneID
	data["parentSceneUniqueID"] = parentSceneUniqueID
	
	return data

func loadData(data):
	state = SAVE.loadVar(data, "state", "")
	currentCharactersVariants = SAVE.loadVar(data, "currentCharactersVariants", {})
	sceneTag = SAVE.loadVar(data, "sceneTag", "")
	sceneEndedFlag = SAVE.loadVar(data, "sceneEndedFlag", false)
	sceneEndedArgs = SAVE.loadVar(data, "sceneEndedArgs", null)
	updateCharacter()
	sceneSavedItemsInv.loadData(SAVE.loadVar(data, "sceneSavedItemsInv", {}))
	uniqueSceneID = SAVE.loadVar(data, "uniqueSceneID", -1)
	parentSceneUniqueID = SAVE.loadVar(data, "parentSceneUniqueID", -1)
