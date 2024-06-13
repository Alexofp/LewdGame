extends Reference
class_name RestraintData

var level: int = 0
var tightness: float = 1.0
var lockStrength: float = 0.0 
var lockType: String = ""
var item: WeakRef
var npcDodgeDifficultyMod: float = 1.0
var npcAiScoreMod: float = 1.0
var restraintType = RestraintType.Generic

func getItem():
	return item.get_ref()

func resetOnNewDay():
	tightness = 1.0

func resetOnNewTry():
	pass
	#tightness = 1.0

func onStruggleRemoval():
	tightness = 1.0

func onLockPicked():
	return

func getTightness():
	return tightness

func setLevel(newlevel):
	level = newlevel
	
func getLevel():
	return level

func getVisibleLevel(isBlind = false):
	if(isBlind && !canInspectWhileBlindfolded()):
		return "???"
	return str(level)

func canInspectWhileBlindfolded():
	return false

func canBeEasilyRemovedByDom():
	return canStruggle()

func getDodgeDifficulty():
	return 1.0 * Util.maxi(1, level) * npcDodgeDifficultyMod

func getFinalChanceToForceARestraint(_pc):
	var dodgeChance = _pc.getDodgeChance()
	var restraintDodgeDifficulty = getDodgeDifficulty()
	var finalSuccessChance = _pc.getRestraintResistance() * (1.0 / restraintDodgeDifficulty) * (1.0 - dodgeChance)

	return finalSuccessChance

func getLevelDamage():
	return 0.5 / pow(max(1.0, level), 0.8)

func getStatDamageMult(_pc):
	return 1.0 + _pc.getStat(Stat.Strength) / 20.0

func calcDamage(_pc, mult = 1.0):
	return mult * getLevelDamage() * getStatDamageMult(_pc) * RNG.randf_range(0.8, 1.0)

func takeDamage(howMuch):
	tightness -= howMuch
	if tightness > 1.0:
		tightness = 1.0

func takeLockDamage(howMuch):
	lockStrength -= howMuch
	if lockStrength > 1.0:
		lockStrength = 1.0
	if lockStrength < 0:
		lockStrength = 0.0

func shouldBeRemoved():
	return tightness <= 0

func getRemoveMessage():
	return getItem().getVisibleName()+" slips off!"

func getLockpickedMessage():
	return "Lock on" + getItem().getVisibleName() + " sucessfuly picked!"

func canStruggle():
	return true

func failChance(_pc, chance):
	return RNG.chance(chance)

func luckChance(_pc, chance):
	return RNG.chance(chance)

func fatalFail(_minigame):
	return _minigame < 0.0

func scaleDamage(dam) -> int:
	return int(round(getLevel() / 3.0 * dam))

func shouldDoStruggleMinigame(_pc):
	return true

func calculateAIScore(_pc):
	if(!shouldDoStruggleMinigame(_pc)):
		return 5.0 * npcDodgeDifficultyMod
	
	var result = 1.0
	if(!_pc.isBlindfolded() || canInspectWhileBlindfolded()):
		result = result * 2.0 / float(level)
	if(tightness > 0.0):
		result /= tightness
	
	return result * npcDodgeDifficultyMod

#Advanced negavive values for more fun in case of fatal fail
func doFailingStruggle(_pc, _minigame):
	var _handsFree = !_pc.hasBlockedHands()
	var _armsFree = !_pc.hasBoundArms()
	var _legsFree = !_pc.hasBoundLegs()
	var _canSee = !_pc.isBlindfolded()
	var _canBite = !_pc.isBitingBlocked()
	
	var text = "error?"
	var lust = 0
	var pain = 0
	var damage = 0
	var stamina = 0
	
	text = "You fail while trying to make "+getItem().getVisibleName()+" slip off"
	stamina = 10 + 4 * level
	
	return {"text": text, "damage": damage, "lust": lust, "pain": pain, "stamina": stamina}

func doStruggle(_pc, _minigame):
	var _handsFree = !_pc.hasBlockedHands()
	var _armsFree = !_pc.hasBoundArms()
	var _legsFree = !_pc.hasBoundLegs()
	var _canSee = !_pc.isBlindfolded()
	var _canBite = !_pc.isBitingBlocked()
	
	var text = "error?"
	var lust = 0
	var pain = 0
	var damage = 0
	var lockDamage = 0.0
	var stamina = 5 + 3 * level
	text = "You struggle, trying to make the "+getItem().getVisibleName()+" slip off"
	
	damage = calcDamage(_pc)
	if isLocked():
		lockDamage = RNG.randf_rangeDis(0, damage / 5) 
	
	#damage = calcDamage()
	
	return {"text": text, "damage": damage, "lockDamage": lockDamage, "lust": lust, "pain": pain, "stamina": stamina}

func doLockpick(_pc, _minigame):	
	var lust = 0
	var pain = 0
	var damage = 0
	var lockDamage = 0.0
	var stamina = 5 + 2 * level
	var text = "You picking the lock, trying to unlock the " + getItem().getVisibleName()
	
	lockDamage = _minigame
		
	return {"text": text, "damage": damage, "lockDamage": lockDamage, "lust": lust, "pain": pain, "stamina": stamina}

func doCut(_pc, _minigame):	
	var lust = 0
	var pain = 0
	var damage = 0.0
	var lockDamage = 0.0
	var stamina = 5 + 2 * level
	var text = "You are looking a good place to cut, trying to rid off the " + getItem().getVisibleName()
	
	damage = _minigame
	
	return {"text": text, "damage": damage, "lockDamage": lockDamage, "lust": lust, "pain": pain, "stamina": stamina}


func processStruggleTurn(_pc, _isActivelyStruggling):
	return null#{"text": "TEST "+getItem().getVisibleName()}

func processLockpickTurn(_pc, _isActive):
	return null

func processCutTurn(_pc, _isActive):
	return null

func getVisibleTightness():
	if(tightness > 0.9):
		return "sits very tight"
	if(tightness > 0.8):
		return "sits tight"
	if(tightness > 0.7):
		return "sits kinda tight"
	if(tightness > 0.6):
		return "gives in a little bit"
	if(tightness > 0.5):
		return "gives some leeway"
	if(tightness > 0.4):
		return "quite a bit of leeway"
	if(tightness > 0.3):
		return "feels slightly loose"
	if(tightness > 0.2):
		return "kinda loose"
	if(tightness > 0.1):
		return "pretty loose"
	return "extremely loose"

func getVisibleLockStrength():
	if(lockStrength > 0.9):
		return "securely locked"
	if(tightness > 0.5):
		return "slightly loose"
	if(tightness > 0.2):
		return "somewhat damaged"
	return "almost unlocked"

func getTightnessPercentString():
	return str(round(tightness*100.0))+"%"

func getLockPercentString():
	return str(round(lockStrength*100.0))+"%"

func isLocked():
	return lockStrength > 0

func getLockType():
	return lockType

func canUnlockWithKey():
	return true

func canBeCut():
	return false

func canBeLocked():
	return canUnlockWithKey()

func lockIt(_type = "common", _strength = 1.0):
	lockType = _type
	lockStrength = _strength

func reLockIt(_strength = 1.0):
	lockStrength = _strength
	
func alwaysSavedWhenStruggledOutOf():
	return false

func alwaysBreaksWhenStruggledOutOf():
	return false

func getRestraintType():
	return restraintType

func getResistAnimation():
	return "struggle"

func saveData():
	var data = {}
	
	data["level"] = level
	data["tightness"] = tightness
	data["lockStrength"] = lockStrength
	data["lockType"] = lockType

	return data
	
func loadData(_data):
	level = SAVE.loadVar(_data, "level", 1)
	tightness = SAVE.loadVar(_data, "tightness", 1.0)
	lockStrength = SAVE.loadVar(_data, "lockStrength", 0.0)
	lockType = SAVE.loadVar(_data, "lockType", "")
