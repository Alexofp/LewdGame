extends Node

var myProjectSettings

var enabledContent = {}
const optionsFilepath = "user://options.json"
var fetchNewRelease = true
# Pregnancy options
var menstrualCycleLengthDays: int
var eggCellLifespanHours: int
var playerPregnancyTimeDays: int
var npcPregnancyTimeDays: int
var impregnationChanceModifier: int
var bellySizeDependsOnLitterSize: bool = false
var bellyMaxSizeModifier: float = 1.0
var optimizeChilds:bool = true
var maxKeepPCKids:int = 50
var maxKeepNPCKids:int = 30

# Sandbox options
var sandboxPawnCount:int = 30
var sandboxBreeding:String = "rare" # normal reduced rare veryrare never
var sandboxNpcLeveling:float = 1.0

# Difficulty options
var hardStruggleEnabled: bool = false
var smartLockRarity: String = "normal" # never veryrare rare normal often veryoften bdsmslut always
var overstimulationEnabled: bool = true

var shouldScaleUI: bool = true
var uiScaleMultiplier = 1.0
var requireDoubleTapOnMobile = false
var uiButtonSize:int = 0

var showSpeakerName = true
var fontSize = "normal"
var showShortcuts = true
var showSceneCreator = true
var inventoryIconsSize = "small"

var measurementUnits = "metric"

var debugPanel = false
var showMapArt = false
var developerCommentary = false

var showCharacterArt = true
var showSceneArt = true
var imagePackOrder = []

var rollbackEnabled = false
var rollbackSlots = 5
var rollbackSaveEvery = 1

var showModdedLauncher = false

var jigglePhysicsBreastsEnabled = true
var jigglePhysicsBellyEnabled = true
var jigglePhysicsButtEnabled = true
var jigglePhysicsGlobalModifier = 1.0

var advancedShadersEnabled = true
var chainsEnabled = true
var cumEnabled = true
var cumDependsOnBallsSize = true
var cumIntensityMult = 1.0

var autosaveEnabled = true

var genderNamesOverrides = {}
var webhookURL = "https://webhook.xtoys.app/abcrandomidentifier"
var webhookStatsEnabled = false
var webhookPainEnabled = false

func resetToDefaults():
	fetchNewRelease = true
	menstrualCycleLengthDays = 7
	eggCellLifespanHours = 48
	playerPregnancyTimeDays = 5
	npcPregnancyTimeDays = 5
	bellySizeDependsOnLitterSize = false
	impregnationChanceModifier = 100
	bellyMaxSizeModifier = 1.0
	optimizeChilds = true
	maxKeepPCKids = 50
	maxKeepNPCKids = 30
	hardStruggleEnabled = false
	smartLockRarity = "normal"
	overstimulationEnabled = true
	shouldScaleUI = true
	uiScaleMultiplier = 1.0
	showSpeakerName = true
	fontSize = "normal"
	showShortcuts = true
	measurementUnits = "metric"
	requireDoubleTapOnMobile = false
	uiButtonSize = 0
	debugPanel = false
	showMapArt = false
	#imagePackOrder = []
	showCharacterArt = true
	showSceneArt = true
	showSceneCreator = true
	rollbackEnabled = false
	rollbackSlots = 5
	rollbackSaveEvery = 1
	showModdedLauncher = false
	developerCommentary = false
	jigglePhysicsBreastsEnabled = true
	jigglePhysicsBellyEnabled = true
	jigglePhysicsButtEnabled = true
	jigglePhysicsGlobalModifier = 1.0
	advancedShadersEnabled = true
	chainsEnabled = true
	autosaveEnabled = true
	inventoryIconsSize = "small"
	genderNamesOverrides = {}
	sandboxPawnCount = 30
	sandboxBreeding = "rare"
	sandboxNpcLeveling = 1.0
	
	enabledContent.clear()
	for contentType in ContentType.getAll():
		enabledContent[contentType] = !ContentType.isDisabledByDefault(contentType)
		
	call_deferred("applySettingsEffect")

func _init():
	myProjectSettings = load("res://Game/Options/MyProjectSettings.gd").new()
	myProjectSettings.save()

	resetToDefaults()
	
	loadFromFile()

func getGenderOverrideName(theGender, defaultValue):
	if(!genderNamesOverrides.has(theGender) || genderNamesOverrides[theGender] == ""):
		return defaultValue
	return genderNamesOverrides[theGender]

func isContentEnabled(contentType):
	if(!enabledContent.has(contentType)):
		return !ContentType.isDisabledByDefault(contentType)
	
	return enabledContent[contentType]

func shouldFetchGithubRelease():
	return fetchNewRelease

func getMenstrualCycleLengthDays():
	return menstrualCycleLengthDays

func getEggCellLifespanHours():
	return eggCellLifespanHours
	
func getPlayerPregnancyTimeDays():
	return playerPregnancyTimeDays
	
func getNPCPregnancyTimeDays():
	return npcPregnancyTimeDays

func getImpregnationChanceModifier() -> float:
	var resultValue:float = float(impregnationChanceModifier) / 100.0
	resultValue = clamp(resultValue, 0.0, 1000.0)
	return resultValue

func getBellyMaxSizeDependsOnLitterSize() -> bool:
	return bellySizeDependsOnLitterSize

func getBellyMaxSizeModifier() -> float:
	return bellyMaxSizeModifier

func shouldOptimizeKids() -> bool:
	return optimizeChilds

func getMaxKeepPCKids() -> int:
	return maxKeepPCKids

func getMaxKeepNPCKids() -> int:
	return maxKeepNPCKids

func isHardStruggleEnabled():
	return hardStruggleEnabled

func getSmartLockRarity():
	return smartLockRarity

func isOverstimulationEnabled():
	return overstimulationEnabled

func shouldShowSpeakerName():
	return showSpeakerName

func getFontSize():
	return fontSize

func shouldShowShortcuts():
	return showShortcuts

func getMeasurementUnits():
	return measurementUnits

func shouldRequireDoubleTapOnMobile():
	return requireDoubleTapOnMobile

func getUiButtonSize():
	return uiButtonSize

func isDebugPanelEnabled():
	return debugPanel

func shouldShowCharacterArt():
	return showCharacterArt

func shouldShowSceneArt():
	return showSceneArt

func shouldShowSceneCreator():
	return showSceneCreator

func shouldShowMapArt():
	return showMapArt

func isRollbackEnabled():
	return rollbackEnabled

func getRollbackSlotsAmount():
	return rollbackSlots

func getRollbackSaveEveryXChoices():
	return rollbackSaveEvery

func shouldShowModdedLauncher():
	return showModdedLauncher

func developerCommentaryEnabled():
	return developerCommentary

func isJigglePhysicsBreastsEnabled():
	return jigglePhysicsBreastsEnabled

func isJigglePhysicsBellyEnabled():
	return jigglePhysicsBellyEnabled
	
func isJigglePhysicsButtEnabled():
	return jigglePhysicsButtEnabled

func getJigglePhysicsGlobalModifier():
	return jigglePhysicsGlobalModifier

func shouldUseAdvancedShaders():
	return advancedShadersEnabled

func shouldAutosave():
	return autosaveEnabled

func shouldSpawnChains():
	return chainsEnabled

func isVisibleCumShotsEnabled():
	return cumEnabled

func getCumShotsDependOnBallsVolume():
	return cumDependsOnBallsSize

func getCumShotsIntensityMult():
	return cumIntensityMult

func getSandboxPawnCount() -> int:
	return sandboxPawnCount

func getSandboxNpcLeveling() -> float:
	return sandboxNpcLeveling

func getSandboxOffscreenBreedingMult() -> float:
	if(sandboxBreeding == "normal"):
		return 1.0
	if(sandboxBreeding == "reduced"):
		return 0.5
	if(sandboxBreeding == "rare"):
		return 0.2
	if(sandboxBreeding == "veryrare"):
		return 0.05
	if(sandboxBreeding == "never"):
		return 0.0
	
	return 1.0

func getInventoryIconSize():
	if(inventoryIconsSize == "small"):
		return 32
	if(inventoryIconsSize == "normal"):
		return 40
	if(inventoryIconsSize == "big"):
		return 64
	return 32
func getWebhookStatsEnabled():
	return webhookStatsEnabled

func getWebhookPainEnabled():
	return webhookPainEnabled

func getWebhookURL():
	return webhookURL

func getChangeableOptions():
	var settings = [
		{
			"name": "Modding",
			"id": "modding",
			"options": [
				{
					"name": "Enable Modded BDCC Launcher",
					"description": "Restart the game to see it. Allows you to manage your mods and download new ones",
					"id": "showModdedLauncher",
					"type": "checkbox",
					"value": showModdedLauncher,
				},
			],
		},
		{
			"name": "Sandbox",
			"id": "sandbox",
			"options": [
				{
					"name": "Pawn amount",
					"description": "How many pawns should be running around the prison normally..",
					"id": "sandboxPawnCount",
					"type": "int",
					"value": sandboxPawnCount,
				},
				{
					"name": "Off-screen breeding",
					"description": "How often should the pawns be able to breed each other while you're not looking",
					"id": "sandboxBreeding",
					"type": "list",
					"value": sandboxBreeding,
					"values": [
						["normal", "Normal (100%)"],
						["reduced", "Reduced (50%)"],
						["rare", "Rare (20%)"],
						["veryrare", "Very rare (5%)"],
						["never", "Never (0%)"],
					],
				},
				{
					"name": "Accelerated pawn auto-leveling",
					"description": "Pawns receive more or less experience depending on the player's level. This setting adjusts the strength of this modifier. Normal leveling makes the npcs earn a fixed amount of experience from fights.",
					"id": "sandboxNpcLeveling",
					"type": "list",
					"value": sandboxNpcLeveling,
					"values": [
						[-1.0, "Disable npc leveling"],
						[0.0, "Normal leveling"],
						[0.05, "5%"],
						[0.1, "10%"],
						[0.25, "25%"],
						[0.5, "50%"],
						[0.75, "75%"],
						[1.0, "100%"],
						[1.5, "150%"],
						[2.0, "200%"],
					],
				},
			],
		},
		{
			"name": "Pregnancy settings",
			"id": "pregnancy",
			"options": [
				{
					"name": "Menstrual cycle length (days)",
					"description": "How long is the female menstrual cycle. Females can only get pregnant after they ovulate once per cycle. Realistic value is 30. Default value is 7",
					"id": "menstrualCycleLengthDays",
					"type": "int",
					"value": menstrualCycleLengthDays,
				},
				{
					"name": "Egg cell lifespan (hours)",
					"description": "How long egg cells live after ovulation. Realistic value is 18. Default value is 48",
					"id": "eggCellLifespanHours",
					"type": "int",
					"value": eggCellLifespanHours,
				},
				{
					"name": "Player pregnancy length (days)",
					"description": "How many days must pass until the player is ready to give birth. Realistic value is 270 for humans. Realistic value for felines is 30. Default value is 5",
					"id": "playerPregnancyTimeDays",
					"type": "int",
					"value": playerPregnancyTimeDays,
				},
				{
					"name": "NPC pregnancy length (days)",
					"description": "How many days pass before non-playable characters give birth. Realistic value is 270 for humans. Realistic value for felines is 30. Default value is 5",
					"id": "npcPregnancyTimeDays",
					"type": "int",
					"value": npcPregnancyTimeDays,
				},
				{
					"name": "Impregnation chance modifier (%)",
					"description": "Higher chance means impregnation is easier. Must be above zero",
					"id": "impregnationChanceModifier",
					"type": "int",
					"value": impregnationChanceModifier,
				},
				{
					"name": "Belly size depends on litter amount",
					"description": "If enabled, pregnant bellies will look bigger depending on the amount of kids it carries. For example, it will look roughly twice as big with 16 kids",
					"id": "bellySizeDependsOnLitterSize",
					"type": "checkbox",
					"value": bellySizeDependsOnLitterSize,
				},
				{
					"name": "Pregnant belly size (%)",
					"description": "Just a visual thing. Probaby best to leave it at 100% if you're gonna enable the option above.",
					"id": "bellyMaxSizeModifier",
					"type": "list",
					"value": bellyMaxSizeModifier,
					"values": [
						[0.0, "0%"],
						[0.25, "25%"],
						[0.5, "50%"],
						[0.7, "70%"],
						[0.8, "80%"],
						[0.9, "90%"],
						[1.0, "100%"],
						[1.10, "110%"],
						[1.25, "125%"],
						[1.5, "150%"],
						[1.75, "175%"],
						[2.0, "200%"],
					],
				},
				{
					"name": "Auto child record optimizer",
					"description": "If enabled, will automatically 'archive' old child records when their count goes above the specified amount each day. All the extra child info like name/species/gender is lost but the amount of kids you had with any npc is preserved. Useful as an automatic protection against save bloating.",
					"id": "optimizeChilds",
					"type": "checkbox",
					"value": optimizeChilds,
				},
				{
					"name": "Max player-related children records",
					"description": "The game will keep this many newest records of player's kids if 'Auto child record optimizer' is enabled. The oldest records will be 'archived'.",
					"id": "maxKeepPCKids",
					"type": "int",
					"value": maxKeepPCKids,
				},
				{
					"name": "Max non-player-related children records",
					"description": "The game will keep this many newest records of kids that don't belong to the player if 'Auto child record optimizer' is enabled. The oldest records will be 'archived'.",
					"id": "maxKeepNPCKids",
					"type": "int",
					"value": maxKeepNPCKids,
				},
			]
		},
		{
			"name": "Difficulty settings",
			"id": "difficulty",
			"options": [
				{
					"name": "Harder struggling",
					"description": "Makes getting restraints off harder. Turn this option on only if you feel like Houdini.",
					"id": "hardStruggleEnabled",
					"type": "checkbox",
					"value": hardStruggleEnabled
				},
				{
					"name": "Smart Lock rarity",
					"description": "How often will NPCs add special smart-locked BDSM gear on the player.",
					"id": "smartLockRarity",
					"type": "list",
					"value": smartLockRarity,
					"values": [
						["never", "Never"],
						["veryrare", "Very rare"],
						["rare", "Rare"],
						["normal", "Normal"],
						["often", "Often"],
						["veryoften", "Very often"],
						["bdsmslut", "BDSM SLUT"],
						["always", "Always"],
					]
				},
				{
					"name": "Overstimulation mechanic",
					"description": "Makes it so any erogenous zone can be overstimulated during sex. Overstimulated zones lose sensitivity when stimulated further. Nipples can be overstimulated even if this option is disabled.",
					"id": "overstimulationEnabled",
					"type": "checkbox",
					"value": overstimulationEnabled
				},
			]
		},
		{
			"name": "Render (Restart game after changing these)",
			"id": "render",
			"options": [
				{
					"name": "Renderer",
					"description": "GLES3 = Fancy, GLES2 = More support",
					"id": "renderer",
					"type": "list",
					"value": ProjectSettings.get_setting("rendering/quality/driver/driver_name"),
					"values": [
						["GLES3", "GLES3"],
						["GLES2", "GLES2"],
					]
				},
				{
					"name": "Force Software Skinning",
					"description": "Turn this on if the player doll is displayed incorrectly. Might lower performance.",
					"id": "softwareSkinning",
					"type": "checkbox",
					"value": ProjectSettings.get_setting("rendering/quality/skinning/force_software_skinning"),
				},
				{
					"name": "Skin shaders",
					"description": "Turn this off if your game is lagging/crashing. Will disable all skins.",
					"id": "advancedShadersEnabled",
					"type": "checkbox",
					"value": advancedShadersEnabled,
				}
			]
		},
		{
			"name": "Jiggle physics",
			"id": "jigglephysics",
			"options": [
				{
					"name": "Breasts jiggle physics",
					"description": "Should the boobs bounce?",
					"id": "jigglePhysicsBreastsEnabled",
					"type": "checkbox",
					"value": jigglePhysicsBreastsEnabled,
				},
				{
					"name": "Belly jiggle physics",
					"description": "Should the belly bounce?",
					"id": "jigglePhysicsBellyEnabled",
					"type": "checkbox",
					"value": jigglePhysicsBellyEnabled,
				},
				{
					"name": "Butt jiggle physics",
					"description": "Should the butt bounce?",
					"id": "jigglePhysicsButtEnabled",
					"type": "checkbox",
					"value": jigglePhysicsButtEnabled,
				},
				{
					"name": "Jiggle physics modifier",
					"description": "How bouncy should everything be",
					"id": "jigglePhysicsGlobalModifier",
					"type": "list",
					"value": jigglePhysicsGlobalModifier,
					"values": [
						[0.1, "10%"],
						[0.25, "25%"],
						[0.5, "50%"],
						[0.6, "60%"],
						[0.7, "70%"],
						[0.8, "80%"],
						[0.9, "90%"],
						[1.0, "100%"],
						[1.10, "110%"],
						[1.2, "120%"],
						[1.35, "135%"],
						[1.5, "150%"],
						[2.0, "200%"],
					],
				},
			]
		},
		{
			"name": "Saves",
			"id": "saves",
			"options": [
				{
					"name": "Autosave after sleep",
					"description": "Should the game save automatically when you sleep",
					"id": "autosaveEnabled",
					"type": "checkbox",
					"value": autosaveEnabled,
				}
			],
		},
		{
			"name": "Cum",
			"id": "cum",
			"options": [
				{
					"name": "Visible cumshots",
					"description": "Visible particles for when someone cums inside someone else or just shoots their load",
					"id": "cumEnabled",
					"type": "checkbox",
					"value": cumEnabled,
				},
				{
					"name": "Cumshot intensity multiplier",
					"description": "A multiplier for the amount of cum particles displayed during cumshots and also their velocity",
					"id": "cumIntensityMult",
					"type": "list",
					"value": cumIntensityMult,
					"values": [
						[0.1, "10%"],
						[0.3, "30%"],
						[0.5, "50%"],
						[0.7, "70%"],
						[0.9, "90%"],
						[1.0, "100%"],
						[1.1, "110%"],
						[1.3, "130%"],
						[1.5, "150%"],
						[1.7, "170%"],
						[2.0, "200%"],
						[3.0, "300%"],
						[5.0, "500%"],
					],
				},
				{
					"name": "Cumshots depend on balls volume",
					"description": "If unchecked, cumshots will always have the same intensity. If checked, they will scale depending on the balls volume.",
					"id": "cumDependsOnBallsSize",
					"type": "checkbox",
					"value": cumDependsOnBallsSize,
				},
			]
		},
		{
			"name": "Other",
			"id": "other",
			"options": [
				{
					"name": "Fetch latest release",
					"description": "Should the game load latest update info from github when starting the game",
					"id": "fetchLatestRelease",
					"type": "checkbox",
					"value": fetchNewRelease,
				},
				{
					"name": "UI scaling",
					"description": "Should the game scale the ui for different resolutions. Disable if text is blurry.",
					"id": "shouldScaleUI",
					"type": "checkbox",
					"value": shouldScaleUI,
				},
				{
					"name": "UI scale multiplier",
					"description": "Be careful when changing this value.",
					"id": "uiScaleMultiplier",
					"type": "list",
					"value": uiScaleMultiplier,
					"values": [
						[0.5, "50%"],
						[0.6, "60%"],
						[0.7, "70%"],
						[0.8, "80%"],
						[0.9, "90%"],
						[1.0, "100%"],
						[1.05, "105%"],
						[1.10, "110%"],
						[1.15, "115%"],
						[1.2, "120%"],
						[1.25, "125%"],
						[1.35, "135%"],
						[1.5, "150%"],
					],
				},
				{
					"name": "Show speaker name",
					"description": "Adds a name of the speaker before the speech",
					"id": "showSpeakerName",
					"type": "checkbox",
					"value": showSpeakerName,
				},
				{
					"name": "Output font size",
					"description": "Font size for the scene text output",
					"id": "fontSize",
					"type": "list",
					"value": fontSize,
					"values": [
						["small", "Small"],
						["normal", "Normal"],
						["big", "Big"],
					],
				},
				{
					"name": "Show shortcuts",
					"description": "Show the shortcut key on the button",
					"id": "showShortcuts",
					"type": "checkbox",
					"value": showShortcuts,
				},
				{
					"name": "Button size",
					"description": "Changes the size of the buttons inside the main game screen",
					"id": "uiButtonSize",
					"type": "list",
					"value": uiButtonSize,
					"values": [
						[0, "Default"],
						[1, "Slightly bigger"],
						[2, "Big"],
						[3, "Very big"],
					],
				},
				{
					"name": "Inventory icons",
					"description": "Changes the size of the buttons inside the main game screen",
					"id": "inventoryIconsSize",
					"type": "list",
					"value": inventoryIconsSize,
					"values": [
						["small", "Small"],
						["normal", "Normal"],
						["big", "Big"],
					],
				},
				{
					"name": "Double-tap to pick option (mobile)",
					"description": "First tap shows the description, second tap picks the option. Works only with touchscreens",
					"id": "requireDoubleTapOnMobile",
					"type": "checkbox",
					"value": requireDoubleTapOnMobile,
				},
				{
					"name": "Measurement units",
					"description": "Choose how to display length values",
					"id": "measurementUnits",
					"type": "list",
					"value": measurementUnits,
					"values": [
						["metric", "Metric (cm)"],
						["imperial", "Imperial (in)"],
						["metricimperial", "Metric and Imperial"],
					],
				},
				{
					"name": "Show character art",
					"description": "Show panel with character art instead of small one",
					"id": "showCharacterArt",
					"type": "checkbox",
					"value": showCharacterArt,
				},
				{
					"name": "Show scene art",
					"description": "Display the art associated with the current scene (if available)",
					"id": "showSceneArt",
					"type": "checkbox",
					"value": showSceneArt,
				},
				{
					"name": "Image packs",
					"description": "Choose artist priority",
					"id": "imagePackOrder",
					"type": "prioritylist",
					"imagePacks": true,
					"value": "",
					"values": imagePackOrder,
				},
				{
					"name": "Show scene creator",
					"description": "Displays a 'scene by' text with the author's name under the minimap",
					"id": "showSceneCreator",
					"type": "checkbox",
					"value": showSceneCreator,
				},
				{
					"name": "Developer commentary",
					"description": "Enables developer commentary for scenes that support it",
					"id": "developerCommentary",
					"type": "checkbox",
					"value": developerCommentary,
				},
				{
					"name": "Visible chains",
					"description": "Visible chains when your character is cuffed/leashed. Disabling might improve perfomance.",
					"id": "chainsEnabled",
					"type": "checkbox",
					"value": chainsEnabled,
				},
#				{
#					"name": "Show map art (WIP)",
#					"description": "(WORK IN PROGRESS) Shows props and walls on the minimap when supported",
#					"id": "showMapArt",
#					"type": "checkbox",
#					"value": showMapArt,
#				},
			],
		},
		{
			"name": "Rollback settings (Experimental)",
			"id": "rollback",
			"options": [
				{
					"name": "Rollback enabled",
					"description": "If checked you will be able to rollback the game's state, undoing any choices that the player made. Might use a lot of memory. Disable if the game is too laggy",
					"id": "rollbackEnabled",
					"type": "checkbox",
					"value": rollbackEnabled,
				},
				{
					"name": "Rollback history size",
					"description": "How many actions you wanna be able to undo",
					"id": "rollbackSlots",
					"type": "int",
					"value": rollbackSlots,
				},
				{
					"name": "Make snapshot every X choices",
					"description": "How often do you wanna save the rollback state. 1 = every choice",
					"id": "rollbackSaveEvery",
					"type": "int",
					"value": rollbackSaveEvery,
				},
			]
		},
		{
			"name": "Webhook",
			"id": "webhook",
			"options": [
				{
					"name": "Webhook base URL",
					"description": "The base URL of the webhook",
					"id": "webhookURL",
					"type": "string",
					"value": webhookURL,
				},
				{
					"name": "Stats enabled",
					"description": "Sends POST requests with basic player character stats",
					"id": "webhookStatsEnabled",
					"type": "checkbox",
					"value": webhookStatsEnabled,
				},
				{
					"name": "Painful insertions enabled",
					"description": "Sends POST requests with painful insertion information",
					"id": "webhookPainEnabled",
					"type": "checkbox",
					"value": webhookPainEnabled,
				},
			]
		},
		{
			"name": "Debug",
			"id": "debug",
			"options": [
				{
					"name": "Debug/Cheats panel",
					"description": "Adds a button that shows the debug panel",
					"id": "debugPanel",
					"type": "checkbox",
					"value": debugPanel,
				},
			]
		},
	]
	
	var contentSettings = []
	for contentType in ContentType.getAll():
		contentSettings.append({
			"name": ContentType.getVisibleName(contentType),
			"description": ContentType.getDescription(contentType),
			"id": contentType,
			"type": "checkbox",
			"value": isContentEnabled(contentType),
		})
	settings.append({
		"name": "Enabled Fetish Content",
		"id": "enabledContent",
		"options": contentSettings,
	})
	
	var genderNamesSettings = []
	for gender in NpcGender.getAll():
		var genderExplanation = NpcGender.getGenderExplanation(gender)
		if(genderExplanation == null):
			genderExplanation = ""
		
		genderNamesSettings.append({
			"name": NpcGender.getOptionsDesc(gender),
			"description": genderExplanation,
			"id": gender,
			"type": "string",
			"value": getGenderOverrideName(gender, ""),
			"placeholder": NpcGender.getDefaultVisibleName(gender),
		})
	settings.append({
		"name": "Npc Self-Identity Names Override",
		"id": "gendernames",
		"options": genderNamesSettings,
	})
	
	return settings

func applyOption(categoryID, optionID, value):
	if(categoryID == "gendernames"):
		if(value == "" && genderNamesOverrides.has(optionID)):
			genderNamesOverrides.erase(optionID)
		if(value != ""):
			genderNamesOverrides[optionID] = value
	
	if(categoryID == "sandbox"):
		if(optionID == "sandboxPawnCount"):
			sandboxPawnCount = value
			if(sandboxPawnCount < 0):
				sandboxPawnCount = 0
		if(optionID == "sandboxBreeding"):
			sandboxBreeding = value
		if(optionID == "sandboxNpcLeveling"):
			sandboxNpcLeveling = value
	
	if(categoryID == "jigglephysics"):
		if(optionID == "jigglePhysicsBreastsEnabled"):
			jigglePhysicsBreastsEnabled = value
		if(optionID == "jigglePhysicsBellyEnabled"):
			jigglePhysicsBellyEnabled = value
		if(optionID == "jigglePhysicsButtEnabled"):
			jigglePhysicsButtEnabled = value
		if(optionID == "jigglePhysicsGlobalModifier"):
			jigglePhysicsGlobalModifier = value

	if(categoryID == "cum"):
		if(optionID == "cumEnabled"):
			cumEnabled = value
		if(optionID == "cumDependsOnBallsSize"):
			cumDependsOnBallsSize = value
		if(optionID == "cumIntensityMult"):
			cumIntensityMult = value

	if(categoryID == "saves"):
		if(optionID == "autosaveEnabled"):
			autosaveEnabled = value

	if(categoryID == "modding"):
		if(optionID == "showModdedLauncher"):
			showModdedLauncher = value
			if(showModdedLauncher):
				var _ok = OS.request_permissions()
	
	if(categoryID == "pregnancy"):
		if(optionID == "menstrualCycleLengthDays"):
			menstrualCycleLengthDays = value
		if(optionID == "eggCellLifespanHours"):
			eggCellLifespanHours = value
		if(optionID == "playerPregnancyTimeDays"):
			playerPregnancyTimeDays = value
		if(optionID == "npcPregnancyTimeDays"):
			npcPregnancyTimeDays = value
		if(optionID == "impregnationChanceModifier"):
			impregnationChanceModifier = value
		if(optionID == "bellySizeDependsOnLitterSize"):
			bellySizeDependsOnLitterSize = value
		if(optionID == "bellyMaxSizeModifier"):
			bellyMaxSizeModifier = value
		if(optionID == "optimizeChilds"):
			optimizeChilds = value
		if(optionID == "maxKeepPCKids"):
			maxKeepPCKids = value
		if(optionID == "maxKeepNPCKids"):
			maxKeepNPCKids = value
	
	if categoryID == "difficulty":
		if optionID == "hardStruggleEnabled":
			hardStruggleEnabled = value
		if optionID == "smartLockRarity":
			smartLockRarity = value
		if optionID == "overstimulationEnabled":
			overstimulationEnabled = value
	
	if(categoryID == "other"):
		if(optionID == "fetchLatestRelease"):
			fetchNewRelease = value
		if(optionID == "shouldScaleUI"):
			shouldScaleUI = value
			
			applySettingsEffect()
		if(optionID == "uiScaleMultiplier"):
			uiScaleMultiplier = value
			
			applySettingsEffect()
		if(optionID == "showSpeakerName"):
			showSpeakerName = value
		if(optionID == "fontSize"):
			fontSize = value
		if(optionID == "showShortcuts"):
			showShortcuts = value
		if(optionID == "measurementUnits"):
			measurementUnits = value
		if(optionID == "requireDoubleTapOnMobile"):
			requireDoubleTapOnMobile = value
		if(optionID == "uiButtonSize"):
			uiButtonSize = value
		if(optionID == "inventoryIconsSize"):
			inventoryIconsSize = value
		if(optionID == "showCharacterArt"):
			showCharacterArt = value
		if(optionID == "showSceneArt"):
			showSceneArt = value
		if(optionID == "showSceneCreator"):
			showSceneCreator = value
		if(optionID == "showMapArt"):
			showMapArt = value
		if(optionID == "developerCommentary"):
			developerCommentary = value
		if(optionID == "chainsEnabled"):
			chainsEnabled = value
		
	if(categoryID == "render"):
		if(optionID == "renderer"):
			myProjectSettings.setDriverName(value)
			myProjectSettings.save()
		if(optionID == "softwareSkinning"):
			myProjectSettings.setForceSoftwareSkinning(value)
			myProjectSettings.save()
		if(optionID == "advancedShadersEnabled"):
			advancedShadersEnabled = value
			
	if(categoryID == "webhook"):
		if(optionID == "webhookStatsEnabled"):
			webhookStatsEnabled = value
		if(optionID == "webhookPainEnabled"):
			webhookPainEnabled = value
		if(optionID == "webhookURL"):
			webhookURL = value
	
	if(categoryID == "debug"):
		if(optionID == "debugPanel"):
			debugPanel = value
	
	if(categoryID == "rollback"):
		if(optionID == "rollbackEnabled"):
			rollbackEnabled = value
		if(optionID == "rollbackSlots"):
			rollbackSlots = Util.maxi(value, 1)
		if(optionID == "rollbackSaveEvery"):
			rollbackSaveEvery = Util.maxi(value, 1)
			
	if(categoryID == "enabledContent"):
		enabledContent[optionID] = value
	print("SETTING "+categoryID+":"+optionID+" TO "+str(value))

func applySettingsEffect():
	applyUIScale()
	
func applyUIScale():
	if(shouldScaleUI):
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(1280,720), uiScaleMultiplier)
	else:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(1280,720))

func saveData():
	var data = {
		"optionsVersion": 1,
		"enabledContent": enabledContent,
		"fetchNewRelease": fetchNewRelease,
		"menstrualCycleLengthDays": menstrualCycleLengthDays,
		"eggCellLifespanHours": eggCellLifespanHours,
		"playerPregnancyTimeDays": playerPregnancyTimeDays,
		"npcPregnancyTimeDays": npcPregnancyTimeDays,
		"impregnationChanceModifier": impregnationChanceModifier,
		"bellySizeDependsOnLitterSize": bellySizeDependsOnLitterSize,
		"bellyMaxSizeModifier": bellyMaxSizeModifier,
		"optimizeChilds": optimizeChilds,
		"maxKeepPCKids": maxKeepPCKids,
		"maxKeepNPCKids": maxKeepNPCKids,
		"hardStruggleEnabled": hardStruggleEnabled,
		"smartLockRarity": smartLockRarity,
		"overstimulationEnabled": overstimulationEnabled,
		"shouldScaleUI": shouldScaleUI,
		"uiScaleMultiplier": uiScaleMultiplier,
		"uiButtonSize": uiButtonSize,
		"showSpeakerName": showSpeakerName,
		"fontSize": fontSize,
		"showShortcuts": showShortcuts,
		"measurementUnits": measurementUnits,
		"requireDoubleTapOnMobile": requireDoubleTapOnMobile,
		"debugPanel": debugPanel,
		"imagePackOrder": imagePackOrder,
		"showCharacterArt": showCharacterArt,
		"showSceneArt": showSceneArt,
		"showSceneCreator": showSceneCreator,
		"showMapArt": showMapArt,
		"rollbackEnabled": rollbackEnabled,
		"rollbackSlots": rollbackSlots,
		"rollbackSaveEvery": rollbackSaveEvery,
		"showModdedLauncher": showModdedLauncher,
		"developerCommentary": developerCommentary,
		"jigglePhysicsBreastsEnabled": jigglePhysicsBreastsEnabled,
		"jigglePhysicsBellyEnabled": jigglePhysicsBellyEnabled,
		"jigglePhysicsButtEnabled": jigglePhysicsButtEnabled,
		"jigglePhysicsGlobalModifier": jigglePhysicsGlobalModifier,
		"advancedShadersEnabled": advancedShadersEnabled,
		"chainsEnabled": chainsEnabled,
		"autosaveEnabled": autosaveEnabled,
		"inventoryIconsSize": inventoryIconsSize,
		"genderNamesOverrides": genderNamesOverrides,
		"cumEnabled": cumEnabled,
		"cumDependsOnBallsSize": cumDependsOnBallsSize,
		"cumIntensityMult": cumIntensityMult,
		"sandboxPawnCount": sandboxPawnCount,
		"sandboxBreeding": sandboxBreeding,
		"sandboxNpcLeveling": sandboxNpcLeveling,
		"webhookStatsEnabled": webhookStatsEnabled,
		"webhookPainEnabled": webhookStatsEnabled,
		"webhookURL": webhookURL,
	}
	
	return data

func loadData(data):
	enabledContent = loadVar(data, "enabledContent", {})
	fetchNewRelease = loadVar(data, "fetchNewRelease", true)
	menstrualCycleLengthDays = loadVar(data, "menstrualCycleLengthDays", 7)
	eggCellLifespanHours = loadVar(data, "eggCellLifespanHours", 48)
	playerPregnancyTimeDays = loadVar(data, "playerPregnancyTimeDays", 5)
	npcPregnancyTimeDays = loadVar(data, "npcPregnancyTimeDays", 5)
	impregnationChanceModifier = loadVar(data, "impregnationChanceModifier", 100)
	bellySizeDependsOnLitterSize = loadVar(data, "bellySizeDependsOnLitterSize", false)
	bellyMaxSizeModifier = loadVar(data, "bellyMaxSizeModifier", 1.0)
	optimizeChilds = loadVar(data, "optimizeChilds", false)
	maxKeepPCKids = loadVar(data, "maxKeepPCKids", 50)
	maxKeepNPCKids = loadVar(data, "maxKeepNPCKids", 30)
	hardStruggleEnabled = loadVar(data, "hardStruggleEnabled", false)
	smartLockRarity = loadVar(data, "smartLockRarity", "normal")
	overstimulationEnabled = loadVar(data, "overstimulationEnabled", true)
	shouldScaleUI = loadVar(data, "shouldScaleUI", true)
	uiScaleMultiplier = loadVar(data, "uiScaleMultiplier", 1.0)
	uiButtonSize = loadVar(data, "uiButtonSize", 0)
	showSpeakerName = loadVar(data, "showSpeakerName", true)
	fontSize = loadVar(data, "fontSize", "normal")
	showShortcuts = loadVar(data, "showShortcuts", true)
	measurementUnits = loadVar(data, "measurementUnits", "metric")
	requireDoubleTapOnMobile = loadVar(data, "requireDoubleTapOnMobile", false)
	debugPanel = loadVar(data, "debugPanel", false)
	imagePackOrder = loadVar(data, "imagePackOrder", [])
	showCharacterArt = loadVar(data, "showCharacterArt", true)
	showSceneArt = loadVar(data, "showSceneArt", true)
	showSceneCreator = loadVar(data, "showSceneCreator", true)
	showMapArt = loadVar(data, "showMapArt", false)
	rollbackEnabled = loadVar(data, "rollbackEnabled", false)
	rollbackSlots = loadVar(data, "rollbackSlots", 5)
	rollbackSaveEvery = loadVar(data, "rollbackSaveEvery", 1)
	showModdedLauncher = loadVar(data, "showModdedLauncher", false)
	developerCommentary = loadVar(data, "developerCommentary", false)
	jigglePhysicsBreastsEnabled = loadVar(data, "jigglePhysicsBreastsEnabled", true)
	jigglePhysicsBellyEnabled = loadVar(data, "jigglePhysicsBellyEnabled", true)
	jigglePhysicsButtEnabled = loadVar(data, "jigglePhysicsButtEnabled", true)
	jigglePhysicsGlobalModifier = loadVar(data, "jigglePhysicsGlobalModifier", 1.0)
	advancedShadersEnabled = loadVar(data, "advancedShadersEnabled", true)
	chainsEnabled = loadVar(data, "chainsEnabled", true)
	autosaveEnabled = loadVar(data, "autosaveEnabled", true)
	inventoryIconsSize = loadVar(data, "inventoryIconsSize", "small")
	genderNamesOverrides = loadVar(data, "genderNamesOverrides", {})
	cumEnabled = loadVar(data, "cumEnabled", true)
	cumDependsOnBallsSize = loadVar(data, "cumDependsOnBallsSize", true)
	cumIntensityMult = loadVar(data, "cumIntensityMult", 1.0)
	sandboxPawnCount = loadVar(data, "sandboxPawnCount", 30)
	sandboxBreeding = loadVar(data, "sandboxBreeding", "rare")
	sandboxNpcLeveling = loadVar(data, "sandboxNpcLeveling", 1.0)
	webhookStatsEnabled = loadVar(data, "webhookStatsEnabled", false)
	webhookPainEnabled = loadVar(data, "webhookPainEnabled", false)
	webhookURL = loadVar(data, "webhookURL", "https://webhook.xtoys.app/abcrandomid")

func saveToFile():
	var saveData = saveData()
	var save_game = File.new()
	save_game.open(optionsFilepath, File.WRITE)
	
	save_game.store_line(JSON.print(saveData, "\t", true))
	
	save_game.close()

func loadFromFile():
	var save_game = File.new()
	if not save_game.file_exists(optionsFilepath):
		print("GlobalOptions: No saved options found, default values will be used")
		return
	
	save_game.open(optionsFilepath, File.READ)
	#var saveData = parse_json(save_game.get_as_text())
	var jsonResult = JSON.parse(save_game.get_as_text())
	if(jsonResult.error != OK):
		Log.printerr("GlobalOptions: Error while loading the options file, the file is not a valid json")
		return
	
	var saveData = jsonResult.result
	loadData(saveData)
	save_game.close()

func loadVar(data: Dictionary, key, nullvalue = null):
	if(!data.has(key)):
		Log.printerr("Warning: Options file doesn't have key "+key+". Using "+str(nullvalue)+" as default value. File: "+Util.getStackFunction())
		return nullvalue
		
	if(nullvalue != null && typeof(data[key]) != typeof(nullvalue) && !(typeof(data[key]) == TYPE_REAL && typeof(nullvalue) == TYPE_INT)):
		Log.printerr("Warning: value mismatch when loading an options file. Key '"+key+"' has type "+Util.variantTypeToString(typeof(data[key]))+" and default value has type "+Util.variantTypeToString(typeof(nullvalue))+". Is that an error? "+Util.getStackFunction())
		
	if(data[key] == null && nullvalue != null):
		Log.printerr("Warning: loaded value is null while the default value isn't. Is that correct? "+Util.getStackFunction())
		
	return data[key]

func resetRenderSettings():
	myProjectSettings.resetToDefault()

func checkImagePackOrder(imagePacks):
	var newImagePackOrder = []
	
	for imagePackID in imagePackOrder:
		if (imagePacks.has(imagePackID)):
			newImagePackOrder.append(imagePackID)
	
	for imagePackID in imagePacks:
		if(!newImagePackOrder.has(imagePackID)):
			newImagePackOrder.push_front(imagePackID)
	
	imagePackOrder = newImagePackOrder
	#print("checkImagePackOrder DONE ",imagePackOrder)

func getImagePackOrder():
	return imagePackOrder
