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

class ResponseData:

	# response
	var text: Array
	var damage: float = 0.0
	var lockDamage: float = 0.0
	var lust: int = 0
	var pain: int = 0
	var stamina: int = 0
	
	# prosessing data
	var fail = "" # force | never
	var fatal = "" # force | never
	var success = "" # force | never
	var lock = "" # ignore | break | resist
	var replace = true # additional replace
	var use = []
	var flow = []
	var name: String
	
	func _init(_name: String):
		name = _name

	# skip rest of processing except after part
	func skipRest():
		fail = "never"
		fatal = "never"
		success = "never"
	

	func build():
		var _text = "|".join(text)
		_text = _text.replace(".| ", " ").replace("!| ", " ").replace(" | ", " ")
		_text = _text.replace("| ", " ").replace(" |", " ")
		_text = _text.replace("|", " ")
		
		_text = _text.replace("{item.name}", name).strip_edges()
		return {"text": _text, "damage": damage, "lockDamage": lockDamage, "lust": lust, "pain": pain, "stamina": stamina}


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

# level dependent general multiplier, 1 to 20 (inf), higher for higher levels
func getLevelMultiplier(scale = 1.0):
	return scale * (0.6 + pow(max(1.0, level) / 2.0, 1.2))

# level dependent durability multiplier defaul for all damages, 1 to 0.1 (0), for higher levels is result lower
func getLevelDamage(scale = 1.0):
	return scale * (1.3 / pow(0.4 + max(1.0, level), 0.8))

# strength multiplier, defaul all struggle
func getStrengthDamageMult(_pc):
	return (10.0 + pow(max(1.0,_pc.getStat(Stat.Strength)), 0.8)) / 10.0

# agility multiplier, defaul all lockpick
func getAgilityDamageMult(_pc):
	return (10.0 + pow(max(1.0,_pc.getStat(Stat.Agility)), 0.8)) / 10.0

# strength plus agility multipier, defaul all cut 
func getMixedDamageMult(_pc):
	return (10.0 + pow(max(1.0, _pc.getStat(Stat.Strength)/2.0 + _pc.getStat(Stat.Agility)/2.0 ), 0.8)) / 10.0

# main damage for struggle - reflecting level and ability
func calcStruggleDamage(_pc, mult = 1.0):
	if _pc.hasPerk(Perk.BDSMPerfectStreak):
		return mult * getLevelDamage() * (getStrengthDamageMult(_pc) + 0.5)
	return mult * getLevelDamage() * getStrengthDamageMult(_pc)	

# site damage for struggle, releases the lock - reflecting level and ability
func calcLockDamage(_pc, mult = 1.0):
	return mult * getLevelDamage() * getStrengthDamageMult(_pc)

# main damage for lockpick - reflecting level and ability
func calcPickDamage(_pc, mult = 1.0):
	return mult * getLevelDamage() * getAgilityDamageMult(_pc)

# main damage for cut - reflecting level and ability
func calcCutDamage(_pc, mult = 1.0):
	return mult * getLevelDamage() * (getMixedDamageMult(_pc) + 1.0)


# reduces the success rate according to other restrictions, includes abilities, 1 to 0.1 (0) lower is worse
func calcRestrainMult(_pc, _minigame):
	var mult = 1.0
	if _pc.isBlindfolded():
		if _pc.hasPerk(Perk.BDSMBlindfold):
			mult = 0.9
		mult = 0.8

	if _pc.hasBoundArms() && _pc.hasBlockedHands():
		if _pc.hasPerk(Perk.BDSMPerfectStreak):
			mult *= 0.6
		else:
			mult *= 0.4
	elif _pc.hasBoundArms() || _pc.hasBlockedHands():
		if _pc.hasPerk(Perk.BDSMPerfectStreak):
			mult *= 0.8
		else:
			mult *= 0.6
	return mult

# true if it is possible to break the lock by struggling
func canBreakLock(_pc, _minigame):
	return _minigame > 0.8 

# struggling multiplier for locked things
func calcLockedMult(_pc, _minigame):
	var mult = 0
	if _minigame > 0.8:
		mult = _minigame - 0.8
	return mult

# injury for fatal failure when cutting
func calcFatalCutPain(_pc, _minigame):
	return 5 + -_minigame * 5.0
	
	
# used stamina for struggling, reflecting level and ability
func calcStruggleStamina(_pc, mult = 1.0):
	if _pc.hasPerk(Perk.BDSMBetterStruggling):
		return mult * (5 + getLevelMultiplier(2.0)) 
	return mult * (10 + getLevelMultiplier(4.0))

# used stamina for lockpicking, reflecting level and ability
func calcPickStamina(_pc, mult = 1.0):
	return mult * (5 + level * 2)

# used stamina for cutting, reflecting level and ability
func calcCutStamina(_pc, mult = 1.0):
	if _pc.hasPerk(Perk.BDSMBetterStruggling):
		return mult * (5 + getLevelMultiplier(2)) 
	return mult * (5 + getLevelMultiplier(3))


# pain received during struggling 
func calcStrugglePain(_pc, mult = 1.0):
	return mult * (5 + getLevelMultiplier(2))

# pain received during lockpickinging
func calcPickPain(_pc, mult = 1.0):
	return mult * (5 + getLevelMultiplier(1))

# pain received during cutting
func calcCutPain(_pc, mult = 1.0):
	return mult * (10 + getLevelMultiplier(3))


# lust received during struggling
func calcStruggleLust(_pc, mult = 1.0):
	return mult * (10 + getLevelMultiplier(3))

# lust received during lockpickinging
func calcPickLust(_pc, mult = 1.0):
	return mult * (5 + getLevelMultiplier(1))

# lust received during cutting
func calcCutLuist(_pc, mult = 1.0):
	return mult * (5 + getLevelMultiplier(2))


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

func failChanceZoned(_pc, _minigame, chance):
	if fatalFail(_minigame):
		return RNG.chance(chance) || RNG.chance(chance) || RNG.chance(chance)
	if fail(_minigame):
		return RNG.chance(chance) || RNG.chance(chance)
	return RNG.chance(chance)

func luckChance(_pc, chance):
	return RNG.chance(chance)

func fatalFail(_minigame):
	return _minigame < 0.0

func fail(_minigame):
	return _minigame == 0.0

func success(_minigame):
	return _minigame > 0.0

#deprecated
func scaleDamage(dam) -> int:
	return int(round(getLevel() / 3.0 * dam))

func shouldDoStruggleMinigame(_pc):
	return true

func canInstantEscape(_pc):
	if _pc.hasPerk(Perk.BDSMInstantEscape) && !isLocked() && level < RNG.randf_rangeDis(0, _pc.getLevel()):
		return RNG.chance(50)
	return false

func calculateAIScore(_pc):
	if(!shouldDoStruggleMinigame(_pc)):
		return 5.0 * npcDodgeDifficultyMod
	
	var result = 1.0
	if !_pc.isBlindfolded() || canInspectWhileBlindfolded():
		result = result * 2.0 / float(level)
	if tightness > 0.0:
		result /= tightness
	
	return result * npcDodgeDifficultyMod

### strugle, minigame score  0> sucess, <0 fatal fail ###  
func doStruggle(_pc, _minigame):
	var response =  beforeStruggle(_pc, _minigame)
	response =  defaultStruggle(_pc, _minigame, response)
	
	if (fatalFail(_minigame) && response.fatal != "never") || response.fatal == "force":
		response.use.append("fatal")
		response = fatalFailStruggle(_pc, _minigame, response)
		response = commonFailStruggle(_pc, _minigame, response)
	
	elif (fail(_minigame) && response.fail != "never") || response.fail == "force":
		response.use.append("fail")
		response = failStruggle(_pc, _minigame, response)
		response = commonFailStruggle(_pc, _minigame, response)
	
	elif (success(_minigame) && response.success != "never") || response.success == "force":
		response.use.append("success")
		if !isLocked() || response.lock == "ignore":
			response.use.append("ignore")
			response = sucessStruggle(_pc, _minigame, response)
	
		elif !canBreakLock(_pc, _minigame) || response.lock == "resist":
			response.use.append("resist")
			response = sucessStruggleLocked(_pc, _minigame, response)
	
		elif canBreakLock(_pc, _minigame) || response.lock == "break":
			response.use.append("break")
			response = sucessStruggleBreak(_pc, _minigame, response)
		response = commonSuccessStruggle(_pc, _minigame, response)
		
	response = afterStruggle(_pc, _minigame, response)
	return response

# called before struggling
func beforeStruggle(_pc, _minigame):
	return ResponseData.new(getItem().getVisibleName())

# called at begining of struggling
func defaultStruggle(_pc, _minigame, response):
	response.text.append("{user.youHe} struggle, trying to make the {item.name} slip off.")
	response.stamina += calcStruggleStamina(_pc, 1)
	return response
	
# fatal failed option for struggling
func fatalFailStruggle(_pc, _minigame, response):
	if tightness < 1.0:
		response.text.append(" but it seems like {user.youHe} just tightened it up more.")
	else:
		response.text.append(" but it seems like all {user.his} effort is in vain.")
	response.damage += calcStruggleDamage(_pc, _minigame / 4.0)
	response.stamina += calcStruggleStamina(_pc, 1)
	return response

# failed option for struggling
func failStruggle(_pc, _minigame, response):
	response.text.append(" but without visible effect.")
	return response
	
# successful struggle for unlocked stuff
func sucessStruggle(_pc, _minigame, response):
	response.damage += calcStruggleDamage(_pc, _minigame) * calcRestrainMult(_pc, _minigame)
	return response

# successful struggle for locked stuff, success thwarted by the lock
func sucessStruggleLocked(_pc, _minigame, response):
	response.text.append(" but the lock is too strong.")
	return response

# successful struggle despite the lock, lock at least partially overcome
func sucessStruggleBreak(_pc, _minigame, response):
	response.text.append(" but it would have been done better if only it was not locked.")
	var _mult = calcLockedMult(_pc, _minigame)
	response.damage += calcStruggleDamage(_pc, _mult) * calcRestrainMult(_pc, _minigame)
	response.lockDamage += calcLockDamage(_pc, _mult) * calcRestrainMult(_pc, _minigame)
	return response

# common failed option for struggling, executed after all fail
func commonFailStruggle(_pc, _minigame, response):
	if failChanceZoned(_pc, _minigame, 10) && response.use.has("bite"):
		response.text.append("Ow, {user.name} accidentally bit {user.himself}.")
		response.pain += calcStrugglePain(_pc, RNG.randi_range(2, 3))
	if failChanceZoned(_pc, _minigame, 10) && response.use.has("step"):
		response.text.append("Ow, {user.name} accidentally bit {user.himself}.")
		response.pain += calcStrugglePain(_pc, RNG.randi_range(1, 2))
	elif failChanceZoned(_pc, _minigame, 15) && response.use.has("smash"):
		response.text.append("Ow! {user.name} accidently smashed them against "+RNG.pick(["the wall", "the ground", "something"])+".")
		response.pain += calcStrugglePain(_pc, RNG.randi_range(1, 3))	
	return response

# common success option for struggling, executed after all sucess
func commonSuccessStruggle(_pc, _minigame, response):
	return response

# called after struggling
func afterStruggle(_pc, _minigame, response):
	if failChanceZoned(_pc, _minigame, 20) && response.use.has("bite"):
		response.text.append("{user.name} finds {user.himself} drooling a lot.")
		response.lust += calcStruggleLust(_pc, 2)
	return response


### use lockpick tool, minigame score  0> sucess, <0 fatal fail ###
func doLockpick(_pc, _minigame):
	var response = beforePick(_pc, _minigame)
	response = defaultPick(_pc, _minigame, response)
	
	if (fatalFail(_minigame) && response.fatal != "never") || response.fatal == "force":
		response.use.append("fatal")
		response = fatalFailPick(_pc, _minigame, response)
	
	elif (fail(_minigame) && response.fail != "never") || response.fail == "force":
		response.use.append("fail")
		response = failPick(_pc, _minigame, response)
	
	elif (success(_minigame) && response.success != "never") || response.success == "force":
		response.use.append("success")
		response = sucessPick(_pc, _minigame, response)
	
	response = afterPick(_pc, _minigame, response)
	return response

# called before lockpicking
func beforePick(_pc, _minigame):
	return ResponseData.new(getItem().getVisibleName())

# called at begining of lockpicking
func defaultPick(_pc, _minigame, response):
	response.text.append("{user.youHe} picking the lock, trying to unlock the {item.name}.")
	response.stamina += calcPickStamina(_pc, 1)
	return response

# called after lockpicking
func afterPick(_pc, _minigame, response):
	return response

# fatal failed option for lockpicking
func fatalFailPick(_pc, _minigame, response):
	response.text.append(" but it seems like {user.youHe} you've stuck the lock instead.")
	response.lockDamage = -1.0
	response.stamina = calcPickStamina(_pc, 2)
	return response

# fail option for lockpicking
func failPick(_pc, _minigame, response):
	response.text.append(" but without visible effect.")
	return response

# success option for lockpicking
func sucessPick(_pc, _minigame, response):
	response.text.append(" and it seems to be working.")
	response.lockDamage = calcPickDamage(_pc, _minigame) *  calcRestrainMult(_pc, _minigame)
	return response


### use cuting tool, minigame score  0> sucess, <0 fatal fail ###
func doCut(_pc, _minigame):
	var response = beforeCut(_pc, _minigame)
	response = defaultCut(_pc, _minigame, response)
	
	if (fatalFail(_minigame) && response.fatal != "never") || response.fatal == "force":
		response.use.append("fatal")
		response = fatalFailCut(_pc, _minigame, response)
	
	elif (fail(_minigame) && response.fail != "never") || response.fail == "force":
		response.use.append("fail")
		response = failCut(_pc, _minigame, response)
	
	elif (success(_minigame)  && response.success != "never") || response.success == "force":
		response.use.append("success")
		response = successCut(_pc, _minigame, response)

	response = afterCut(_pc, _minigame, response)
	return response

# called before cutting
func beforeCut(_pc, _minigame):
	return ResponseData.new(getItem().getVisibleName())

# called at begining of cutting
func defaultCut(_pc, _minigame, response):
	response.text.append("{user.youHe} looking for a good place to cut, trying to rid off the {item.name}.")
	response.stamina += calcCutStamina(_pc, 1)
	response.pain += calcCutPain(_pc, 1)
	return response

# called after cutting
func afterCut(_pc, _minigame, response):
	return response

# fatal failed option for cutting
func fatalFailCut(_pc, _minigame, response):
	response.text.append(" but instead the bondage gear {user.youHe} hurt self.")
	response.pain += calcFatalCutPain(_pc, _minigame)
	return response

# fail option for cutting
func failCut(_pc, _minigame, response):
	response.text.append(" but without visible effect.")
	return response

# success option for cutting
func successCut(_pc, _minigame, response):
	var _mult = calcLockedMult(_pc, _minigame)
	response.damage = calcCutDamage(_pc, _minigame) * calcRestrainMult(_pc, _minigame)
	return response


func processStruggleTurn(_pc, _isActivelyStruggling):
	return ResponseData.new(getItem().getVisibleName())

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

func canBeLockPicked():
	return canUnlockWithKey() && lockStrength > 0

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
