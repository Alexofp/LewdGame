extends Control

########################
# testing game for dev #
########################

var level = 0


signal minigameCompleted(finalScore, result)

var finalScore = 0
var option = "default"

func _ready():
	Log.info("Testing game ready")
	Log.info("level " + str(level))
	optionMenu()

func _process(_delta):
	if _delta < 0:
		print("process..")

	
func _on_Buttonwin_pressed():
	print("Success")
	finalScore = 1
	emit_signal("minigameCompleted", finalScore, {option: true})
	
func _on_Buttonlose_pressed():
	print("Fail")
	finalScore = 0
	emit_signal("minigameCompleted", finalScore, {option: true})

func _on_Buttonfatal_pressed():
	print("Ftatal fail")
	finalScore = -1
	emit_signal("minigameCompleted", finalScore, {})

func _on_Buttoncustom_pressed():
	print("custom")
	finalScore = get_node("LineEdit-result").get_text()
	print(finalScore)
	emit_signal("minigameCompleted", finalScore, {option: true})


func optionMenu():
	get_node("MenuButton-options").get_popup().add_item("Strength")
	get_node("MenuButton-options").get_popup().add_item("Agility")
	get_node("MenuButton-options").get_popup().add_item("Time")
	get_node("MenuButton-options").get_popup().connect("id_pressed", self, "_on_item_selected")

func _on_item_selected(id):
	var _option = get_node("MenuButton-options").get_popup().get_item_text(id)
	print(_option)
	option = _option


func config(_params = {}):
	if(_params.has("level")):
		level = _params["level"]

