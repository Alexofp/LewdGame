extends "res://Scenes/SceneBase.gd"

var uniqueItemID = ""

func _init():
	sceneID = "PutOnAnyItemScene"

func _initScene(_args = []):
	if(_args.size() > 0):
		uniqueItemID = _args[0]
	
func _reactInit():
	if(uniqueItemID == null || uniqueItemID == ""):
		return
		
	var item: ItemBase = GM.pc.getInventory().getItemByUniqueID(uniqueItemID)
	if(item == null):
		return
	
	if(!GM.pc.hasBlockedHands()):
		if(GM.pc.hasBoundArms()):
			setState("awkwardputon")
		
		GM.pc.getInventory().removeItem(item)
		GM.pc.getInventory().equipItem(item)
		GM.pc.updateAppearance()
		GM.main.updateSubAnims()
		if item.isRestraint() && item.getRestraintData().canBeLocked() && RNG.chance(25):
			item.getRestraintData().lockIt()
	else:
		setState("blockedhands")

func _run():
	if(state == ""):
		if(uniqueItemID == null || uniqueItemID == ""):
			addButton("Continue", "Oops", "endthescene")
			return
		
		var item: ItemBase = GM.pc.getInventory().getItemByUniqueID(uniqueItemID)
		if(item == null):
			saynn("Error: no item found")
		else:
			saynn("You "+item.getPuttingOnStringLong(false))
		
		addButton("Continue", "You put on an item", "endthescene")

	if(state == "awkwardputon"):
		if(uniqueItemID == null || uniqueItemID == ""):
			addButton("Continue", "Oops", "endthescene")
			return
		
		var item: ItemBase = GM.pc.getInventory().getItemByUniqueID(uniqueItemID)
		if(item == null):
			saynn("Error: no item found")
		else:
			saynn("It's very awkward to do with bound arms but you just about managed. You "+item.getPuttingOnStringLong(false))
		
		addButton("Continue", "You put on an item", "endthescene")

	if(state == "blockedhands"):
		saynn("You really try to put that on but your blocked hands prevent you from doing so")
		
		addButton("Continue", "Aww", "endthescene")
		
func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	
	setState(_action)

func saveData():
	var data = .saveData()
	
	data["uniqueItemID"] = uniqueItemID
	
	return data
	
func loadData(data):
	.loadData(data)
	
	uniqueItemID = SAVE.loadVar(data, "uniqueItemID", "")
