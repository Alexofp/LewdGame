extends "res://Inventory/Items/BDSM/InmateAnkleCuffs.gd"

func _init():
	id = "ZiptiesAnkle"

func getVisibleName():
	return "Zip ties (ankles)"
	
func getA():
	return ""
	
func getDescription():
	return "Bulky plastic restraints. Can be locked to bind legs together"

func getTakeOffScene():
	return "CuffTuggingScene"

func getTags():
	return [ItemTag.BDSMRestraint]

func getUnriggedParts(_character):
	return {
		"ankle.L": ["res://Inventory/UnriggedModels/ZipTies/ZipTiesModel.tscn"],
		"ankle.R": ["res://Inventory/UnriggedModels/ZipTies/ZipTiesModel.tscn"],
	}
	
func generateRestraintData():
	restraintData = RestraintLegCuffsZip.new()
	restraintData.setLevel(calculateBestRestraintLevel())

func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return "Some zip ties were forced onto your legs, forcing you to waddle or hop around!"
	else:
		return "Some zip ties were forced onto {receiver.nameS} legs, forcing {receiver.him} to waddle or hop around!"

func getInventoryImage():
	return "res://Images/Items/bdsm/ZipTies.png"
