extends TFBase

var newSpecies:Array = [Species.Canine]
var affectedSlots:Dictionary = {}

func _init():
	id = "SpeciesTF"

func start(_args:Dictionary):
	if(_args.has("species")):
		newSpecies = _args["species"] if (_args["species"] is Array) else [_args["species"]]
	else:
		var randomSpecies:String = GM.main.getEncounterSettings().generateSpeciesBlacklist(getChar().getSpecies())
		if(randomSpecies == ""):
			randomSpecies = Species.Canine
			doCancelDelayed()
		newSpecies = [randomSpecies]

func getSlotsToTransform() -> Array:
	return BodypartSlot.getAll()

func allowsRemovingParts() -> bool:
	return true

func getSlotsLeft() -> Array:
	var result:Array = []
	for bodypartSlot in getSlotsToTransform():
		if(bodypartSlot in [BodypartSlot.Hair, BodypartSlot.Vagina, BodypartSlot.Anus]):
			continue
		if(affectedSlots.has(bodypartSlot)):
			continue
		result.append(bodypartSlot)
	return result

func hasAnySlotsLeftToTranform() -> bool:
	var theChar:BaseCharacter = getChar()
	var allowsRemoving:bool = allowsRemovingParts()
	var slotsLeft:Array = getSlotsLeft()
	for bodypartSlot in slotsLeft:
		var possiblePartIDs:Dictionary = Bodypart.findPossibleBodypartIDsDict(bodypartSlot, theChar, newSpecies)
		if(!allowsRemoving && possiblePartIDs.has("") && theChar.hasBodypart(bodypartSlot)):
			possiblePartIDs.erase("")
		if(possiblePartIDs.empty()):
			continue
		
		var currentBodypart:Bodypart = theChar.getBodypart(bodypartSlot)
		var currPartID:String = "" if currentBodypart == null else currentBodypart.id
		
		if(!possiblePartIDs.has(currPartID)):
			return true
	return false
		
func shouldCancelItself() -> bool:
	for species in newSpecies:
		if(GlobalRegistry.getSpecies(species) == null):
			return true
	return false
		
func canTransformFurther() -> bool:
	if(!hasAnySlotsLeftToTranform()):
		return false
	return true#!isMaxStage()
	
func getTimerForStage(_theStage:int) -> int:
	if(_theStage == 0):
		return 120
	return 240
	
func doProgress(_context:Dictionary) -> Dictionary:
	var allowsRemoving:bool = allowsRemovingParts()
	var theSlots:Array = getSlotsLeft()
	theSlots.shuffle()
	var theChar:BaseCharacter = getChar()
	while(theSlots.size() > 0):
		var bodypartSlot = theSlots.pop_front()
		
		var possiblePartIDs:Dictionary = Bodypart.findPossibleBodypartIDsDict(bodypartSlot, theChar, newSpecies)
		if(!allowsRemoving && possiblePartIDs.has("") && theChar.hasBodypart(bodypartSlot)):
			possiblePartIDs.erase("")
		if(possiblePartIDs.empty()):
			continue
		
		var currentBodypart:Bodypart = theChar.getBodypart(bodypartSlot)
		var currPartID:String = "" if currentBodypart == null else currentBodypart.id
		
		if(possiblePartIDs.has(currPartID)):
			continue
		
		var newPartID:String = RNG.pickWeightedDict(possiblePartIDs)
		affectedSlots[bodypartSlot] = true
		
		return {
			slot = bodypartSlot,
			effects = [
				partEffect("newpart", bodypartSlot, "SwitchPart", [newPartID]),
				charEffect("speciescalc", "SpeciesCalculate", []),
			]
		}
	return {}

func reactProgress(_context:Dictionary, _result:TFResult):
	var slot = _result.getField("slot", BodypartSlot.Body)
	var showPenis:bool = _result.getField("showPenis", false)
	if(showPenis):
		slot = BodypartSlot.Penis
	
#	if(isFirstTime()):
#		addText(("Something is happening to your chest.."))
#	else:
#		addText("A sudden warmth envelops your chest, and you feel an electrifying tingling sensation that sends shivers down your spine.")
#
	addText(_result.getAllTFTexts())
	
	
	if(slot in [BodypartSlot.Head, BodypartSlot.Ears, BodypartSlot.Hair, BodypartSlot.Horns]):
		playAnim(StageScene.Solo, "struggle_gag")
	elif(slot == BodypartSlot.Legs):
		playAnim(StageScene.Solo, "struggle_legs")
	elif(slot in [BodypartSlot.Penis, BodypartSlot.Vagina, BodypartSlot.Anus]):
		playAnim(StageScene.GivingBirth, "birth", {bodyState={exposedCrotch=true, hard=true}})
	else:
		playAnim(StageScene.Solo, "struggle", {bodyState={naked=true}})
	
#
#func onSexEvent(_event : SexEvent):
#	var _npc = getChar()
#	if(_event.getType() in [SexEvent.BreastFeeding, SexEvent.BreastsGroped, SexEvent.BreastsPumpMilked]):
#		if(_event.getTargetChar() == _npc):
#			accelerateTimer(0.5)
