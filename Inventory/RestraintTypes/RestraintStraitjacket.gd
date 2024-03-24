extends RestraintData
class_name RestraintStraitjacket

func _init():
	npcDodgeDifficultyMod = 1.5
	restraintType = RestraintType.Straitjacket
	
func resetOnNewDay():
	pass

func canBeCut():
	return true

func calcCutDamage(_pc, mult = 1.0):
	return .calcCutDamage(_pc, mult) / 2.0

func calcStruggleStamina(_pc, mult = 1.0):
	return .calcStruggleStamina(_pc, mult * 1.5)
