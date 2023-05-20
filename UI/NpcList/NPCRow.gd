extends PanelContainer

onready var _npcNameLabel = $HBoxContainer/Name
onready var _npcGenderLabel = $HBoxContainer/Gender
onready var _npcPersonalityLabel = $HBoxContainer/Personality
onready var _amountOfChildrenLabel = $HBoxContainer/Children
onready var meetButton = $HBoxContainer/CenterContainer2/Meet
onready var forgetButton = $HBoxContainer/CenterContainer/Forget
var _npcID: String


#func _ready():


func setName(name: String):
	_npcNameLabel.text = name


func setGender(gender: String):
	_npcGenderLabel.text = gender


func setPersonality(personality: String):
	_npcPersonalityLabel.text = personality


func setChildren(children):
	_amountOfChildrenLabel.text = String(children)


func setNpcID(ID: String):
	if(_npcID == null):
		push_error("Attempt to delete null NPC in the NPC list")
	else:
		_npcID = ID


func getNpcID():
	if(_npcID != null):
		return _npcID
	else: print("NPCRow: NPC ID is missing")


func _on_Forget_pressed():
	GM.ui.npcListScreen.forgetNPC(_npcID)
	queue_free()
#	GM.ui.npcListScreen.updateData()
	

