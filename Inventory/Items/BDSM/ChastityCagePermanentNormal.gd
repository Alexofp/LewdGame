extends ItemBase

func _init():
	id = "ChastityCagePermanentNormal"

func getVisibleName():
	return "Permanent Cage"
	
func getDescription():
	return "Prevents the ability to use your penis. Forever."

func getClothingSlot():
	return InventorySlot.Penis

func getRequiredBodypart():
	return BodypartSlot.Penis

func getBuffs():
	return [
		buff(Buff.ChastityPenisBuff),
		]

func getTakeOffScene():
	return "RestraintTakeOffNopeScene"

func getPrice():
	return 0

func canSell():
	return true

func getTags():
	return [ItemTag.BDSMRestraint, ItemTag.ChastityCage]

func isRestraint():
	return true

func generateRestraintData():
	restraintData = RestraintUnremovable.new()
	restraintData.setLevel(calculateBestRestraintLevel())
	restraintData.lockIt()

func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return getAStackNameCapitalize()+" was locked onto your penis, making it useless!"
	else:
		return getAStackNameCapitalize()+" was locked onto {receiver.nameS} penis, making it useless!"

func updateDoll(doll: Doll3D):
	doll.setState("cock", "caged")

func isImportant():
	return true

func getInventoryImage():
	return "res://Images/Items/bdsm/chastity_cage.png"
