extends "res://Inventory/Items/BDSM/InmateWristCuffs.gd"

func _init():
	id = "ZiptiesWrist"

func getVisibleName():
	return "Zip ties (wrists)"
	
func getA():
	return ""
	
func getDescription():
	return "Bulky plastic restraints. Can be locked to bind arms together"

func getTakeOffScene():
	return "CuffTuggingScene"

func getTags():
	return [ItemTag.BDSMRestraint]

func getUnriggedParts(_character):
	return {
		"wrist.L": ["res://Inventory/UnriggedModels/ZipTies/ZipTiesModel.tscn"],
		"wrist.R": ["res://Inventory/UnriggedModels/ZipTies/ZipTiesModel.tscn"],
	}

func generateRestraintData():
	restraintData = RestraintHandCuffsZip.new()
	restraintData.setLevel(calculateBestRestraintLevel())
	
func getForcedOnMessage(isPlayer = true):
	if(isPlayer):
		return "Some zip ties were forced onto your arms"
	else:
		return "Some zip ties were forced onto {receiver.nameS} arms"

func getInventoryImage():
	return "res://Images/Items/bdsm/ZipTies.png"
