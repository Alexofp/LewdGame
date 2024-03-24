extends ItemBase


func _init():
	id = "safetyCutter"

func getVisibleName():
	return "Safety cutter tool"
	
func getDescription():
	return "A small safety blade perfect for easy slicing through rope. It dulls quickly and becomes useless. You feel like you should keep some of these just in case."

func getPrice():
	return 5

func canSell():
	return true

func canCombine():
	return true

func getTags():
	return [
		ItemTag.SoldByGeneralVendomat,
		ItemTag.SoldByTheAnnouncer,
		]

func getInventoryImage():
	return "res://Images/Items/bdsm/safetycutter.png"
