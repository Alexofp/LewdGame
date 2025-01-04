extends Button

func _ready():
	var event: InputEventAction = self.shortcut.shortcut
	$Icon.path = event.action
