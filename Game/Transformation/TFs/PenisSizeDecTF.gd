extends TFBase

var target:float = 0.0
var hasTarget:bool = false

func _init():
	id = "PenisSizeDecTF"

func getName() -> String:
	return "Decreases length of penis"

func getPillName() -> String:
	return "ShrinkRay"

func getTFCheckTags() -> Dictionary:
	return {
		"penis": true,
	}

func isPossibleFor(_char) -> bool:
	if(!_char.hasPenis()):
		return false
	if(hasTarget):
		return _char.getPenisSize() > target
	if(_char.getPenisSize() <= 9):
		return false
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
			desc = "Whats the final penis length should be (This drug can only decrease length).",
			value = 10.0,
			values = lenArray,
		},
	}

func canTransformFurther() -> bool:
	if(hasTarget):
		return getChar().getPenisSize() > target
	if(!getChar().hasPenis() || getChar().getPenisSize() <= 9):
		return false
	return .canTransformFurther()
	
func getMaxStage() -> int:
	return 3
	
func getTimerForStage(_theStage:int) -> int:
	if(_theStage == 0):
		return 120
	return 240
	
func doProgress(_context:Dictionary) -> Dictionary:
	if(hasTarget):
		var currentSize:float = getChar().getPenisSize()
		var delta:float = target - currentSize
		if(delta < -4.0):
			delta = -4.0
		if(delta > 0):
			delta = 0
		return {
			effects = [
				partEffect("penLen", BodypartSlot.Penis, "PenisLengthChange", [delta])
			]
		}
	return {
		effects = [
			partEffect("penLen", BodypartSlot.Penis, "PenisLengthChange", [-RNG.randi_range(2, 4)])
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
