extends ItemBase

func _init():
	id = HK_Item.ImaginaryAnkleCuffs

func getVisibleName():
	return "Real ankle cuffs"
	
func getDescription():
	return "A set of definitely real ankle cuffs."

func getClothingSlot():
	return InventorySlot.Ankles

func getBuffs():
	return [
		buff(Buff.RestrainedLegsBuff),
		]

func getTags():
	return [ItemTag.BDSMRestraint]

func getTakeOffScene():
	return "HK_HypnoCuffsScene"
	
func isRestraint():
	return true

func generateRestraintData():
	restraintData = HK_HypnoRestraint.new()
	restraintData.setLevel(1)

func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return "There are " + getAStackName() + " cuffs keeping your ankles together. When did those get there?"
	else:
		return "There are " + getAStackName() + " cuffs keeping {receiver.nameS} ankles together. When did those get there?"
		
func getUnriggedParts(_character):
	return {
		"ankle.L": ["res://Modules/HypnokinkModule/Items/HypnoRestraints/HypnoCuffModel.tscn"],
		"ankle.R": ["res://Modules/HypnokinkModule/Items/HypnoRestraints/HypnoCuffModel.tscn"],
	}

func updateDoll(doll: Doll3D):
	doll.setLegsCuffed(true)

func getChains():
	return [["res://Modules/HypnokinkModule/Items/HypnoRestraints/ImaginaryChain.tscn", "ankle.L", "ankle.R"]]
