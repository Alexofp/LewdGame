extends ItemBase

var tfID:String = ""
var tfArgs:Dictionary = {}

func _init():
	id = "TFPill"

func getVisibleName():
	return "Strange Pill"
	
func getDescription():
	return "A pill that lacks any labels or instructions. Who knows what it will do..\n[color=#"+Color.cyan.to_html()+"]This pill might have some kind of transformative effect on your body.[/color]"

func canUseInCombat():
	return true

func getTFID() -> String:
	if(tfID == ""):
		tfID = TFUtil.generateTFIDForAPill()
		if(tfID != ""):
			var tf = GlobalRegistry.getTransformationRef(tfID)
			if(tf != null):
				tfArgs = tf.generatePillArgs()
	return tfID

func setTFID(newTFID:String):
	tfID = newTFID
	tfArgs.clear()
	if(tfID != ""):
		var tf = GlobalRegistry.getTransformationRef(tfID)
		if(tf != null):
			tfArgs = tf.generatePillArgs()

func pillStartTF(_user) -> Array:
	var _id:String = getTFID()
	
	var tfHolder = _user.getTFHolder()
	
	if(tfID == "" || GlobalRegistry.getTransformationRef(tfID) == null || tfHolder == null || !tfHolder.canStartTransformation(tfID)):
		return [false, "{USER.You} {USER.youVerb('swallow')} the pill.. but nothing happens. Looks like {USER.youHe} got lucky!".replace("USER", _user.getID())]
	
	_user.getTFHolder().startTransformation(tfID, tfArgs)
	return [true, "{USER.You} {USER.youVerb('swallow')} the weird pill..".replace("USER", _user.getID())]

func useInCombat(_attacker, _receiver):
	removeXOrDestroy(1)
	return pillStartTF(_attacker)[1]

func getPossibleActions():
	return [
		{
			"name": "Consume",
			"scene": "UseItemLikeInCombatScene",
			"description": "Take the pill",
		},
	]

func getPrice():
	return 3

func canSell():
	return true

func canCombine():
	return false

#func tryCombine(_otherItem):
#	if(tfID == "" && _otherItem.tfID == ""):
#		return .tryCombine(_otherItem)
#	return false

func addsIntoxication():
	return 0.0

func getTimedBuffs():
	return [
	]

func getBuffsDurationSeconds():
	return 60*60*12

func getTimedBuffsTurns():
	return [
	]

func getBuffsDurationTurns():
	return 5

func getTags():
	return [
		#ItemTag.SoldByMedicalVendomat,
		ItemTag.SexEngineDrug,
		]

func getBuyAmount():
	return 1

func getSexEngineInfo(_sexEngine, _domInfo, _subInfo):
	#var sub:BaseCharacter = _subInfo.getChar()
	#var dom:BaseCharacter = _domInfo.getChar()
	
	return {
		"name": "Strange Pill",
		"usedName": "a strange pill",
		"desc": getDescription(),
		"scoreOnSub": 0.2,#_domInfo.goalsScoreMax({SexGoal.FuckVaginal: 1.0, SexGoal.FuckAnal: 0.5}, _subInfo.charID)*_domInfo.fetishScore({Fetish.Breeding: 1.0}),
		"scoreOnSelf": 0.0,
		"scoreSubScore": _subInfo.fetishScore({Fetish.TFReceiving: 1.0}),
		"canUseOnDom": true,
		"canUseOnSub": true,
		"maxUsesByNPC": 99,
		"sexgoal": SexGoal.UseTFDrug,
	}

func useInSex(_receiver):
	var _success:bool = pillStartTF(_receiver)[0]
	return {
		text = "Nothing happens at first.." if _success else "The pill has no effect.",
	}

func getItemCategory():
	return ItemCategory.Medical

func saveData():
	var data = .saveData()
	
	data["tfID"] = tfID
	data["tfArgs"] = tfArgs
	
	return data
	
func loadData(data):
	.loadData(data)
	
	tfID = SAVE.loadVar(data, "tfID", "")
	tfArgs = SAVE.loadVar(data, "tfArgs", {})
