extends ItemBase


func _init():
	id = "LatexStraitjacket"

func getVisibleName():
	return "Latex Straitjacket"

func getDescription():
	return "A very fashionable straitjacket with included chastity belt and holes for breasts"

func getClothingSlot():
	return InventorySlot.Body

func getBuffs():
	return [
		buff(Buff.BlockedHandsBuff),
		buff(Buff.RestrainedArmsBuff),
		]

func getTags():
	return [ItemTag.BDSMRestraint]

func isRestraint():
	return true

func coversBodyparts():
	return {
		BodypartSlot.Body: true,
		BodypartSlot.Vagina: true,
		BodypartSlot.Penis: true,
		}

func generateRestraintData():
	restraintData = RestraintStraitjacket.new()
	restraintData.setLevel(calculateBestRestraintLevel(3))

func getRiggedParts(_character):
	return {
		"straitjacket": "res://Inventory/RiggedModels/StraitJacket/StraitJacket.tscn",
	}

func getHidesParts(_character):
	return {
		BodypartSlot.Penis: true,
		BodypartSlot.Arms: true,
	}

func getHidesAttachments(_character):
	return {
		"wrist.R": true,
		"wrist.L": true,
	}

func getInventoryImage():
	return "res://Images/Items/bdsm/jacket.png"
