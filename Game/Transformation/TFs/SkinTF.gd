extends TFBase

var prog:float = 0
var pickedColors:Array = []
var pickedSkin:String = ""

func _init():
	id = "SkinTF"
	#pillGenWeight = 0.0

func getName() -> String:
	return "Changes colors"

func getPillName() -> String:
	return "CoLore"

func getTFCheckTags() -> Dictionary:
	return {
		"skin": true,
	}

func start(_args:Dictionary):
	var theChar = getChar()
	
	if(_args.has("color_r") && _args.has("color_g") && _args.has("color_b")):
		pickedColors = [
			(Color(_args["color_r"]) if (_args["color_r"] is String) else _args["color_r"]),
			(Color(_args["color_g"]) if (_args["color_g"] is String) else _args["color_g"]),
			(Color(_args["color_b"]) if (_args["color_b"] is String) else _args["color_b"]),
			]
	elif(!_args.has("colors")):
		pickedColors = TFUtil.getRandomColorsForSpecies(theChar.getSpecies())
	else:
		pickedColors = _args["colors"]
	
	if(!_args.has("skin")):
		pickedSkin = TFUtil.getRandomSkinForSpecies(theChar.getSpecies())
	else:
		pickedSkin = _args["skin"]

func getPillOptions() -> Dictionary:
	var skinsArray:Array = []
	for skinID in GlobalRegistry.getSkinsAllKeys():
		var theSkin:SkinBase = GlobalRegistry.getSkin(skinID)
		skinsArray.append([skinID, theSkin.getName()])
	
	return {
		"skin": {
			name = "Skin",
			desc = "The new skin.",
			value = "EmptySkin",
			values = skinsArray,
		},
		"color_r": {
			name = "Primary color",
			desc = "The primary color.",
			value = "#FF0000",
			color = true,
		},
		"color_g": {
			name = "Secondary color",
			desc = "The secondary color.",
			value = "#FFFF00",
			color = true,
		},
		"color_b": {
			name = "Third color",
			desc = "The third color.",
			value = "#FF00FF",
			color = true,
		},
	}

func getMaxStage() -> int:
	return 5

func canTransformFurther() -> bool:
	if(prog < 1.0):
		return true
	return false
	
func getTimerForStage(_theStage:int) -> int:
	if(_theStage == 0):
		return 120
	return 240
	
func doProgress(_context:Dictionary) -> Dictionary:
	prog += 0.2
	if(prog > 1.0):
		prog = 1.0
	return {
		effects = [
			charEffect("skin", "SkinSet", [pickedSkin if prog >= 0.5 else "", pickedColors, prog]),
		]
	}


func reactProgressShort(_context:Dictionary, _result:TFResult):
	reactProgress(_context, _result)

func reactProgress(_context:Dictionary, _result:TFResult):
	if(isFirstTime()):
		addText("Right before {npc.yourHis} eyes, the colors of {npc.yourHis} skin begin to change. Subtly.. but it's still obvious. Warm glow pulses inside {npc.youHim}.. This is probably just the beginning.")
	elif(prog >= 1.0):
		addText("The colors of {npc.yourHis} skin shift.. and the glow fades, signaling that the transformation has finished.")
	else:
		addText("The colors of {npc.yourHis} skin change more and more, slowly shifting towards their final state.")
	
	playAnim(StageScene.Solo, "struggle", {bodyState={naked=true}})
	
func getBuffs() -> Array:
	return []

func saveData() -> Dictionary:
	var data:Dictionary = .saveData()
	
	data["ps"] = pickedSkin
	var pickedColorsStrs:Array = []
	for color in pickedColors:
		pickedColorsStrs.append(color.to_html())
	data["pcs"] = pickedColorsStrs
	data["prog"] = prog
	
	return data

func loadData(_data:Dictionary):
	.loadData(_data)
	
	pickedSkin = SAVE.loadVar(_data, "ps", "")
	var pickedColorsStrs = SAVE.loadVar(_data, "pcs", [])
	pickedColors = []
	for colorStr in pickedColorsStrs:
		pickedColors.append(Color(colorStr))
	prog = SAVE.loadVar(_data, "prog", 0.0)
