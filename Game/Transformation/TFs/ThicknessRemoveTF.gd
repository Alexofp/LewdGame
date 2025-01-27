extends TFBase

var target:int = 0
var hasTarget:bool = false

func _init():
	id = "ThicknessRemoveTF"
	
	pointsOnUnlock = 5

func getName() -> String:
	return "Makes you thinner"

func getPillName() -> String:
	return "SliMM"

func getUnlockData() -> Dictionary:
	return {
		eliza = "This pill seems to be formulated with appetite suppressants and fat-burning compounds that could help you shed those extra pounds.. It's like one of those fake ad products.. but this one seems like it will actually work, huh. When taken, it will probably make you thinner.. so I really wanna call it.. 'SliMM'.",
	}

func getTFCheckTags() -> Dictionary:
	return {
		"thickness": true,
	}

func getPillFluidsRequired() -> Dictionary:
	return {
		"GirlCum": 300.0,
	}

func isPossibleFor(_char) -> bool:
	if(_char.getThickness() <= 0):
		return false
	if(hasTarget):
		return _char.getThickness() > target
	return true

func start(_args:Dictionary):
	if(_args.has("target")):
		hasTarget = true
		target = _args["target"]

func getPillOptions() -> Dictionary:
	var possibleVals:Array = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]
	var posVals:Array = []
	for theVal in possibleVals:
		posVals.append([theVal, str(theVal)+"%"])
	return {
		"target": {
			name = "Target",
			desc = "Whats the final thickness should be like (This drug can only lower thickness).",
			value = 50,
			values = posVals,
		},
	}

func canTransformFurther() -> bool:
	if(getChar().getThickness() <= 0):
		return false
	if(hasTarget):
		return getChar().getThickness() > target
	return .canTransformFurther()
	
func getMaxStage() -> int:
	return 3
	
func getTimerForStage(_theStage:int) -> int:
	if(_theStage == 0):
		return 300
	return 60*60*12
	
func doProgress(_context:Dictionary) -> Dictionary:
	if(hasTarget):
		var currentThickness:int = getChar().getThickness()
		var delta:int = target - currentThickness
		if(delta < -13):
			delta = -13
		if(delta > 0):
			delta = 0
		return {
			effects = [
				charEffect("thi", "AddThickness", [delta]),
			]
		}
	
	return {
		effects = [
			charEffect("thi", "AddThickness", [-RNG.randi_range(7, 13)]),
		]
	}

func reactProgress(_context:Dictionary, _result:TFResult):
	addText(_result.getAllTFTexts())
	
	playAnim(StageScene.GivingBirth, "birth", {bodyState={exposedCrotch=true, hard=true}})
	
func saveData() -> Dictionary:
	var data:Dictionary = .saveData()
	
	data["ht"] = hasTarget
	data["tt"] = target
	
	return data

func loadData(_data:Dictionary):
	.loadData(_data)
	
	hasTarget = SAVE.loadVar(_data, "ht", false)
	target = SAVE.loadVar(_data, "tt", 50)
