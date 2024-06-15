extends RestraintHandCuffs
class_name RestraintHandCuffsZip

func _init():
	restraintType = RestraintType.WristCuffsZip

func canUnlockWithKey():
	return false

func canBeCut():
	return true

func canBeLocked():
	return false
