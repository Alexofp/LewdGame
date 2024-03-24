extends RestraintLegCuffs
class_name RestraintLegCuffsZip

func _init():
	npcDodgeDifficultyMod = 1.1
	restraintType = RestraintType.AnkleCuffsZip

func canUnlockWithKey():
	return false

func canBeCut():
	return true

func canBeLocked():
	return false
