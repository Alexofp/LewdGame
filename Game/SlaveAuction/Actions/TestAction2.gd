extends AuctionAction

func _init():
	id = "TestAction2"

func getName() -> String:
	return "SEX (TOP)"

func onAct(_char:BaseCharacter, _auction, _slaveTraits:Dictionary):
	return {
		text = "VERY GOOD AT FUCKING YOU",
	}

func getTraits() -> Dictionary:
	return {
		"FetishSexTop": 1.0,
	}

func getPositiveReaction(_char:BaseCharacter) -> String:
	return "NICE, I COULD USE A SERVICE TOP."
