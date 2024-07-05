extends "res://Game/Datapacks/UI/CrotchCode/CodeBlockBase.gd"

var printSlot := CrotchSlotVar.new()

func getCategories():
	return ["Output"]

func _init():
	printSlot.setRawType(CrotchVarType.STRING)
	printSlot.setRawValue("")

func getType():
	return CrotchBlocks.CALL

func setBlock(theBlock):
	printSlot.setBlock(theBlock)

func execute(_contex:CodeContex):
	_contex.doPrint(str(printSlot.getValue(_contex)))

func getTemplate():
	return [
		{
			type = "label",
			text = "Print",
		},
		{
			type = "slot",
			id = "printSlot",
			slot = printSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "printSlot"):
		return printSlot
