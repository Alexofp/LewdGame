extends ItemBase


func _init():
	id = "lockPicker"

func getVisibleName():
	return "Lock picking tool"
	
func getDescription():
	return "An universal one-time use tool that can pick simple locks, like the ones used on bondage gear. You feel like you should keep some of these just in case."

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
	return "res://Images/Items/bdsm/lockpicker.png"
