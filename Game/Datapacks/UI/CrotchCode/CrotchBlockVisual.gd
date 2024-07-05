extends Control

var isPickVersion = false
var id = "base"
var codeBlock
onready var template_vertical_list = $HBoxContainer/TemplateVerticalList
var parentSlot

var editor

func get_drag_data(_position):
	#if(!isPickVersion):
	#	return null
	var mydata = {
		id = id,
		ref = self,
	}
	if(isPickVersion):
		mydata["block"] = CrotchBlocks.createBlock(id)
		codeBlock = mydata["block"]
		codeBlock.updateEditor(editor)
	else:
		mydata["block"] = codeBlock
	#set_drag_preview(make_preview(mydata))
	var thePreview = duplicate(0)
	thePreview.set_script(null)
	thePreview.modulate = Color(1.0, 1.0, 1.0, 0.5)
	set_drag_preview(thePreview)
	#print("BEGAN DRAG!")
	GlobalSignals.emitOnDragStarted()
	return mydata

func setIsSpawned():
	isPickVersion = false

func setIsPickedVersion():
	isPickVersion = true

func setCodeBlock(newCodeBlock):
	codeBlock = newCodeBlock
	constructTemplate()

func constructTemplate():
	Util.delete_children(template_vertical_list)
	
	if(codeBlock.shouldExpandTemplate()):
		makeExpand()
	
	var theType = codeBlock.getType()
	$HBoxContainer/DragLabel.text = CrotchBlocks.getLeftBracket(theType)
	$HBoxContainer/DragLabel2.text = CrotchBlocks.getRightBracket(theType)
	
	var theTemplate = codeBlock.getTemplate()
	var currentHBox:HBoxContainer = HBoxContainer.new()
	template_vertical_list.add_child(currentHBox)
	
	for templateLine in theTemplate:
		var templateType = templateLine["type"]
		
		if(templateType == "label"):
			var newLabel = Label.new()
			currentHBox.add_child(newLabel)
			newLabel.text = templateLine["text"]
		if(templateType == "rawstring"):
			var newRawString = preload("res://Game/Datapacks/UI/CrotchCode/VisualSlots/VisRawString.tscn").instance()
			currentHBox.add_child(newRawString)
			newRawString.setValue(templateLine["value"])
			newRawString.id = templateLine["id"]
			newRawString.connect("onValueChanged", codeBlock, "applyRawValue")
		if(templateType == "rawint"):
			var newRawString = preload("res://Game/Datapacks/UI/CrotchCode/VisualSlots/VisRawInt.tscn").instance()
			currentHBox.add_child(newRawString)
			newRawString.setValue(templateLine["value"])
			newRawString.id = templateLine["id"]
			newRawString.connect("onValueChanged", codeBlock, "applyRawValue")
		if(templateType == "slot"):
			var slotID = templateLine["id"]
			#currentHBox = HBoxContainer.new()
			#template_vertical_list.add_child(currentHBox)
			var newSlotVis = load("res://Game/Datapacks/UI/CrotchCode/VisualSlots/VisSlotVar.tscn").instance()
			newSlotVis.editor = editor
			currentHBox.add_child(newSlotVis)
			if(templateLine.has("slotType")):
				newSlotVis.setSideLabelsType(templateLine["slotType"])
			if(templateLine.has("extraType")):
				newSlotVis.setExtraMode(templateLine["extraType"])
			if(templateLine.has("expand") && templateLine["expand"]):
				newSlotVis.makeExpand()
			newSlotVis.setSlotVar(codeBlock.getSlot(slotID))
			codeBlock.updateVisualSlot(editor, slotID, newSlotVis)
		if(templateType == "slot_list"):
			var slotID = templateLine["id"]
			currentHBox = HBoxContainer.new()
			template_vertical_list.add_child(currentHBox)
			var newSlotVis = load("res://Game/Datapacks/UI/CrotchCode/VisualSlots/VisSlotCalls.tscn").instance()
			newSlotVis.editor = editor
			currentHBox.add_child(newSlotVis)
			newSlotVis.setSlotCalls(codeBlock.getSlot(slotID))
			currentHBox = HBoxContainer.new()
			template_vertical_list.add_child(currentHBox)
			
			#var curVal = codeBlock.data[templateLine[1]]
			#if(curVal is CrotchBlock):
			#	var newScene = curVal.createVisualScene()
				
			
			#var newEdit = LineEdit.new()
			#currentHBox.add_child(newEdit)
			#newEdit.text = templateLine[3]
			pass

func doSelfdelete():
	if(isPickVersion):
		return
	if(parentSlot != null):
		parentSlot.removeBlock(codeBlock)

func setParentVisSlot(theParentSlot):
	parentSlot = theParentSlot

func setErrored():
	self_modulate = Color.red

func resetErrored():
	self_modulate = Color.white

func makeExpand():
	size_flags_horizontal = SIZE_EXPAND_FILL


func _on_PopupMenu_index_pressed(index):
	if(index == 0):
		doSelfdelete()

var lastRightClick = 0
func _on_CrotchBlock_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_RIGHT:
			if((Time.get_ticks_msec() - lastRightClick) < 400.0):
				doSelfdelete()
			else:
				lastRightClick = Time.get_ticks_msec()
