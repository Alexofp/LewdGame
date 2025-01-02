extends Control
class_name MainScene

onready var gameUI = $GameUI
onready var charactersNode = $Characters
onready var dynamicCharactersNode = $DynamicCharacters
var sceneStack: Array = []
var messages: Array = []
var logMessages: Array = []
var currentDay = 0
var timeOfDay = 6*60*60 # seconds since 00:00
var flags = {}
var flagsCache = null
var moduleFlags = {}
var datapackFlags = {}
var playerScene = preload("res://Player/Player.gd")
var overriddenPlayerScene = preload("res://Player/OverriddenPlayer.gd")
var overridenPC
var originalPC
var roomMemories = {}
var lootedRooms = {}
var rollbacker:Rollbacker
var encounterSettings:EncounterSettings
var currentlyTestingScene = false
var allowExecuteOnce:bool = false
var isDebuggingIS:bool = false

var IS:InteractionSystem = InteractionSystem.new()
var RS:RelationshipSystem = RelationshipSystem.new()
var WHS:WorldHistory = WorldHistory.new()
var SAB:SlaveAuctionBidders = SlaveAuctionBidders.new()

var staticCharacters = {}
var charactersToUpdate = {}
var dynamicCharacters = {}
var dynamicCharactersPools = {}

var loadedDatapacks = {}
var datapackCharacters = {}

signal time_passed(_secondsPassed)
signal saveLoadingFinished

func _init():
	rollbacker = Rollbacker.new()
	flagsCache = Flag.getFlags()
	encounterSettings = EncounterSettings.new()

func overridePC():
	if(overridenPC != null):
		assert(false, "Trying to override player twice!")
		return
	
	Util.remove_all_signals(originalPC)
			
	var newpc = overriddenPlayerScene.new()
	overridenPC = newpc
	GM.pc = newpc
	connectSignalsToPC(newpc)
	add_child(newpc)
	
func clearOverridePC():
	if(overridenPC == null):
		assert(false, "Player wasn't overridden when we are trying to clear it")
		return
	overridenPC.queue_free()
	overridenPC = null
	GM.pc = originalPC
	connectSignalsToPC(originalPC)
	
func getCurrentPC():
	if(overridenPC != null):
		return overridenPC
	return originalPC

func getOriginalPC():
	return originalPC
	
func getOverriddenPC():
	return overridenPC

func connectSignalsToPC(who):
	var _s = who.connect("levelChanged", self, "_on_Player_levelChanged")
	_s = who.connect("orificeBecomeMoreLoose", self, "_on_Player_orificeBecomeMoreLoose")
	_s = who.connect("exchangedCumDuringRubbing", self, "_on_Player_exchangedCumDuringRubbing")
	_s = who.connect("skillLevelChanged", self, "_on_Player_skillLevelChanged")
	_s = who.connect("stat_changed", $GameUI, "_on_Player_stat_changed")
	_s = who.connect("holePainfullyStretched", self, "_on_Player_holePinafullyStretched")
	_s = who.connect("gotWoundedBy", self, "_on_Player_gotWoundedBy")

func _exit_tree():
	GM.main = null
	
func createStaticCharacters():
	Util.delete_children(charactersNode)
	staticCharacters.clear()
	
	var characterClasses = GlobalRegistry.getCharacterClasses()
	for charID in characterClasses:
		var character = characterClasses[charID]
		var characterObject = character.new()
		staticCharacters[characterObject.id] = characterObject
		charactersNode.add_child(characterObject)
	
func updateStaticCharacters():
	for charID in staticCharacters:
		staticCharacters[charID].updateBodyparts()
	
func getCharacter(charID):
	if(charID == "pc"):
		return GM.pc
	if(staticCharacters.has(charID)):
		return staticCharacters[charID]
	if(dynamicCharacters.has(charID)):
		return dynamicCharacters[charID]
	return null

func getCharacters():
	return staticCharacters

func getDynamicCharacters():
	return dynamicCharacters

func addDynamicCharacter(character, printDebug = true):
	if(!(character.isDynamicCharacter())):
		assert(false, "addDynamicCharacter() Received a non-dynamic character")
		
	var newCharID = character.getID()
	if(newCharID == null || newCharID == "" || newCharID == "errorerror"):
		character.id = generateCharacterID()
	
	if(dynamicCharacters.has(newCharID)):
		removeDynamicCharacter(newCharID)
	
	dynamicCharacters[newCharID] = character
	dynamicCharactersNode.add_child(character)
	if(printDebug):
		Log.print("addDynamicCharacter(): Adding "+str(newCharID)+" character "+Util.getStackFunction())
		
func removeDynamicCharacter(characterID, printDebug = true):
	if(!(characterID is String)):
		characterID = characterID.getID()
	
	if(dynamicCharacters.has(characterID)):
		if(printDebug):
			Log.print("removeDynamicCharacter(): Removing "+str(characterID)+" character")
		removeDynamicCharacterFromAllPools(characterID)
		RS.removeAllEntriesOf(characterID)
		IS.deletePawn(characterID)
		
		dynamicCharacters[characterID].queue_free()
		dynamicCharacters.erase(characterID)
	else:
		Log.print("removeDynamicCharacter(): Tried to remove "+str(characterID)+" character but it doesn't exist")

func addDynamicCharacterToPool(characterID, poolID:String):
	if(!(characterID is String)):
		characterID = characterID.getID()
	
	if(!dynamicCharacters.has(characterID)):
		return false
	
	if(!dynamicCharactersPools.has(poolID)):
		dynamicCharactersPools[poolID] = {}
	
	dynamicCharactersPools[poolID][characterID] = true
	return true

func removeDynamicCharacterFromPool(characterID, poolID:String):
	if(!(characterID is String)):
		characterID = characterID.getID()
	
	if(!dynamicCharactersPools.has(poolID)):
		return false
	if(!dynamicCharactersPools[poolID].has(characterID)):
		return false

	dynamicCharactersPools[poolID].erase(characterID)
	return true

func removeDynamicCharacterFromAllPools(characterID):
	if(!(characterID is String)):
		characterID = characterID.getID()
	
	for poolID in dynamicCharactersPools:
		if(dynamicCharactersPools[poolID].has(characterID)):
			dynamicCharactersPools[poolID].erase(characterID)

func getDynamicCharacterIDsFromPool(poolID:String):
	if(!dynamicCharactersPools.has(poolID)):
		return []
	
	return dynamicCharactersPools[poolID].keys()

func getPCSlavesIDs():
	return getDynamicCharacterIDsFromPool(CharacterPool.Slaves)

func getPCSlaveAmount() -> int:
	return getDynamicCharacterIDsFromPool(CharacterPool.Slaves).size()

func getDynamicCharactersPoolSize(poolID:String):
	if(!dynamicCharactersPools.has(poolID)):
		return 0
	
	return dynamicCharactersPools[poolID].size()

func getDynamicCharactersPools():
	return dynamicCharactersPools.keys()

# Called when the node enters the scene tree for the first time.
func _ready():
	GM.main = self
	createStaticCharacters()
	call_deferred("updateStaticCharacters")
	
	var pc = playerScene.new()
	originalPC = pc
	GM.pc = pc
	connectSignalsToPC(pc)
	add_child(pc)
	
	randomize()
	
	WHS.clearHistory()
	startNewGame()
	
	runCurrentScene()
	GM.ui.onTimePassed(0)
	
	Console.addCommand("setflag", self, "consoleSetFlagBool", ["flagID", "trueOrFalse"], "Changes the game flag, be very careful")
	Console.addCommand("clearflag", self, "consoleClearFlag", ["flagID"], "Resets the game flag, be very careful")
	Console.addCommand("setmoduleflag", self, "consoleSetModuleFlagBool", ["moduleID", "flagID", "trueOrFalse"], "Changes the game flag, be very careful")
	Console.addCommand("clearmoduleflag", self, "consoleClearModuleFlag", ["moduleID", "flagID"], "Resets the game flag, be very careful")
	#Console.addCommand("ae", self, "consoleAnimationEditor", [], "Animation editor")
	applyAllWorldEdits()
	
func startNewGame():
	GM.ES.registerDatapackEvents(loadedDatapacks.keys())
	for scene in sceneStack:
		scene.queue_free()
	sceneStack = []
	
	runScene("IntroScene")
	#runScene("FightScene", ["testchar"])
	#runScene("FightScene", ["tavi"])

func getNewUniqueSceneID(blockedIDS=[]) -> int:
	var takenIDs = {}
	for someID in blockedIDS:
		if(someID >= 0):
			takenIDs[someID] = true
	
	for scene in sceneStack:
		if(scene.uniqueSceneID >= 0):
			takenIDs[scene.uniqueSceneID] = true
		if(scene.parentSceneUniqueID >= 0):
			takenIDs[scene.parentSceneUniqueID] = true
	
	var result:int = 0
	while(true):
		if(!takenIDs.has(result)):
			return result
		result += 1
	return result

func runScene(id, _args = [], parentSceneUniqueID = -1):
	var scene = GlobalRegistry.createScene(id)
	assert(scene != null, "SCENE WITH ID "+str(id)+" IS NOT FOUND. MAKE SURE IT WAS REGISTERED INSIDE THE MODULE.")
	scene.uniqueSceneID = getNewUniqueSceneID([parentSceneUniqueID])
	if(parentSceneUniqueID >= 0):
		scene.parentSceneUniqueID = parentSceneUniqueID
	add_child(scene)
	sceneStack.append(scene)
	print("Starting scene "+id)
	
	allowExecuteOnce = true
	scene.initScene(_args)
	#scene.run()
	return scene

func removeScene(scene, args = []):
	if(sceneStack.has(scene)):
		if(true):#scene == sceneStack.back() || true):
			var isCurrentScene = (scene == sceneStack.back())
			#var previousSceneIndex = sceneStack.find(scene) - 1
			var savedParentSceneID = scene.parentSceneUniqueID
			var savedTag = scene.sceneTag
			
			sceneStack.erase(scene)
			
			var parentScene = getSceneByUniqueID(savedParentSceneID)
			if(parentScene != null):
				parentScene.react_scene_end(savedTag, args)
			#else:
				## This is not ideal but it's required to refresh stuff like portraits (not anymore)
				#if(previousSceneIndex < sceneStack.size() && previousSceneIndex >= 0):
				#	sceneStack[previousSceneIndex].react_scene_end(savedTag, args)
			
			if(isCurrentScene && sceneStack.back() != null):
				sceneStack.back().updateCharacter()
				runCurrentScene()
		else:
			sceneStack.erase(scene)
	
	if(sceneStack.size() == 0):
		Log.print("Error: no more scenes in the scenestack")
		gameUI.clearText()
		gameUI.clearButtons()
		gameUI.say("Error: no more scenes in the scenestack. Please let the developer know")
		return

func getSceneByUniqueID(uID):
	if(uID < 0):
		return null
	for scene in sceneStack:
		if(scene.uniqueSceneID == uID):
			return scene
	return null

func getCurrentScene():
	if(sceneStack.size() > 0):
		return sceneStack.back()
	return null

func endCurrentScene(keepWorld:bool=true):
	if(sceneStack.size() == 1 && keepWorld):
		IS.stopInteractionsForPawnID("pc")
		return
	var currentScene = getCurrentScene()
	if(currentScene != null):
		currentScene.endScene()

func clearSceneStack():
	for scene in sceneStack:
		scene.queue_free()
	sceneStack = []

func _on_GameUI_on_option_button(method, args):
	pickOption(method, args)
	
func pickOption(method, args):
	rollbacker.pushRollbackState()
	IS.resetExtraText()
	GM.main.clearMessages()
	GlobalTooltip.resetTooltips()
	
	if(GM.ES.checkButtonInput(method, args)):
		pass
		
	elif(sceneStack.size() > 0):
		sceneStack.back().react(method, args)
		#if(sceneStack.back().react(method, args)):
		#	return

	allowExecuteOnce = true # For 'run code once' code block
	runCurrentScene()
	
func runCurrentScene():
	if(sceneStack.size() > 0):
		sceneStack.back().run()
		
		if(IS.hasExtraText()):
			GM.ui.say(IS.getExtraText())
		
		if(messages.size() > 0):
			GM.ui.trimLineEndings()
			GM.ui.say("\n\n[center][i]"+Util.join(messages, "\n")+"[/i][/center]\n")
		GM.ui.translateText()
	updateStuff()
	allowExecuteOnce = false

func reRun():
	runCurrentScene()

func loadingSavefileFinished():
	charactersToUpdate.clear()
	for charID in getCharacters():
		var character = getCharacter(charID)
		character.checkOldWayOfUpdating(currentDay, timeOfDay)
		if(character.shouldBeUpdated()):
			startUpdatingCharacter(charID)
	for charID in dynamicCharacters:
		var character = getCharacter(charID)
		character.checkOldWayOfUpdating(currentDay, timeOfDay)
		if(character.shouldBeUpdated()):
			startUpdatingCharacter(charID)
	
	GM.ES.registerDatapackEvents(loadedDatapacks.keys())
	
	emit_signal("saveLoadingFinished")
	#if(GM.ui != null):
	#	GM.ui.getStage3d().resetToNothing()
	reRun()
	
	applyAllWorldEdits()
	
	if(!rollbacker.rollbacking):
		WHS.clearHistory()
	IS.updatePCLocation()
	GM.world.updatePawns(IS)
	GM.world.setPawnsShowed(canShowPawns())
	
func applyAllWorldEdits():
	var worldEdits = GlobalRegistry.getWorldEdits()
	for worldEditID in worldEdits:
		var worldEdit = worldEdits[worldEditID]
		worldEdit.apply(GM.world)

func applyWorldEdit(id):
	var worldEdits = GlobalRegistry.getWorldEdits()
	if(worldEdits.has(id)):
		worldEdits[id].apply(GM.world)

func canSave():
	return true

func supportsBattleTurns():
	for scene in sceneStack:
		if(scene.supportsBattleTurns()):
			return true
	
	return false

# Yeah, very hacky. Fight me
func getCurrentFightScene():
	for scene in sceneStack:
		if(scene.sceneID == "FightScene"):
			return scene
	return null

func supportsSexEngine():
	for scene in sceneStack:
		if(scene.supportsSexEngine()):
			return true
	
	return false

func saveData():
	var data = {}
	data["messages"] = messages
	data["timeOfDay"] = timeOfDay
	data["currentDay"] = currentDay
	data["flags"] = flags
	data["moduleFlags"] = moduleFlags
	data["datapackFlags"] = datapackFlags
	data["EventSystem"] = GM.ES.saveData()
	data["ChildSystem"] = GM.CS.saveData()
	data["logMessages"] = logMessages
	data["roomMemories"] = roomMemories
	data["lootedRooms"] = lootedRooms
	data["world"] = GM.world.saveData()
	data["dynamicCharactersPools"] = dynamicCharactersPools
	data["encounterSettings"] = encounterSettings.saveData()
	data["gameExtenders"] = GM.GES.saveData()
	data["loadedDatapacks"] = loadedDatapacks
	data["datapackCharacters"] = datapackCharacters
	data["interactionSystem"] = IS.saveData()
	data["relationshipSystem"] = RS.saveData()
	data["auctionBidders"] = SAB.saveData()
	
	data["scenes"] = []
	for scene in sceneStack:
		var sceneData = {}
		sceneData["id"] = scene.sceneID
		sceneData["sceneData"] = scene.saveData()
		data["scenes"].append(sceneData)
	
	return data

func loadData(data):
	if(SAVE.isUpdatingFromSaveVersion(1)):
		SaveConversion.fixFlagsFromVersion1(self, data)
	
	messages = SAVE.loadVar(data, "messages", [])
	timeOfDay = SAVE.loadVar(data, "timeOfDay", 6*60*60)
	currentDay = SAVE.loadVar(data, "currentDay", 0)
	GM.ui.onTimePassed(0)
	flags = SAVE.loadVar(data, "flags", {})
	moduleFlags = SAVE.loadVar(data, "moduleFlags", {})
	datapackFlags = SAVE.loadVar(data, "datapackFlags", {})
	GM.ES.loadData(SAVE.loadVar(data, "EventSystem", {}))
	GM.CS.loadData(SAVE.loadVar(data, "ChildSystem", {}))
	logMessages = SAVE.loadVar(data, "logMessages", [])
	roomMemories = SAVE.loadVar(data, "roomMemories", {})
	lootedRooms = SAVE.loadVar(data, "lootedRooms", {})
	dynamicCharactersPools = SAVE.loadVar(data, "dynamicCharactersPools", {})
	encounterSettings.loadData(SAVE.loadVar(data, "encounterSettings", {}))
	GM.GES.loadData(SAVE.loadVar(data, "gameExtenders", {}))
	loadedDatapacks = SAVE.loadVar(data, "loadedDatapacks", {})
	datapackCharacters = SAVE.loadVar(data, "datapackCharacters", {})
	IS.loadData(SAVE.loadVar(data, "interactionSystem", {}))
	RS.loadData(SAVE.loadVar(data, "relationshipSystem", {}))
	SAB.loadData(SAVE.loadVar(data, "auctionBidders", {}))
	
	var scenes = SAVE.loadVar(data, "scenes", [])
	
	for scene in sceneStack:
		scene.queue_free()
	sceneStack = []
	
	GM.ui.clearCharactersPanel()
	for sceneData in scenes:
		var id = SAVE.loadVar(sceneData, "id", "error")
		
		var scene = GlobalRegistry.createScene(id)
		add_child(scene)
		sceneStack.append(scene)
		print("Starting scene "+id)
		
		#scene.initScene(_args)
		scene.loadData(SAVE.loadVar(sceneData, "sceneData", {}))
		if(scene.uniqueSceneID < 0):
			scene.uniqueSceneID = getNewUniqueSceneID()
			scene.parentSceneUniqueID = scene.uniqueSceneID - 1 # Preserves compatability with old saves
	
	IS.resetExtraText()
	GM.ui.recreateWorld()
	GM.world.loadData(SAVE.loadVar(data, "world", {}))
	#GM.world.updatePawns(IS)
	#GM.world.setPawnsShowed(canShowPawns())

func saveCharactersData():
	var data = {}
	for characterID in staticCharacters:
		var character = staticCharacters[characterID]
		if(character.disableSerialization):
			continue
		data[characterID] = character.saveData()
	return data
	
func loadCharactersData(data):
	for characterID in staticCharacters:
		var character = staticCharacters[characterID]
		if(character.disableSerialization):
			continue
		character.loadData(SAVE.loadVar(data, characterID, {}))
	
func saveDynamicCharactersData():
	var data = {}
	for characterID in dynamicCharacters:
		var charData = {}
		charData["type"] = "dynamic"
		charData["data"] = dynamicCharacters[characterID].saveData()
		data[characterID] = charData
	return data

func loadDynamicCharactersData(data):
	Util.delete_children(dynamicCharactersNode)
	dynamicCharacters.clear()
	
	for characterID in data:
		var charData = SAVE.loadVar(data, characterID, {})
		var charType = SAVE.loadVar(charData, "type", "error")
		if(charType == "dynamic"):
			var newDynamicChar = DynamicCharacter.new()
			newDynamicChar.id = characterID
			addDynamicCharacter(newDynamicChar, false)
			newDynamicChar.loadData(SAVE.loadVar(charData, "data", {}))
		else:
			Log.printerr("loadDynamicCharactersData() Trying to load a non-dynamic character with id "+str(characterID))
	
func addMessage(text: String):
	messages.append(text)

func getMessages():
	return messages

func clearMessages():
	messages = []

func getTimeCap():
	return 23 * 60 * 60

func isVeryLate():
	return timeOfDay >= getTimeCap()

func stopProcessingUnusedCharacters():
	for charID in charactersToUpdate.keys():
		var character = getCharacter(charID)
		if(character != null):
			character.updateNonBattleEffects()
		if(character == null || !character.shouldBeUpdated()):
			print("STOPPED PROCESSING: "+str(charID))
			charactersToUpdate.erase(charID)
			if(character != null):
				character.onStoppedProcessing()
		elif(character != null && !characterIsVisible(charID)):
			character.updateNonBattleEffects()

func processTime(_seconds):
	_seconds = int(round(_seconds))
	
	timeOfDay += _seconds
	
	doTimeProcess(_seconds)
	stopProcessingUnusedCharacters()

func doTimeProcess(_seconds):
	# This splits long sleeping times into 1 hour chunks
	IS.processTime(_seconds)
	
	var copySeconds = _seconds
	while(copySeconds > 0):
		var clippedSeconds = min(60*60, copySeconds)
		GM.pc.processTime(clippedSeconds)
		
		for characterID in charactersToUpdate:
			var character = getCharacter(characterID)
			if(character != null):
				character.processTime(clippedSeconds)
		
		copySeconds -= clippedSeconds
	
	GM.ui.onTimePassed(_seconds)
	
	var oldHours = int((timeOfDay - _seconds) / 60 / 60)
	var newHours = int(timeOfDay / 60 / 60)
	var hoursPassed = newHours - oldHours

	if(hoursPassed > 0):
		hoursPassed(hoursPassed)
	
	emit_signal("time_passed", _seconds)

func hoursPassed(howMuch):
	GM.pc.hoursPassed(howMuch)
	
	for characterID in charactersToUpdate:
		var character = getCharacter(characterID)
		if(character != null):
			character.hoursPassed(howMuch)
	
	if(dynamicCharactersPools.has(CharacterPool.Slaves)):
		for characterID in dynamicCharactersPools[CharacterPool.Slaves]:
			var character = getCharacter(characterID)
			if(character != null && character.isSlaveToPlayer()):
				character.getNpcSlavery().hoursPassed(howMuch)
	
	RS.decayRelationships(howMuch)

func processTimeUntil(newseconds):
	if(timeOfDay >= newseconds):
		return
	
	var timeDiff = newseconds - timeOfDay
	
	timeOfDay = newseconds
	doTimeProcess(timeDiff)
	return timeDiff
	
func startNewDay():
	IS.beforeNewDay()
	GM.CS.optimize()
	
	# We assume that you always go to sleep at 23:00
	if(timeOfDay > getTimeCap()):
		timeOfDay = getTimeCap()
	
	var newtime = 6 * 60 * 60
	var timediff = 24 * 60 * 60 - timeOfDay + newtime
	
	currentDay += 1
	timeOfDay = newtime
	
	Flag.resetFlagsOnNewDay()
	roomMemoriesProcessDay()
	npcSlaveryOnNewDay()
	
	doTimeProcess(timediff)
	
	WHS.onNewDay()
	IS.afterNewDay()
	
	SAVE.triggerAutosave()
	
	return timediff

func npcSlaveryOnNewDay():
	for slaveID in getDynamicCharacterIDsFromPool(CharacterPool.Slaves):
		var character = getCharacter(slaveID)
		if(character == null):
			continue
		if(character.isSlaveToPlayer()):
			var npcSlave = character.getNpcSlavery()
			npcSlave.onNewDay()

func getVisibleTime():
	var text = ""
	if(isVeryLate()):
		text = "Night time"
	else:
		text = Util.getTimeStringHHMM(timeOfDay)
	
	text += ", day " + str(currentDay)
	return text

func getFormattedTimeFromSeconds(howManySeconds:int):
	return Util.getTimeStringHHMM(howManySeconds)

func getTime():
	return timeOfDay

func getDays():
	return currentDay

func getTimeInGlobalSeconds():
	return int(currentDay * 24 * 60 * 60) + int(timeOfDay)

func setFlag(flagID, value):
	# Handling "ModuleID.FlagID" here
	var splitData = Util.splitOnFirst(flagID, ".")
	if(splitData.size() > 1):
		setModuleFlag(splitData[0], splitData[1], value)
		return
	
	# Handling "DatapackID:FlagID" here
	var splitData2 = Util.splitOnFirst(flagID, ":")
	if(splitData2.size() > 1):
		setDatapackFlag(splitData2[0], splitData2[1], value)
		return
	
	if(!flagsCache.has(flagID)):
		Log.printerr("setFlag(): Detected the usage of an unknown flag: "+str(flagID)+" "+Util.getStackFunction())
		return
	
	if("type" in flagsCache[flagID]):
		var flagType = flagsCache[flagID]["type"]
		if(!FlagType.isCorrectType(flagType, value)):
			Log.printerr("setFlag(): Wrong type for flag "+str(flagID)+". Value: "+str(value)+" "+Util.getStackFunction())
			return
			
	flags[flagID] = value

func hasDatapackFlag(datapackID, flagID):
	if(!loadedDatapacks.has(datapackID)):
		Log.printerr("hasDatapackFlag(): Trying to check a flag "+str(flagID)+" of a datapack that wasn't loaded: "+str(datapackID))
		return
	var datapack:Datapack = GlobalRegistry.getDatapack(datapackID)
	if(datapack == null):
		Log.printerr("hasDatapackFlag(): Datapack "+str(datapackID)+" isn't found "+Util.getStackFunction())
		return
		
	if(!datapack.flags.has(flagID)):
		return false
	return true

func setDatapackFlag(datapackID, flagID, value):
	if(!loadedDatapacks.has(datapackID)):
		Log.printerr("setDatapackFlag(): Trying to set a flag "+str(flagID)+" of a datapack that wasn't loaded: "+str(datapackID))
		return
	
	# Check if value is the right type
	var datapack:Datapack = GlobalRegistry.getDatapack(datapackID)
	if(datapack == null):
		Log.printerr("setDatapackFlag(): Datapack "+str(datapackID)+" isn't found "+Util.getStackFunction())
		return
		
	if(!datapack.flags.has(flagID)):
		Log.printerr("setDatapackFlag(): Datapack is "+str(datapackID)+". Detected the usage of an unknown flag: "+str(flagID)+" "+Util.getStackFunction())
		return
	
	var flagType = datapack.flags[flagID]["type"]
	if(flagType == DatapackSceneVarType.BOOL && !(value is bool)):
		Log.printerr("setDatapackFlag(): Trying to assign a '"+str(value)+"' value to a BOOLEAN flag "+str(flagID))
		return
	if(flagType == DatapackSceneVarType.STRING && !(value is String)):
		Log.printerr("setDatapackFlag(): Trying to assign a '"+str(value)+"' value to a STRING flag "+str(flagID))
		return
	if(flagType == DatapackSceneVarType.NUMBER && !(value is int) && !(value is float)):
		Log.printerr("setDatapackFlag(): Trying to assign a '"+str(value)+"' value to a NUMBER flag "+str(flagID))
		return
		
	if(!datapackFlags.has(datapackID)):
		datapackFlags[datapackID] = {}
	datapackFlags[datapackID][flagID] = value

func clearDatapackFlag(datapackID, flagID):
	if(!datapackFlags.has(datapackID) || !datapackFlags[datapackID].has(flagID)):
		return
	datapackFlags[datapackID].erase(flagID)

func getDatapackFlag(datapackID, flagID, defaultValue = null):
	if(!loadedDatapacks.has(datapackID)):
		Log.printerr("getDatapackFlag(): Datapack "+str(datapackID)+" wasn't loaded "+Util.getStackFunction())
		return defaultValue
	
	var datapack:Datapack = GlobalRegistry.getDatapack(datapackID)
	if(datapack == null):
		Log.printerr("getDatapackFlag(): Datapack "+str(datapackID)+" isn't found "+Util.getStackFunction())
		return defaultValue
	
	if(!datapack.flags.has(flagID)):
		Log.printerr("getDatapackFlag(): Datapack is "+str(datapackID)+". Detected the usage of an unknown flag: "+str(flagID)+" "+Util.getStackFunction())
		return defaultValue
	
	if(!datapackFlags.has(datapackID) || !datapackFlags[datapackID].has(flagID)):
		return datapack.flags[flagID]["default"]
		#return defaultValue
	
	return datapackFlags[datapackID][flagID]

func clearFlag(flagID):
	var splitData = Util.splitOnFirst(flagID, ".")
	if(splitData.size() > 1):
		clearModuleFlag(splitData[0], splitData[1])
		return
	
	var splitData2 = Util.splitOnFirst(flagID, ":")
	if(splitData2.size() > 1):
		clearDatapackFlag(splitData2[0], splitData2[1])
		return
	
	flags.erase(flagID)

func increaseFlag(flagID, addvalue = 1):
	setFlag(flagID, getFlag(flagID, 0) + addvalue)

func hasFlag(flagID:String) -> bool:
	var splitData = Util.splitOnFirst(flagID, ".")
	if(splitData.size() > 1):
		var modules = GlobalRegistry.getModules()
		var moduleID:String = splitData[0]
		if(!modules.has(moduleID)):
			return false
		var module:Module = modules[moduleID]
		var moduleFlagsCache:Dictionary = module.getFlagsCache()
		if(moduleFlagsCache.has(splitData[1])):
			return true
		return false
	
	var splitData2 = Util.splitOnFirst(flagID, ":")
	if(splitData2.size() > 1):
		#return getDatapackFlag(splitData2[0], splitData2[1], defaultValue)
		var datapackID:String = splitData2[0]
		if(!loadedDatapacks.has(datapackID)):
			return false
		
		var datapack:Datapack = GlobalRegistry.getDatapack(datapackID)
		if(datapack == null):
			return false
		if(!datapack.flags.has(splitData2[1])):
			return false
		return true
	
	if(flagsCache.has(flagID)):
		return true
	return false

func getFlag(flagID, defaultValue = null):
	var splitData = Util.splitOnFirst(flagID, ".")
	if(splitData.size() > 1):
		return getModuleFlag(splitData[0], splitData[1], defaultValue)
	
	var splitData2 = Util.splitOnFirst(flagID, ":")
	if(splitData2.size() > 1):
		return getDatapackFlag(splitData2[0], splitData2[1], defaultValue)
	
	if(!flagsCache.has(flagID)):
		Log.printerr("getFlag(): Detected the usage of an unknown flag: "+str(flagID)+" "+Util.getStackFunction())
		return defaultValue
	
	if(!flags.has(flagID)):
		return defaultValue
	
	return flags[flagID]

func setModuleFlag(moduleID, flagID, value):
	var modules = GlobalRegistry.getModules()
	if(!modules.has(moduleID)):
		Log.printerr("getModuleFlag(): Module "+str(moduleID)+" doesn't exist "+Util.getStackFunction())
		return
	
	var module:Module = modules[moduleID]
	var moduleFlagsCache = module.getFlagsCache()
	
	if(!moduleFlagsCache.has(flagID)):
		Log.printerr("setModuleFlag(): Module is "+str(moduleID)+". Detected the usage of an unknown flag: "+str(flagID)+" "+Util.getStackFunction())
		return
	
	if("type" in moduleFlagsCache[flagID]):
		var flagType = moduleFlagsCache[flagID]["type"]
		if(!FlagType.isCorrectType(flagType, value)):
			Log.printerr("setModuleFlag(): Module is "+str(moduleID)+". Wrong type for flag "+str(flagID)+". Value: "+str(value)+" "+Util.getStackFunction())
			return
	
	if(!moduleFlags.has(moduleID)):
		moduleFlags[moduleID] = {}
	moduleFlags[moduleID][flagID] = value
	

func increaseModuleFlag(moduleID, flagID, addvalue = 1):
	setModuleFlag(moduleID, flagID, getModuleFlag(moduleID, flagID, 0) + addvalue)

func getModuleFlag(moduleID, flagID, defaultValue = null):
	var modules = GlobalRegistry.getModules()
	if(!modules.has(moduleID)):
		Log.printerr("getModuleFlag(): Module "+str(moduleID)+" doesn't exist "+Util.getStackFunction())
		return defaultValue
	
	var module:Module = modules[moduleID]
	var moduleFlagsCache = module.getFlagsCache()
	
	if(!moduleFlagsCache.has(flagID)):
		Log.printerr("getModuleFlag(): Module is "+str(moduleID)+". Detected the usage of an unknown flag: "+str(flagID)+" "+Util.getStackFunction())
		return defaultValue
	
	if(!moduleFlags.has(moduleID) || !moduleFlags[moduleID].has(flagID)):
		return defaultValue
	
	return moduleFlags[moduleID][flagID]

func clearModuleFlag(moduleID, flagID):
	if(!moduleFlags.has(moduleID) || !moduleFlags[moduleID].has(flagID)):
		return
	moduleFlags[moduleID].erase(flagID)

func resolveCustomCharacterName(charID):
	if(sceneStack.size() > 0):
		return sceneStack.back().resolveCustomCharacterName(charID)
	return null

func updateStuff():
	if(GM.pc == null):
		return
	
	var playerIsBlindfolded = GM.pc.isBlindfolded()
	GM.world.setDarknessVisible(playerIsBlindfolded)
	if(playerIsBlindfolded):
		if(GM.pc.canHandleBlindness()):
			GM.world.setDarknessSize(64)
		else:
			GM.world.setDarknessSize(16)
			
	for worldEdit in GlobalRegistry.getRegularWorldEdits():
		worldEdit.apply(GM.world)
	
	GM.world.updatePawns(IS)
	GM.world.setPawnsShowed(canShowPawns())


func _on_Player_levelChanged():
	if(GM.ui):
		GM.ui.makeSkillsButtonFlash()
		addMessage("You reached a new level!")


func _on_Player_skillLevelChanged(_skillID):
	if(GM.ui):
		if(GM.pc.getSkillsHolder().canUnlockAnyPerkInSkill(_skillID)):
			GM.ui.makeSkillsButtonFlash()
		
		var skill: SkillBase = GM.pc.getSkillsHolder().getSkill(_skillID)
		
		addMessage("Your '"+skill.getVisibleName()+"' skill has increased to level "+str(skill.getLevel())+"!")
		

func _on_Player_orificeBecomeMoreLoose(orificeName, _newvalue, _oldvalue):
	addMessage("Your "+orificeName+" is stretched and is now more used to the insertions")

func _on_Player_exchangedCumDuringRubbing(senderName, receiverName):
	addMessage(receiverName + " stole some cum from "+senderName+" during tribbing")

func _on_Player_holePinafullyStretched(bodypart, _who):
	if(bodypart == BodypartSlot.Vagina):
		addMessage("OW! Your pussy [b]hurts[/b]..")
	if(bodypart == BodypartSlot.Anus):
		addMessage("OW! Your anus [b]hurts[/b]..")
	callPainWebhook(bodypart)

func callPainWebhook(bodypart):
	var jsonStr = ""
	if(OPTIONS.getWebhookPainEnabled()):
		jsonStr= '{"action": "painstretch","bodypart": "' + str(bodypart) + '"}'
		$HTTPRequest.request(OPTIONS.getWebhookURL(), ["Content-Type: application/json"], true, HTTPClient.METHOD_POST , jsonStr)

func _on_Player_gotWoundedBy(_who):
	addMessage("OW! That [b]really[/b] hurt..")

func getRandomSceneFor(sceneType):
	var resultScenes = []
	
	var modules = GlobalRegistry.getModules()
	for moduleID in modules:
		var module : Module = modules[moduleID]
		
		var moduleScenes = module.getRandomSceneFor(sceneType)
		if(moduleScenes == null || !(moduleScenes is Array)):
			continue
		if(moduleScenes.size() > 0 && !(moduleScenes[0] is Array)):
			Log.printerr("Module "+str(moduleID)+" returns bad getRandomSceneFor() data")
			continue
		resultScenes.append_array(moduleScenes)
	
	return RNG.pickWeightedPairs(resultScenes)

func addLogMessage(title: String, message: String):
	logMessages.append({
		"title": title,
		"message": message,
	})

func showLog():
	if(logMessages.size() > 0):
		var scene = runScene("MessagesLogScene", [])
		scene.sceneTag = "messageslog"
		return true
	return false

func getLogMessages():
	return logMessages

func clearLog():
	logMessages.clear()

func playAnimation(sceneID, actionID, args = {}):
	if(GM.ui != null):
		GM.ui.getStage3d().play(sceneID, actionID, args)

func playAnimationForceReset(sceneID, actionID, args = {}):
	if(GM.ui != null):
		GM.ui.getStage3d().play(sceneID, actionID, args, false, true)

func updateSubAnims():
	if(GM.ui != null):
		GM.ui.getStage3d().updateSubAnims()

func addRoomMemory(roomID, text, days):
	roomMemories[roomID] = {
		"text": text,
		"days": days,
	}
	
func addRoomMemoryCurrentLoc(text, days):
	if(GM.pc == null):
		return
	addRoomMemory(GM.pc.getLocation(), text, days)

func getRoomMemory(roomID):
	if(!roomMemories.has(roomID)):
		return null
	return roomMemories[roomID]["text"]

func roomMemoriesProcessDay():
	for roomID in roomMemories.keys():
		var data = roomMemories[roomID]
		data["days"] -= 1
		
		if(data["days"] <= 0):
			roomMemories.erase(roomID)

func getDebugActions():
	return [
		{
			"id": "giveItem",
			"name": "Give player item",
			"args": [
				{
					"id": "itemID",
					"name": "Item id",
					"type": "smartlist",
					"item": true,
				},
				{
					"id": "amount",
					"name": "Amount",
					"type": "number",
					"value": 1,
					"onlyPositive": true,
				},
			]
		},
		{
			"id": "addPain",
			"name": "Add pain PC",
			"args": [
				{
					"id": "amount",
					"name": "Amount",
					"type": "number",
					"value": 10,
				},
			]
		},
		{
			"id": "addLust",
			"name": "Add lust PC",
			"args": [
				{
					"id": "amount",
					"name": "Amount",
					"type": "number",
					"value": 10,
				},
			]
		},
		{
			"id": "addStamina",
			"name": "Add stamina PC",
			"args": [
				{
					"id": "amount",
					"name": "Amount",
					"type": "number",
					"value": 100,
				},
			]
		},
		{
			"id": "addCredits",
			"name": "Add Credits PC",
			"args": [
				{
					"id": "amount",
					"name": "Amount",
					"type": "number",
					"value": 10,
				},
			]
		},
		{
			"id": "healPC",
			"name": "Heal PC",
			"args": [
			]
		},
		{
			"id": "addExp",
			"name": "Add experience PC",
			"args": [
				{
					"id": "amount",
					"name": "Amount",
					"type": "number",
					"value": 100,
				},
			]
		},
		{
			"id": "addSkillExp",
			"name": "Add skill exp. PC",
			"args": [
				{
					"id": "skillID",
					"name": "Skill",
					"type": "list",
					"skill": true,
				},
				{
					"id": "amount",
					"name": "Amount",
					"type": "number",
					"value": 100,
				},
			]
		},
		{
			"id": "lactatePC",
			"name": "Make PC lactate",
			"args": [
			]
		},
		{
			"id": "resetPCPerks",
			"name": "Reset picked perks",
		},	
		{
			"id": "resetPCStats",
			"name": "Reset picked stats",
		},
		{
			"id": "characterCreator",
			"name": "Open character creator",
		},
		{
			"id": "runScene",
			"name": "Run scene",
			"args": [
				{
					"id": "sceneID",
					"name": "Scene ID",
					"type": "string",
					"value": "",
				},
			]
		},
		{
			"id": "removePCRestraints",
			"name": "Remove all restraints",
		},
		{
			"id": "openConsole",
			"name": "Open console",
		},
		{
			"id": "animBrowser",
			"name": "Animation browser",
		},
		{
			"id": "skinEditor",
			"name": "Skin editor",
			"args": [
				{
					"id": "npcID",
					"name": "NPC ID",
					"value": "pc",
					"type": "smartlist",
					"npc": true,
				},
				{
					"id": "cnpcID",
					"name": "Custom ID",
					"value": "",
					"type": "string",
				},
			]
		},
		{
			"id": "enslaveRandom",
			"name": "Enslave random npc",
		},
		{
			"id": "duplicateAndEnslave",
			"name": "Duplicate and enslave static npc",
			"args": [
				{
					"id": "npcID",
					"name": "NPC ID",
					"value": "pc",
					"type": "smartlist",
					"npc": true,
				},
#				{
#					"id": "cnpcID",
#					"name": "Custom ID",
#					"value": "",
#					"type": "string",
#				},
				{
					"id": "pooltype",
					"name": "Character pool",
					"type": "list",
					"value": "inmate",
					"values": [
						["inmate", "Inmate (gen)"],
						["inmatehigh", "Inmate (highsec)"],
						["inmatesex", "Inmate (sexdeviant)"],
						["guard", "Guard"],
						["engineer", "Engineer"],
						["nurse", "Nurse"],
					],
				},
				{
					"id": "resequip",
					"name": "Reset equipment",
					"value": true,
					"type": "checkbox",
				},
				{
					"id": "pcpers",
					"name": "Copy player's personality",
					"value": true,
					"type": "checkbox",
				},
				{
					"id": "pcfetish",
					"name": "Copy player's fetishes",
					"value": true,
					"type": "checkbox",
				},
			]
		},
		{
			"id": "damageClothes",
			"name": "Damage pc clothes",
		},
		{
			"id": "repairClothes",
			"name": "Repair pc clothes",
		},
		{
			"id": "forceSmartlock",
			"name": "Force smart lock",
		},
		{
			"id": "spyRandom",
			"name": "Spy on pawn",
		},
		{
			"id": "addRep",
			"name": "Add reputation",
			"args": [
				{
					"id": "rep",
					"name": "Rep",
					"type": "list",
					"value": RepStat.Whore,
					"values": RepStat.getAllWithNames(),
				},
				{
					"id": "amount",
					"name": "How much (rep score)",
					"type": "number",
					"value": 1.0,
					"float": true,
				},
			],
		},
		{
			"id": "setRep",
			"name": "Set reputation",
			"args": [
				{
					"id": "rep",
					"name": "Rep",
					"type": "list",
					"value": RepStat.Whore,
					"values": RepStat.getAllWithNames(),
				},
				{
					"id": "level",
					"name": "Level",
					"type": "number",
					"value": 0,
				},
			],
		},
		{
			"id": "toggleISDebug",
			"name": "Toggle IS debug",
		},
	]

func doDebugAction(id, args = {}):
	print(id, " ", args)
	
	if(id == "toggleISDebug"):
		isDebuggingIS = !isDebuggingIS
		if(isDebuggingIS):
			addMessage("Interaction System debug info is now Enabled")
		else:
			addMessage("Interaction System debug info is now Disabled")
	
	if(id == "addRep"):
		GM.pc.getReputation().addRep(args["rep"], args["amount"])
	
	if(id == "setRep"):
		GM.pc.getReputation().setLevel(args["rep"], args["level"])
	
	if(id == "forceSmartlock"):
		if(GM.main.dynamicCharacters.size() == 0):
			return
		var tryAmount = 100
		while(tryAmount > 0):
			var itemID = RNG.pick(GlobalRegistry.getItemIDsByTag(ItemTag.BDSMRestraint))
			var anItem:ItemBase = GlobalRegistry.createItem(itemID)
			if(anItem.hasTag(ItemTag.ImaginaryRestraint) || anItem.getClothingSlot() == null || anItem.getClothingSlot() in [InventorySlot.Static1, InventorySlot.Static2, InventorySlot.Static3] || anItem.hasTag(ItemTag.AllowsEnslaving) || anItem.hasTag(ItemTag.PortalPanties) || (anItem.restraintData != null && (anItem.restraintData is RestraintUnremovable))):
				tryAmount -= 1
				continue
			if(GM.pc.getInventory().hasSlotEquipped(anItem.getClothingSlot())):
				tryAmount -= 5
				continue
			
			GM.pc.getInventory().forceEquipStoreOtherUnlessRestraint(anItem)
			anItem.addRandomSmartLock(RNG.pick(GM.main.dynamicCharacters))
			break
			
		
	if(id == "damageClothes"):
		GM.pc.damageClothes()
	if(id == "repairClothes"):
		GM.pc.repairAllClothes()
	
	if(id == "healPC"):
		GM.pc.addPain(-GM.pc.painThreshold())
		GM.pc.addLust(-GM.pc.lustThreshold())
		GM.pc.addStamina(GM.pc.getMaxStamina())
		
		#for itemID in GlobalRegistry.getItemRefs():
		#	var newItem = GlobalRegistry.createItem(itemID)
		#	GM.pc.getInventory().addItem(newItem)
	
	if(id == "addPain"):
		GM.pc.addPain(args["amount"])
	
	if(id == "addLust"):
		GM.pc.addLust(args["amount"])
		
	if(id == "addStamina"):
		GM.pc.addStamina(args["amount"])
		
	if(id == "addCredits"):
		GM.pc.addCredits(args["amount"])
	
	if(id == "addExp"):
		GM.pc.addExperience(args["amount"])
	
	if(id == "addSkillExp"):
		GM.pc.addSkillExperience(args["skillID"], args["amount"])
	
	if(id == "resetPCPerks"):
		GM.pc.getSkillsHolder().resetPickedPerks()
	
	if(id == "resetPCStats"):
		GM.pc.getSkillsHolder().resetStats()
	
	if(id == "characterCreator"):
		runScene("CharacterCreatorScene", [true])
	
	if(id == "runScene"):
		runScene(args["sceneID"])
	
	if(id == "removePCRestraints"):
		GM.pc.removeAllRestraints()
	
	if(id == "giveItem"):
		if(!args.has("itemID") || args["itemID"] == null):
			return
		
		var item:ItemBase = GlobalRegistry.createItem(args["itemID"])
		if(item.canCombine()):
			item.setAmount(args["amount"]) 
			GM.pc.getInventory().addItem(item)
			Log.print("Item "+item.getStackName()+" added to player")
		else:
			GM.pc.getInventory().addItem(item)
			args["amount"] -= 1
			while(args["amount"] > 0):
				item = GlobalRegistry.createItem(args["itemID"])
				GM.pc.getInventory().addItem(item)
				args["amount"] -= 1
			Log.print("Item "+item.getStackName()+" added to player")
		
	if(id == "openConsole"):
		Console.toggleConsole()
	
	if(id == "animBrowser"):
		runScene("SimpleAnimPlayerScene")

	if(id == "skinEditor"):
		if(args["cnpcID"] != ""):
			runScene("ChangeSkinScene", [args["cnpcID"], true])
		else:
			runScene("ChangeSkinScene", [args["npcID"], true])
			
	if(id == "lactatePC"):
		GM.pc.induceLactation()
		GM.pc.getBodypart(BodypartSlot.Breasts).getFluidProduction().fillPercent(1.0)
		
	if(id == "enslaveRandom"):
		var npcID = NpcFinder.grabNpcIDFromPoolOrGenerate(CharacterPool.Inmates, [], InmateGenerator.new(), {})
		GlobalRegistry.getModule("NpcSlaveryModule").makeSurePCHasSlaveSpace()
		runScene("KidnapDynamicNpcScene", [npcID])
		# runScene("EnslaveDynamicNpcScene", [npcID])
		
	if(id == "spyRandom"):
		runScene("SpyOnPawnScene")
		
	if(id == "duplicateAndEnslave"):
		var theNpcID = args["npcID"]
		#if(args["cnpcID"] != ""):
		#	theNpcID = args["cnpcID"]
		
		var otherChar = getCharacter(theNpcID)
		if(otherChar == null):
			return
			
		var dynamicCharacter = DynamicCharacter.new()
		dynamicCharacter.id = GM.main.generateCharacterID("staticcopy")
		
		GM.main.addDynamicCharacter(dynamicCharacter)
		dynamicCharacter.copyEverythingFrom(otherChar)
		var poolType = args["pooltype"]
		if(poolType in ["inmate", "inmatehigh", "inmatesex"]):
			dynamicCharacter.npcCharacterType = CharacterType.Inmate
			addDynamicCharacterToPool(dynamicCharacter.getID(), CharacterPool.Inmates)
		elif(poolType == "guard"):
			dynamicCharacter.npcCharacterType = CharacterType.Guard
			addDynamicCharacterToPool(dynamicCharacter.getID(), CharacterPool.Guards)
		elif(poolType == "nurse"):
			dynamicCharacter.npcCharacterType = CharacterType.Nurse
			addDynamicCharacterToPool(dynamicCharacter.getID(), CharacterPool.Nurses)
		elif(poolType == "engineer"):
			dynamicCharacter.npcCharacterType = CharacterType.Engineer
			addDynamicCharacterToPool(dynamicCharacter.getID(), CharacterPool.Engineers)
		
		if(args["resequip"]):
			dynamicCharacter.getInventory().clear()
			if(poolType == "inmate"):
				dynamicCharacter.npcDefaultEquipment = ["inmatecollar", "inmateuniform"]
			if(poolType == "inmatehigh"):
				dynamicCharacter.npcDefaultEquipment = ["inmatecollar", "inmateuniformHighsec"]
			if(poolType == "inmatesex"):
				dynamicCharacter.npcDefaultEquipment = ["inmatecollar", "inmateuniformSexDeviant"]
			if(poolType == "guard"):
				dynamicCharacter.npcDefaultEquipment = ["oldcollar", "GuardArmor"]
			if(poolType == "nurse"):
				dynamicCharacter.npcDefaultEquipment = ["oldcollar", "NurseClothes"]
			if(poolType == "engineer"):
				dynamicCharacter.npcDefaultEquipment = ["oldcollar", "EngineerClothes"]
			
			dynamicCharacter.resetEquipment()
		else:
			if(!dynamicCharacter.getInventory().hasEquippedItemWithTag(ItemTag.AllowsEnslaving)):
				dynamicCharacter.getInventory().forceEquipRemoveOther(GlobalRegistry.createItem("oldcollar"))
		
		if(args.has("pcpers") && args["pcpers"]):
			dynamicCharacter.getPersonality().loadData(GM.pc.getPersonality().saveData().duplicate(true))
		if(args.has("pcfetish") && args["pcfetish"]):
			dynamicCharacter.getFetishHolder().loadData(GM.pc.getFetishHolder().saveData().duplicate(true))
			dynamicCharacter.getFetishHolder().removeImpossibleFetishes()
		#var npcID = NpcFinder.grabNpcIDFromPoolOrGenerate(CharacterPool.Inmates, [], InmateGenerator.new(), {})
		GlobalRegistry.getModule("NpcSlaveryModule").makeSurePCHasSlaveSpace()
		runScene("KidnapDynamicNpcScene", [dynamicCharacter.getID()])
		# runScene("EnslaveDynamicNpcScene", [npcID])
		
func consoleSetFlagBool(flagID, valuestr):
	var value = false
	if(valuestr in ["true", "TRUE", "True", "1"]):
		value = true
	elif(valuestr in ["false", "FALSE", "False", "0"]):
		value = false
	else:
		Console.printLine("Accept values are true or false")
		return
		
	setFlag(flagID, value)
	Console.printLine("Flag set")

func consoleSetModuleFlagBool(moduleID, flagID, valuestr):
	var value = false
	if(valuestr in ["true", "TRUE", "True", "1"]):
		value = true
	elif(valuestr in ["false", "FALSE", "False", "0"]):
		value = false
	else:
		Console.printLine("Accept values are true or false")
		return
		
	setModuleFlag(moduleID, flagID, value)
	Console.printLine("Flag set")

func consoleClearFlag(flagID):
	clearFlag(flagID)
	Console.printLine("Flag cleared")
	
func consoleClearModuleFlag(moduleID, flagID):
	clearModuleFlag(moduleID, flagID)
	Console.printLine("Flag cleared")

func _on_GameUI_on_rollback_button():
	rollbacker.rollback()

func characterIsVisible(charID):
	if(charID == "pc"):
		return true
	
	for scene in sceneStack:
		if(scene.hasCharacter(charID)):
			return true
	
	return false

func updateCharacterUntilNow(charID):
	var character = getCharacter(charID)
	if(character != null):
		character.processUntilTime(currentDay, timeOfDay)
		character.updateNonBattleEffects()

func startUpdatingCharacter(charID):
	if(!charactersToUpdate.has(charID)):
		charactersToUpdate[charID] = true
		print("BEGAN PROCESSING "+str(charID))
		var character = getCharacter(charID)
		if(character != null):
			character.processUntilTime(currentDay, timeOfDay)
			character.updateNonBattleEffects()
	else:
		var character = getCharacter(charID)
		if(character != null):
			character.updateNonBattleEffects()

func generateCharacterID(beginPart = "dynamicnpc"):
	var numID = GlobalRegistry.generateNPCUniqueID()
	return beginPart+str(numID)

func getEncounterSettings() -> EncounterSettings:
	return encounterSettings

func canLootRoom(roomID):
	var room = GM.world.getRoomByID(roomID)
	if(room == null):
		return false
	
	if(!room.lootable):
		return false
	
	if(isRoomLooted(roomID)):
		if(room.lootEveryXDays > 0 && getDays() >= (lootedRooms[roomID] + room.lootEveryXDays)):
			return true
		
		return false
	return true

func markRoomAsLooted(roomID):
	lootedRooms[roomID] = getDays()

func isRoomLooted(roomID):
	if(lootedRooms.has(roomID)):
		return true
	return false

#func consoleAnimationEditor():
#	playAnimation(StageScene.SoloEditable, "stand")

func setIsTestingScene(newtest):
	currentlyTestingScene = newtest

func isTestingScene():
	return currentlyTestingScene

func _on_GameUI_onDevComButton():
	if(GM.ui.isShowingDevCommentary()):
		GM.ui.showGameScreen()
		return
	if(!OPTIONS.developerCommentaryEnabled()):
		return
	if(getCurrentScene() == null):
		return
	var devCommentary = getCurrentScene().getDevCommentary()
	getCurrentScene().markShownDevCommentary()
	if(devCommentary == null || devCommentary == ""):
		return
	GM.ui.showDevCommentary(devCommentary)

func setLocationName(locationName: String):
	if(GM.pc.isBlindfolded()):
		locationName = "???"
	
	GM.ui.setLocationName(locationName)

func aimCamera(roomID: String):
	GM.world.aimCamera(roomID)

func aimCameraAndSetLocName(roomID: String):
	GM.world.aimCamera(roomID)
	
	var room = GM.world.getRoomByID(roomID)
	if(!room):
		return
	setLocationName(room.getName())

func playerHasCompanions():
	for scene in sceneStack:
		var sceneComps = scene.getSceneCompanions()
		if(sceneComps != null && sceneComps.size() > 0):
			return true
	return false

func playerHasCompanion(charID):
	for scene in sceneStack:
		var sceneComps = scene.getSceneCompanions()
		if(sceneComps != null && sceneComps.has(charID)):
			return true
	return false

func loadDatapack(datapackID):
	var theDatapack:Datapack = GlobalRegistry.getDatapack(datapackID)
	
	if(theDatapack == null):
		Log.printerr("Trying to load a datapack that doesn't exist in the global registry: "+str(datapackID))
		return false
	
	if(loadedDatapacks.has(datapackID)):
		Log.printerr("Trying to load a datapack that was already loaded: "+str(datapackID))
		return false
	
	loadedDatapacks[datapackID] = true
	datapackCharacters[datapackID] = {}
	
	var newCharacters = theDatapack.characters
	
	for charID in newCharacters:
		addDatapackCharacter(theDatapack, newCharacters[charID])
	
	GM.ES.registerDatapackEvents(loadedDatapacks.keys())
	
	return true

func loadDatapackAndDependencies(datapackID, checked={}):
	if(checked.has(datapackID)): # Recursion protection
		return
	checked[datapackID] = true
	
	var theDatapack:Datapack = GlobalRegistry.getDatapack(datapackID)
	
	if(theDatapack == null):
		Log.printerr("Trying to load a datapack that doesn't exist in the global registry: "+str(datapackID))
		return
	
	var requiredDatapacks = theDatapack.requiredDatapacks
	for otherDatapackID in requiredDatapacks:
		loadDatapackAndDependencies(otherDatapackID, checked)
		
	if(loadedDatapacks.has(datapackID)):
		return
		
	if(!theDatapack.needsTogglingOn()):
		return
		
	loadDatapack(datapackID)

func addDatapackCharacter(theDatapack:Datapack, datapackChar:DatapackCharacter):
	var charID = datapackChar.id
	var datapackID = theDatapack.id
	var finalID = theDatapack.getFinalCharacterID(charID)#theDatapack.id+":"+charID
	
	if(!datapackCharacters.has(datapackID)):
		datapackCharacters[datapackID] = {}
	datapackCharacters[datapackID][finalID] = true
	
	var dynamicCharacter = DynamicCharacter.new()
	dynamicCharacter.id = finalID
	
	addDynamicCharacter(dynamicCharacter)
	
	dynamicCharacter.loadFromDatapackCharacter(theDatapack, datapackChar)
	
	var theCharType = dynamicCharacter.getCharacterType()
	if(theCharType == CharacterType.Inmate):
		addDynamicCharacterToPool(finalID, CharacterPool.Inmates)
	elif(theCharType == CharacterType.Guard):
		addDynamicCharacterToPool(finalID, CharacterPool.Guards)
	elif(theCharType == CharacterType.Nurse):
		addDynamicCharacterToPool(finalID, CharacterPool.Nurses)
	elif(theCharType == CharacterType.Engineer):
		addDynamicCharacterToPool(finalID, CharacterPool.Engineers)

func unloadDatapack(datapackID):
	if(!loadedDatapacks.has(datapackID)):
		Log.printerr("Trying to unload a datapack that was never loaded: "+str(datapackID))
		return false
	
	if(datapackCharacters.has(datapackID)):
		var charsToRemove = datapackCharacters[datapackID].keys()
		
		for idToRemove in charsToRemove:
			removeDynamicCharacter(idToRemove)
	
		datapackCharacters.erase(datapackID)
	
	loadedDatapacks.erase(datapackID)
	GM.ES.registerDatapackEvents(loadedDatapacks.keys())
	return true

func reloadDatapack(datapackID):
	if(!loadedDatapacks.has(datapackID)):
		Log.printerr("Trying to reload a datapack that was never loaded: "+str(datapackID))
		return false
	
	var theDatapack:Datapack = GlobalRegistry.getDatapack(datapackID)
	if(theDatapack == null):
		Log.printerr("Trying to reload a datapack that doesn't exist in the global registry: "+str(datapackID))
		return false
	
	for charID in theDatapack.characters:
		var finalID = theDatapack.getFinalCharacterID(charID)
		
		if(dynamicCharacters.has(finalID)):
			dynamicCharacters[finalID].loadFromDatapackCharacter(theDatapack, theDatapack.characters[charID], true)
		else:
			addDatapackCharacter(theDatapack, theDatapack.characters[charID])
	
	return true
			

func clearDatapackFlags(datapackID):
	if(datapackFlags.has(datapackID)):
		datapackFlags.erase(datapackID)

func isDatapackLoaded(datapackID):
	return loadedDatapacks.has(datapackID)

func getLoadedDatapacks():
	return loadedDatapacks

func isDatapackCharacter(charID):
	for datapackID in datapackCharacters:
		if(datapackCharacters[datapackID].has(charID)):
			return true
	return false

func shouldExecuteOnceCodeblocksRun() -> bool:
	return allowExecuteOnce

func isPawnIDBeingSpied(_charID:String):
	for scene in sceneStack:
		if(scene.isSpyingOnInteractionsWith(_charID)):
			return true
	return false

func playerCanBeInterrupted() -> bool:
	return sceneStack.size() == 1

func canShowPawns() -> bool:
	for scene in sceneStack:
		if(!scene.supportsShowingPawns()):
			return false
	return true
