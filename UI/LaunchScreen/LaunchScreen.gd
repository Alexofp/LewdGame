extends Control

onready var modDescriptionLabel = $VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer2/VBoxContainer/RichTextLabel
onready var modVList = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/ScrollContainer/ModList
onready var modFileList = $VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer2/VBoxContainer/ModFileList
var launchModEntryScene = preload("res://UI/LaunchScreen/LaunchModEntry.tscn")

var currentModOrder = []
var selectedEntry = null

export(Resource) var GlobalTheme

const modOrderPath = "user://modOrder.json"
const pckversionPath = "user://bdccpckversion.txt"
var foundBDCC = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#randomize()
	#var diag:DialogueParser = DialogueParser.new()
	#print(diag.getLexems("Hello world. How;are|you. Hey, [[mean=fucker|bitch;kind=bro;person]]. Meow."))
	#print(diag.processString("Hello,_[[asd]]meow", {kind=true,mean=true}, {BITCH=["bitch", "stupid-bitch", "stupid-stupid-bitch"]}))

	
	if(GlobalTheme != null):
		if(OS.has_touchscreen_ui_hint()):
			GlobalTheme.rename_stylebox("scrollTouch", "scroll", "VScrollBar")
			
	var rawModList = GlobalRegistry.getRawModList()
	if(GlobalRegistry.hasModSupport() && OS.get_name() in ["Android", "Switch"] && (rawModList.size() > 0) || OPTIONS.shouldShowModdedLauncher()):
		if(Util.readFile(pckversionPath) != GlobalRegistry.getGameVersionString()):
			generateBDCCpckFile()
			rawModList = GlobalRegistry.getRawModList()
			
	var SHOW_THIS_SCREEN_ANYWAY = false # DON'T FORGET TO CHANGE TO false BEFORE SHIPPING
	
	if(OS.get_name() in ["Android", "Switch"] || SHOW_THIS_SCREEN_ANYWAY):
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/TestButton.visible = true
	else:
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/TestButton.visible = false
	
	if(OS.get_name() in ["Android", "HTML5", "Switch"]):
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/OpenModsFolder.visible = false
	
	if(!SHOW_THIS_SCREEN_ANYWAY && !OPTIONS.shouldShowModdedLauncher()):
		if(!GlobalRegistry.hasModSupport() || rawModList.size() == 0):
			#GlobalRegistry.registerEverything()
			var _ok = get_tree().change_scene("res://UI/LoadingScreen.tscn")#"res://UI/MainMenu/MainMenu.tscn"

	checkModOrderAndFillData(rawModList)

func checkModOrderAndFillData(rawModList):
	var loadedOrder = loadOrderFromFile()
	
	var finalOrder = []
	var theFile = File.new()
	for modEntry in loadedOrder:
		if(!theFile.file_exists(modEntry["path"])):
			continue
		
		finalOrder.append(modEntry)
	
	for modPath in rawModList:
		var foundMod = false
		for loadedModEntry in loadedOrder:
			if(loadedModEntry["path"] == modPath):
				foundMod = true
				break
		if(foundMod):
			continue
		
		var modEntry = {
			path = modPath,
			name = modPath.get_file(),
			disabled = false,
		}
		finalOrder.append(modEntry)
	
	currentModOrder = finalOrder
	
	ensureBDCCIsFirst()
	updateModList()
	updateSelectedEntry()

func saveOrderIntoFile(saveData):
	var save_game = File.new()
	save_game.open(modOrderPath, File.WRITE)
	
	var finalData = []
	for modEntry in saveData:
		finalData.append({
			"path": modEntry["path"],
			"disabled": modEntry["disabled"],
		})
	
	save_game.store_line(JSON.print(finalData, "\t", true))
	
	save_game.close()

func loadOrderFromFile():
	var save_game = File.new()
	if not save_game.file_exists(modOrderPath):
		print("LaunchScreen: No mod order is found")
		return []
	
	save_game.open(modOrderPath, File.READ)
	#var saveData = parse_json(save_game.get_as_text())
	var jsonResult = JSON.parse(save_game.get_as_text())
	if(jsonResult.error != OK):
		Log.printerr("LaunchScreen: Error while loading the mod order file, the file is not a valid json")
		return []
	
	var saveData = jsonResult.result
	save_game.close()
	
	# Sanity checking
	if(!(saveData is Array)):
		return []
	for modEntry in saveData:
		if(!(modEntry is Dictionary)):
			return []
		if(!modEntry.has("path") || !modEntry.has("disabled")):
			return []
		if(!(modEntry["path"] is String) || !(modEntry["disabled"] is bool)):
			return []
			
	var result = []
	for loadedModEntry in saveData:
		var modEntry = {
			path = loadedModEntry["path"],
			name = loadedModEntry["path"].get_file(),
			disabled = loadedModEntry["disabled"],
		}
		result.append(modEntry)
	
	return result

func updateModList():
	Util.delete_children(modVList)
	
	for modEntry in currentModOrder:
		var newEntry = launchModEntryScene.instance()
		modVList.add_child(newEntry)
		newEntry.setModEntry(modEntry)
		newEntry.connect("onSelected", self, "onModEntryClicked")
		
		if(modEntry == selectedEntry):
			newEntry.makeActive()

func _on_WithModsButton_pressed():
	saveOrderIntoFile(currentModOrder)
	
	GlobalRegistry.loadModOrder(currentModOrder)
	#GlobalRegistry.registerEverything()
	var _ok = get_tree().change_scene("res://UI/LoadingScreen.tscn")#"res://UI/MainMenu/MainMenu.tscn"

func _on_NoModsButton_pressed():
	saveOrderIntoFile(currentModOrder)
	
	#GlobalRegistry.loadModOrder(currentModOrder)
	#GlobalRegistry.registerEverything()
	var _ok = get_tree().change_scene("res://UI/LoadingScreen.tscn")#"res://UI/MainMenu/MainMenu.tscn"

func onModEntryClicked(entry):
	selectedEntry = entry
	updateModList()
	updateSelectedEntry()

func updateSelectedEntry():
	if(selectedEntry == null):
		if(OS.get_name() in ["Android", "Switch"] && false):
			if(!foundBDCC):
				$VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer2/VBoxContainer/WarningLabel.bbcode_text = "[color=red]You must provide BDCC.pck file to be able to use mods. It must be from the current version! Download the most recent one [url=https://github.com/Alexofp/BDCC/releases]HERE[/url] and place into the mods folder[/color]"
				$VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer2/VBoxContainer/WarningLabel.visible = true
				$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/WithModsButton.disabled = true
			else:
				$VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer2/VBoxContainer/WarningLabel.bbcode_text = "BDCC.pck file is found. Don't forget to update it when you update the game. Download the most recent one [url=https://github.com/Alexofp/BDCC/releases]HERE[/url]"
				$VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer2/VBoxContainer/WarningLabel.visible = true
		
		modDescriptionLabel.bbcode_text = "No mod selected"
		return
	
	var desc = ""
	desc += "Mod name: "+selectedEntry["name"]+"\n"
	desc += "Full path: "+selectedEntry["path"]+"\n"
	
	desc += "\n"
	var jsonResult = tryToPopulateFilesList()
	if(jsonResult is String):
		desc += jsonResult
	else:
		desc += "Author: " + str(jsonResult["author"])+"\n"
		if(!GlobalRegistry.isVersionListHasCompatible(str(jsonResult["gameversion"]))):
			desc += "[color=red]Game version: " + str(jsonResult["gameversion"])+" (You are running verson "+GlobalRegistry.getGameVersionString()+")[/color]\n"
		else:
			desc += "Game version: " + str(jsonResult["gameversion"])+"\n"
		desc += "Mod version: " + str(jsonResult["modversion"])+"\n"
		desc += "Description: " + str(jsonResult["description"])+"\n"

	modDescriptionLabel.bbcode_text = desc

func tryToPopulateFilesList():
	modFileList.clear()
	
	if(selectedEntry == null):
		return ""
	var zipToLoad = selectedEntry["path"]
	if(zipToLoad.get_file() == "BDCC.pck"):
		return "This file is required for mods to function on mobile versions. On other platforms this file is Not required and will be disabled automatically"
	
	var gdunzip = GDUnzip.new()
	
	var loaded = gdunzip.load(zipToLoad)
	
	if(loaded && gdunzip.files != null):
		for file in gdunzip.files:
			modFileList.add_item(file)
		
		var jsonFile = zipToLoad.get_file().get_basename()+".json"
		if(gdunzip.files.has(jsonFile)):
			var uncompressed = gdunzip.uncompress(jsonFile)
			if !uncompressed:
				return "'"+str(jsonFile)+"' is wrong or corrupted"
			else:
				var stuff = uncompressed.get_string_from_utf8()
				
				var jsonResult = JSON.parse(stuff)
				if(jsonResult.error != OK):
					return "'"+str(jsonFile)+"' is wrong or corrupted"
				
				var jsonData = jsonResult.result
				if(!(jsonData is Dictionary)):
					return "'"+str(jsonFile)+"' is wrong or corrupted"
				
				var fieldsMustHave = ["author", "gameversion", "modversion", "description"]
				for field in fieldsMustHave:
					if(!jsonData.has(field)):
						return "'"+str(jsonFile)+"' is missing one of the fields. Must have: "+str(fieldsMustHave)
						
				return jsonData
		else:
			return "No '"+str(jsonFile)+"' file provided inside the mod"
	else:
		Log.print('Failed loading zip file')
		modFileList.add_item("Couldn't load any files")
	return "Failed to load info"


func _on_ModDisableButton_pressed():
	if(selectedEntry == null):
		return
	if(selectedEntry["name"] == "BDCC.pck"):
		return
	
	selectedEntry["disabled"] = !selectedEntry["disabled"]
	updateModList()


func _on_MoveUpButton_pressed():
	if(selectedEntry == null):
		return
	if(selectedEntry["name"] == "BDCC.pck"):
		return
	
	var currentIndex = currentModOrder.find(selectedEntry)
	var newIndex = currentIndex - 1
	if(newIndex < 0):
		newIndex = 0
	currentModOrder.remove(currentIndex)
	currentModOrder.insert(newIndex, selectedEntry)
	
	ensureBDCCIsFirst()
	updateModList()


func _on_MoveDownButton_pressed():
	if(selectedEntry == null):
		return
	if(selectedEntry["name"] == "BDCC.pck"):
		return
	
	var currentIndex = currentModOrder.find(selectedEntry)
	var newIndex = currentIndex + 1
	if(newIndex >= currentModOrder.size()):
		newIndex = currentModOrder.size() - 1
	currentModOrder.remove(currentIndex)
	currentModOrder.insert(newIndex, selectedEntry)
	
	updateModList()

func ensureBDCCIsFirst():
	for _i in range(currentModOrder.size()):
		if(currentModOrder[_i]["name"] == "BDCC.pck"):
			var entry = currentModOrder[_i]
			if(not OS.get_name() in ["Android", "Swotch"]):
				entry["disabled"] = true
			else:
				entry["disabled"] = false
			
			currentModOrder.remove(_i)
			currentModOrder.insert(0, entry)
			foundBDCC = true
			return

func _on_DeleteModButton_pressed():
	if(selectedEntry == null):
		return
	
	$ConfirmationDialog.visible = true
	$ConfirmationDialog.dialog_text = "Remove mod?\n"+str(selectedEntry["path"])


func _on_ConfirmationDialog_confirmed():
	if(selectedEntry == null):
		return
	
	var theFile = Directory.new()
	theFile.remove(selectedEntry["path"])
	currentModOrder.erase(selectedEntry)
	selectedEntry = null
	
	updateModList()
	updateSelectedEntry()


func _on_RichTextLabel_meta_clicked(meta):
	var _ok = OS.shell_open(meta)


func _on_TestButton_pressed():
	generateBDCCpckFile()
	checkModOrderAndFillData(GlobalRegistry.getRawModList())
	
func generateBDCCpckFile():
	var packer = PCKPacker.new()
	
	var modsFolder = GlobalRegistry.getModsFolder()
	
	packer.pck_start(modsFolder.plus_file("BDCC.pck"))
	
	
	fillFolder(packer, "res://")
	#packer.add_file("res://text.txt", "text.txt")
	packer.flush()
	
	Util.writeFile(pckversionPath, GlobalRegistry.getGameVersionString())

const ignorePaths = {
	"res://.git": true,
	"res://.github": true,
	#"res://.import": true,
	"res://AssetsSource": true,
}

func fillFolder(packer, folder):
	var dir = Directory.new()
	if dir.open(folder) == OK:
		dir.list_dir_begin(true, false)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var full_path = folder.plus_file(file_name)
				if(ignorePaths.has(full_path)):
					print("IGNORED "+full_path)
					file_name = dir.get_next()
					continue
				
				#var child1 = tree.create_item(root)
				#child1.set_text(0, file_name)
				#child1.collapsed = true
				#child1.set_metadata(0, full_path)

				#print("Found directory: " + file_name)
				fillFolder(packer, full_path)
				#if(child1.get_children() == null):
				#	root.remove_child(child1)
			else:
				#if(file_name.get_extension() == "gd"):
				var full_path:String = folder.plus_file(file_name)
				packer.add_file(full_path, full_path)
				#if(filter == "" || (filter in full_path)):
				#	var child1 = tree.create_item(root)
				#	child1.set_text(0, file_name)
				#	child1.set_metadata(0, full_path)
			file_name = dir.get_next()
	else:
		Log.printerr("An error occurred when trying to access the path "+folder)


func _on_ModBrowserButton_pressed():
	$VBoxContainer.visible = false
	$ModBrowser.visible = true

	saveOrderIntoFile(currentModOrder)

func _on_ModBrowser_closePressed():
	$VBoxContainer.visible = true
	$ModBrowser.visible = false
	
	checkModOrderAndFillData(GlobalRegistry.getRawModList())


func _on_OpenModsFolder_pressed():
	var _ok = OS.shell_open(ProjectSettings.globalize_path("user://mods"))
