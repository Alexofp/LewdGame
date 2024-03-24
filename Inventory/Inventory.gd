extends Node
class_name Inventory

var items = []
var equippedItems = {}

signal equipped_items_changed

func _ready():
	name = "Inventory"

func addItem(item: Reference):
	if(item.currentInventory != null):
		assert(false)
	
	if(item.canCombine()):
		for myitem in items:
			if(myitem.id == item.id):
				if(myitem.tryCombine(item)):
					#item.queue_free()
					return
		
	items.append(item)
	item.currentInventory = self

func hasItem(item):
	return items.has(item)

func hasItemID(itemID: String):
	for item in items:
		if(item.id == itemID):
			return true
	return false

func getItems():
	return items

func getAllItems():
	return items

func getEquippedItems():
	return equippedItems

func getAllSellableItems():
	var result = []
	for item in items:
		if(item.canSell()):
			result.append(item)
	return result

func getItemsAndEquippedItemsTogether():
	var result = []
	result.append_array(equippedItems.values())
	result.append_array(items)
	return result

func getItemsAndEquippedItemsTogetherGrouped():
	var result = {}
	for item in equippedItems.values():
		result["%$%"+item.id] = [item]
	
	for item in items:
		if(!result.has(item.id)):
			result[item.id] = [item]
		else:
			result[item.id].append(item)
	
	return result

func getAllOf(itemID: String):
	var result = []
	
	for item in items:
		if(item.id == itemID):
			result.append(item)
	
	return result
	
func getFirstOf(itemID: String):
	for item in items:
		if(item.id == itemID):
			return item
	return null

func hasItemWithUniqueID(uniqueID: String):
	for item in items:
		if(item.uniqueID == uniqueID):
			return true
	return false

func getItemByUniqueID(uniqueID: String):
	for item in items:
		if(item.uniqueID == uniqueID):
			return item
			
	for slot in equippedItems.keys():
		var item = equippedItems[slot]
		if(item.uniqueID == uniqueID):
			return item
	return null

func getEquippedItemByUniqueID(uniqueID: String):
	for slot in equippedItems.keys():
		var item = equippedItems[slot]
		if(item.uniqueID == uniqueID):
			return item
	return null

func getEquippedItemByID(theID: String):
	for slot in equippedItems.keys():
		var item = equippedItems[slot]
		if(item.id == theID):
			return item
	return null

func removeItem(item):
	if(items.has(item)):
		items.erase(item)
		item.currentInventory = null
		return item
	return null

func removeXFromItemOrDelete(item, amount):
	assert(items.has(item))
	
	item.removeXOrDestroy(amount)

func getAmountOf(itemID):
	var item = getFirstOf(itemID)
	if(item == null):
		return 0
	return item.amount

func getUniqueAmountOf(itemID):
	var result = 0
	for item in items:
		if(item.id == itemID):
			result += 1
	return result

func hasXOf(itemID, amount):
	var item = getFirstOf(itemID)
	if(item == null):
		return false
	if(item.amount >= amount):
		return true
	else:
		return false

func removeXOfOrDestroy(itemID, amount):
	var item = getFirstOf(itemID)
	if(item == null):
		return
	
	item.removeXOrDestroy(amount)

func getAllCombatUsableItems():
	var result = []
	
	for item in items:
		if(item.canUseInCombat()):
			result.append(item)
	
	return result
		
func getAllCombatUsableRestraints():
	var result = []
	
	for item in items:
		if(item.canForceOntoNpc()):
			result.append(item)
		
	return result
		
func getAllCombatUsableRestraintsForStaticNpc():
	var result = []
	
	for item in items:
		if(item.canForceOntoStaticNpc()):
			result.append(item)
		
	return result
		
func canEquipSlot(slot):
	if(get_parent() != null && get_parent().has_method("invCanEquipSlot")):
		return get_parent().invCanEquipSlot(slot)
	return true
		
func getCharacter():
	if(get_parent() != null):
		return get_parent()
	return null
		
func equipItem(item):
	if(hasItem(item)):
		removeItem(item)
	
	var slot = item.getClothingSlot()
	
	if(equippedItems.has(slot)):
		Log.printerr("Trying to equip an item to slot "+str(slot)+" when there is already an item")
		return false
		#assert(false)
	
	if(!canEquipSlot(slot)):
		return false
	
	equippedItems[slot] = item
	item.currentInventory = self
	#add_child(item)
	emit_signal("equipped_items_changed")
	return true

func unequipItem(item):
	var theitem = removeEquippedItem(item)
	if(theitem != null):
		addItem(theitem)
		return true
	return false

func clearSlot(slot):
	var theitem = removeItemFromSlot(slot)
	if(theitem != null):
		return true
	return false

func unequipSlot(slot):
	var theitem = removeItemFromSlot(slot)
	if(theitem != null):
		addItem(theitem)
		return true
	return false

func unequipSlotUnlessRestraint(slot):
	var theitem = getEquippedItem(slot)
	if(theitem != null):
		if(theitem.isRestraint()):
			return false
		
		return unequipItem(theitem)
	return false

func unequipSlotRemoveIfRestraint(slot):
	var theitem = getEquippedItem(slot)
	if(theitem == null):
		return false

	removeItemFromSlot(slot)
	if(!theitem.isRestraint() || theitem.isImportant()):
		addItem(theitem)
		return true

func forceEquipRemoveOther(item):
	var slot = item.getClothingSlot()
	
	if(hasSlotEquipped(slot)):
		removeItemFromSlot(slot)
	
	return equipItem(item)

func forceEquipStoreOther(item):
	var slot = item.getClothingSlot()
	
	if(hasSlotEquipped(slot)):
		var storedItem = removeItemFromSlot(slot)
		addItem(storedItem)
	
	return equipItem(item)

func forceEquipStoreOtherUnlessRestraint(item):
	var slot = item.getClothingSlot()
	
	if(hasSlotEquipped(slot)):
		var storedItem = removeItemFromSlot(slot)
		if(!storedItem.isRestraint() || storedItem.isImportant()):
			addItem(storedItem)
	
	return equipItem(item)
	
func equipItemBy(item, equipper):
	var success = equipItem(item)
	if(success):
		item.onEquippedBy(equipper, false)

func forceEquipByRemoveOther(item, forcer):
	var success = forceEquipRemoveOther(item)
	if(success):
		item.onEquippedBy(forcer, true)
		
func forceEquipByStoreOther(item, forcer):
	var success = forceEquipStoreOther(item)
	if(success):
		item.onEquippedBy(forcer, true)
		
func forceEquipByStoreOtherUnlessRestraint(item, forcer):
	var success = forceEquipStoreOtherUnlessRestraint(item)
	if(success):
		item.onEquippedBy(forcer, true)

func hasItemIDEquipped(itemID: String):
	for slot in equippedItems:
		var item = equippedItems[slot]
		if(item.id == itemID):
			return true
	return false

func hasSlotEquipped(slot):
	return equippedItems.has(slot) && equippedItems[slot] != null

func getEquippedItem(slot):
	if(equippedItems.has(slot)):
		return equippedItems[slot]
	return null

func getAllEquippedItems():
#	var result = []
#	for slot in equippedItems:
#		if(equippedItems[slot] == null):
#			continue
#		result.append(equippedItems[slot])
	
	return equippedItems

func removeItemFromSlot(slot):
	if(equippedItems.has(slot)):
		var item = equippedItems[slot]
		item.onUnequipped()
		equippedItems.erase(slot)
		item.currentInventory = null
		emit_signal("equipped_items_changed")
		return item
	return null

func removeEquippedItem(item):
	for slot in equippedItems.keys():
		var myitem = equippedItems[slot]
		
		if(myitem == item):
			item.onUnequipped()
			equippedItems.erase(slot)
			item.currentInventory = null
			emit_signal("equipped_items_changed")
			return item
	return null

func clear():
	for item in items:
		item.currentInventory = null
		#item.queue_free()
	items.clear()
	
	
	for itemSlot in equippedItems.keys():
		#equippedItems[itemSlot].queue_free()
		equippedItems[itemSlot].currentInventory = null
	equippedItems.clear()
	emit_signal("equipped_items_changed")

func clearEquippedItems():
	for itemSlot in equippedItems.keys():
		#equippedItems[itemSlot].queue_free()
		equippedItems[itemSlot].currentInventory = null
	equippedItems.clear()
	emit_signal("equipped_items_changed")
	
func clearEquippedItemsKeepPersistent():
	var persistent = {}
	for itemSlot in equippedItems.keys():
		#equippedItems[itemSlot].queue_free()
		if(equippedItems[itemSlot].isPersistent()):
			persistent[itemSlot] = equippedItems[itemSlot]
		else:
			equippedItems[itemSlot].currentInventory = null
	equippedItems.clear()
	equippedItems = persistent
	emit_signal("equipped_items_changed")

func getEquippedItemsWithBuff(buffID):
	var result = []
	for itemSlot in equippedItems.keys():
		var item = equippedItems[itemSlot]
		
		var buffs = item.getBuffs()
		
		for buff in buffs:
			if(buff.id == buffID):
				result.append(item)
				continue
	return result

func removeItemsList(itemsToDelete: Array):
	for item in itemsToDelete:
		removeItem(item)

func removeEquippedItemsList(itemsToDelete: Array):
	for item in itemsToDelete:
		removeEquippedItem(item)

func removeEquippedItemsWithBuff(buffID):
	var founditems = getEquippedItemsWithBuff(buffID)
	var hasItem = false
	if(founditems.size() > 0):
		hasItem = true
	removeEquippedItemsList(founditems)
	return hasItem

func getItemsWithTag(tag):
	var result = []
	for item in items:
		if(item.hasTag(tag)):
			result.append(item)
	return result
		
func getEquippedItemsWithTag(tag):
	var result = []
	for itemSlot in equippedItems.keys():
		var item = equippedItems[itemSlot]

		if(item.hasTag(tag)):
			result.append(item)
	return result
	
func hasEquippedItemWithTag(tag):
	for itemSlot in equippedItems.keys():
		var item = equippedItems[itemSlot]

		if(item.hasTag(tag)):
			return true
	return false
	
func getEquppedRestraints():
	var result = []
	
	for itemSlot in equippedItems:
		var item = equippedItems[itemSlot]
		if(item.isRestraint()):
			result.append(item)
	return result

func getEquippedRestraints():
	return getEquppedRestraints()

func hasRemovableRestraints():
	for itemSlot in equippedItems:
		var item = equippedItems[itemSlot]
		if(item.isRestraint()):
			var restraintData = item.getRestraintData()
			if(restraintData.canStruggle()):
				return true
	return false

func getEquppedRemovableRestraints():
	var result = []
	
	for itemSlot in equippedItems:
		var item = equippedItems[itemSlot]
		if(item.isRestraint()):
			var restraintData = item.getRestraintData()
			if(restraintData.canStruggle()):
				result.append(item)
	return result

func forceRestraintsWithTag(tag, amount = 1):
	var itemIDs = GlobalRegistry.getItemIDsByTag(tag)
	itemIDs.shuffle()
	var added = 0
	var result = []
	
	for itemID in itemIDs:
		var potentialItem = GlobalRegistry.getItemRef(itemID)
		if !RNG.chance(potentialItem.rarity()):
			continue
		
		var slot = potentialItem.getClothingSlot()
		if(slot == null || !canEquipSlot(slot)):
			continue
		
		if(hasSlotEquipped(slot)):
			var ourItem = getEquippedItem(slot)
			if(ourItem.isRestraint()):
				continue
		
		var newItem = GlobalRegistry.createItem(itemID)
		if(forceEquipStoreOther(newItem)):
			result.append(newItem)
			added += 1
			
			if(added >= amount):
				return result
	return result

func getFirstItemThatCoversBodypart(bodypartSlot):
	for inventorySlot in InventorySlot.getAll():
		if(!hasSlotEquipped(inventorySlot)):
			continue
		
		var item = getEquippedItem(inventorySlot)
		if(item.coversBodypart(bodypartSlot)):
			return item
	
	return null

func getRestraintsThatCanBeForcedDuringSex(tag):
	var itemIDs = GlobalRegistry.getItemIDsByTag(tag)
	var result = []
	
	for itemID in itemIDs:
		var potentialItem = GlobalRegistry.getItemRef(itemID)
		if !RNG.chance(potentialItem.rarity()):
			continue
		
		var slot = potentialItem.getClothingSlot()
		if(slot == null || !canEquipSlot(slot)):
			continue

		if(hasSlotEquipped(slot)):
			var ourItem = getEquippedItem(slot)
			if(ourItem.isRestraint()):
				continue
		
		var bodypartSlot = potentialItem.getRequiredBodypart()
		var coversItem = getFirstItemThatCoversBodypart(bodypartSlot)
		if(bodypartSlot != null && coversItem != null):
			if(coversItem.isRestraint()):
				continue
		
		result.append(itemID)
	return result

func getAmountOfRestraintsThatCanForceDuringSex(tag):
	return getRestraintsThatCanBeForcedDuringSex(tag).size()

func clearStaticRestraints():
	for slot in InventorySlot.getStatic():
		removeItemFromSlot(slot)

func hasLockedStaticRestraints():
	for slot in InventorySlot.getStatic():
		if(hasSlotEquipped(slot)):
			return true
	return false

func hasIllegalItems():
	for item in items:
		if(item.hasTag(ItemTag.Illegal)):
			return true

	for itemSlot in equippedItems.keys():
		var item = equippedItems[itemSlot]

		if(item.hasTag(ItemTag.Illegal)):
			return true
	return false

func findAndEquipInmateUniform():
	if(hasItemID("inmateuniform")):
		forceEquipStoreOtherUnlessRestraint(getFirstOf("inmateuniform"))
	elif(hasItemID("inmateuniformHighsec")):
		forceEquipStoreOtherUnlessRestraint(getFirstOf("inmateuniformHighsec"))
	elif(hasItemID("inmateuniformSexDeviant")):
		forceEquipStoreOtherUnlessRestraint(getFirstOf("inmateuniformSexDeviant"))

func removeBrokenDublicatedItems():
	var itemsToRemove = []
	var equippedItemsToRemove = []
	
	var seenIDS = {}
	for item in items:
		if(item.uniqueID == null || item.uniqueID == ""):
			continue
		
		if(seenIDS.has(item.uniqueID)):
			itemsToRemove.append(item)
		else:
			seenIDS[item.uniqueID] = true
	
	for slot in equippedItems.keys():
		var item = equippedItems[slot]
		
		if(item.uniqueID == null || item.uniqueID == ""):
			continue
		
		if(seenIDS.has(item.uniqueID)):
			equippedItemsToRemove.append(item)
		else:
			seenIDS[item.uniqueID] = true
	
	for item in itemsToRemove:
		Log.printerr("REMOVING DUBLICATED ITEM: "+item.id+" UNIQUE ID: "+str(item.uniqueID))
		removeItem(item)
	for equippedItem in equippedItemsToRemove:
		Log.printerr("REMOVING DUBLICATED ITEM: "+equippedItem.id+" UNIQUE ID: "+str(equippedItem.uniqueID))
		removeEquippedItem(equippedItem)

func removeRandomRestraints(removedRestraintsChance):
	var restraints = getEquppedRestraints()
	var howManyRemoved = 0
	if(restraints.size() > 0):
		for restraint in restraints:
			if(restraint.isImportant() || restraint.isPersistent()):
				continue
			
			var chanceModifier = 1.0
			var restraintData:RestraintData = restraint.getRestraintData()
			if(restraintData != null):
				chanceModifier /= restraintData.getLevel()
			
			if(RNG.chance(removedRestraintsChance * chanceModifier)):
				removeEquippedItem(restraint)
				howManyRemoved += 1
	
	return howManyRemoved

func saveData():
	var data = {}
	
	data["items"] = []
	
	for item in items:
		var itemData = {
			"id": item.id,
			"uniqueID": item.uniqueID,
		}
		itemData["data"] = item.saveData()
		
		data["items"].append(itemData)
	
	data["equipped_items"] = {}
	for slot in equippedItems:
		var item = equippedItems[slot]
		var itemData = {
			"id": item.id,
			"uniqueID": item.uniqueID,
		}
		itemData["data"] = item.saveData()
		
		data["equipped_items"][slot] = itemData
		
	return data
	
func loadData(data):
	clear()
	
	var loadedItems = SAVE.loadVar(data, "items", [])
	
	for loadedItem in loadedItems:
		var id = SAVE.loadVar(loadedItem, "id", "")
		var uniqueID = SAVE.loadVar(loadedItem, "uniqueID", "")
		var itemLoadedData = SAVE.loadVar(loadedItem, "data", {})
		
		var newItem: ItemBase = GlobalRegistry.createItem(id, false)
		if(newItem == null):
			Log.printerr("ITEM WITH ID "+str(id)+" WASN'T FOUND IN REGISTRY")
			continue
		if(uniqueID == null || uniqueID == ""):
			uniqueID = "item"+str(GlobalRegistry.generateUniqueID())
		newItem.uniqueID = uniqueID
		newItem.loadData(itemLoadedData)
		addItem(newItem)
		
	var loadedEquippedItems = SAVE.loadVar(data, "equipped_items", {})
	for loadedSlot in loadedEquippedItems:
		var loadedItem = loadedEquippedItems[loadedSlot]
		var id = SAVE.loadVar(loadedItem, "id", "")
		var uniqueID = SAVE.loadVar(loadedItem, "uniqueID", null)
		var itemLoadedData = SAVE.loadVar(loadedItem, "data", {})
		
		var newItem: ItemBase = GlobalRegistry.createItem(id, false)
		if(newItem == null):
			Log.printerr("ITEM WITH ID "+str(id)+" WASN'T FOUND IN REGISTRY")
			continue
		if(uniqueID == null || uniqueID == ""):
			uniqueID = "item"+str(GlobalRegistry.generateUniqueID())
		newItem.uniqueID = uniqueID
		newItem.loadData(itemLoadedData)
		equipItem(newItem)

func loadDataNPC(data, npc):
	if(true):
		var hasAnyInvData = data.has("equipped_items")
		loadData(data)
		if(!hasAnyInvData):
			npc.resetEquipmentHard() # Recreates all the equipped items because we need fresh uniqueIDs for the items
		return
	
	for item in items:
		item.currentInventory = null
	items.clear()
	for itemSlot in equippedItems.keys():
		if(equippedItems[itemSlot].uniqueID in [null, ""]):
			continue
		equippedItems[itemSlot].currentInventory = null
		equippedItems.erase(itemSlot)
	#equippedItems.clear()
	
	var loadedItems = SAVE.loadVar(data, "items", [])
	for loadedItem in loadedItems:
		var id = SAVE.loadVar(loadedItem, "id", "")
		var uniqueID = SAVE.loadVar(loadedItem, "uniqueID", "")
		var itemLoadedData = SAVE.loadVar(loadedItem, "data", {})
		
		var newItem: ItemBase = GlobalRegistry.createItem(id, false)
		if(newItem == null):
			Log.printerr("ITEM WITH ID "+str(id)+" WASN'T FOUND IN REGISTRY")
			continue
		newItem.uniqueID = uniqueID
		newItem.loadData(itemLoadedData)
		addItem(newItem)
	
	var loadedEquippedItems = SAVE.loadVar(data, "equipped_items", {})
	for loadedSlot in loadedEquippedItems:
		var loadedItem = loadedEquippedItems[loadedSlot]
		var id = SAVE.loadVar(loadedItem, "id", "")
		var uniqueID = SAVE.loadVar(loadedItem, "uniqueID", null)
		var itemLoadedData = SAVE.loadVar(loadedItem, "data", {})
		
		# Npc's 'default' equipped items
		if(uniqueID in [null, ""]):
			if(hasSlotEquipped(loadedSlot)):
				var currentItem: ItemBase = getEquippedItem(loadedSlot)
				
				if(currentItem.id != id):
					continue
				currentItem.loadData(itemLoadedData)
		# Anything player might have forced onto them
		else:
			if(!hasSlotEquipped(loadedSlot)):
				var newItem: ItemBase = GlobalRegistry.createItem(id, false)
				if(newItem == null):
					Log.printerr("ITEM WITH ID "+str(id)+" WASN'T FOUND IN REGISTRY")
					continue
				newItem.uniqueID = uniqueID
				newItem.loadData(itemLoadedData)
				equipItem(newItem)
	emit_signal("equipped_items_changed")
