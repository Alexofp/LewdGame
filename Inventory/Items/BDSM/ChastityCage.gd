extends ItemBase

func _init():
	id = "ChastityCage"

func getVisibleName():
	return "Chastity Cage"
	
func getDescription():
	return "Prevents the ability to use your penis"

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
	return 10

func canSell():
	return true

func getTags():
	return [ItemTag.BDSMRestraint, ItemTag.CanBeForcedByGuards, ItemTag.ChastityCage, ItemTag.SoldByTheAnnouncer, ItemTag.CanBeForcedInStocks]

func isRestraint():
	return true

func generateRestraintData():
	restraintData = RestraintChastityCage.new()
	restraintData.setLevel(calculateBestRestraintLevel())
	restraintData.lockIt()

func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return getAStackNameCapitalize()+" was locked onto your penis, making it useless!"
	else:
		return getAStackNameCapitalize()+" was locked onto {receiver.nameS} penis, making it useless!"

func updateDoll(doll: Doll3D):
	doll.setState("cock", "caged")

func getAIForceItemWeight():
	return 0.2

func getInventoryImage():
	return "res://Images/Items/bdsm/chastity_cage.png"
