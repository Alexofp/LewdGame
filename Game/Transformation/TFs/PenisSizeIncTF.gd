extends TFBase

var target:float = 0.0
var hasTarget:bool = false

func _init():
	id = "PenisSizeIncTF"
	
	pointsOnUnlock = 5

func getName() -> String:
	return "Increases length of penis"

func getPillName() -> String:
	return "SuperShaft"

func getUnlockData() -> Dictionary:
	return {
		eliza = "Fascinating! This pill appears to contain a blend of growth factors and vasodilators that could promote penile lengthening. When ingested, it will probably lead to a noticeable increase in size. I think I’ll call it.. 'SuperShaft.' If you want my advice.. A big cock sounds nice.. but at some point it hurts more than it pleases.",
	}

func getTFCheckTags() -> Dictionary:
	return {
		"penis": true,
	}

func getPillFluidsRequired() -> Dictionary:
	return {
		"Milk": 1200.0,
	}

func isPossibleFor(_char) -> bool:
	if(!_char.hasPenis()):
		return false
	if(hasTarget):
		return _char.getPenisSize() < target
	return true

func start(_args:Dictionary):
	if(_args.has("target")):
		hasTarget = true
		target = _args["target"]

func getPillOptions() -> Dictionary:
	var lengths:Array = [5.0, 8.0, 10.0, 12.0, 15.0, 18.0, 20.0, 22.0, 25.0, 28.0, 30.0]
	var lenArray:Array = []
	for theLen in lengths:
		lenArray.append([theLen, str(theLen)+"cm"])
	return {
		"target": {
			name = "Target",
			desc = "Whats the final penis length should be (This drug can only increase length).",
			value = 18.0,
			values = lenArray,
		},
	}

func canTransformFurther() -> bool:
	if(!getChar().hasPenis()):
		return false
	if(hasTarget):
		return getChar().getPenisSize() < target
	return .canTransformFurther()
	
func getMaxStage() -> int:
	return 3
	
func getTimerForStage(_theStage:int) -> int:
	if(_theStage == 0):
		return 300
	return 60*60*5
	
func doProgress(_context:Dictionary) -> Dictionary:
	if(hasTarget):
		var currentSize:float = getChar().getPenisSize()
		var delta:float = target - currentSize
		if(delta > 4.0):
			delta = 4.0
		if(delta < 0):
			delta = 0
		return {
			effects = [
				partEffect("penLen", BodypartSlot.Penis, "PenisLengthChange", [delta])
			]
		}
	return {
		effects = [
			partEffect("penLen", BodypartSlot.Penis, "PenisLengthChange", [RNG.randi_range(2, 4)])
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
	target = SAVE.loadVar(_data, "tt", 18.0)
