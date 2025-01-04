extends ControllerButton

var savedKey = -1

signal pressedActually
var showingDescription = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var event: InputEventAction = self.shortcut.shortcut
	self.path = event.action

	var minButtonSize = OPTIONS.getUiButtonSize()
	if(minButtonSize > 0):
		rect_min_size = Vector2(0, 20 + minButtonSize * 16)

# Now unused in favor of ControllerButton handling
func setShortcutPhysicalScancode(code):
	print_debug("WARNING: setShortCutPhysicalScancode is deprecated")
	var inputKey = InputEventKey.new()
	inputKey.physical_scancode = code
	self.shortcut.shortcut = inputKey

#func _unhandled_input(event):
#	if(disabled):
#		return
#	if(event is InputEventKey):
#		if(event.pressed && event.physical_scancode == savedKey):
#			grab_click_focus()
#			grab_focus()
#			emit_signal("pressed")


func _on_SceneOptionButton_pressed():
	if(OS.has_touchscreen_ui_hint() && OPTIONS.shouldRequireDoubleTapOnMobile()):
		if(!showingDescription):
			showingDescription = true
			emit_signal("mouse_entered")
		else:
			showingDescription = false
			emit_signal("pressedActually")
	else:
		emit_signal("pressedActually")


func _on_SceneOptionButton_focus_exited():
	showingDescription = false


func _on_SceneOptionButton_mouse_exited():
	showingDescription = false
