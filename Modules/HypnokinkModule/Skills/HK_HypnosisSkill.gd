extends SkillBase
			
func _init():
	id = HK_Skill.HypnosisSkill
	var _s = connect("levelChanged", self, "_on_levelChanged")

func getVisibleName():
	return "Hypnosis"

func getVisibleDescription():
	return "Shows the control you display over your own subconscious."

func getPerkTiers():
	return [
		[0],
		[2],
		[5],
	]

func _on_levelChanged(idParam, levelParam):
	if(id != idParam || npc == null):
		return
	if(levelParam >= 1):
		if(!npc.hasPerk(HK_Perk.KeywordsDrawback)):
			npc.skillsHolder.addPerk(HK_Perk.KeywordsDrawback)
			flashDrawbackMessage(GlobalRegistry.getPerk(HK_Perk.KeywordsDrawback))
	if(levelParam >= 3):
		if(!npc.hasPerk(HK_Perk.FamousDrawback)):
			npc.skillsHolder.addPerk(HK_Perk.FamousDrawback)
			flashDrawbackMessage(GlobalRegistry.getPerk(HK_Perk.FamousDrawback))
	if(levelParam >= 5):
		if(!npc.hasPerk(HK_Perk.DeepTranceDrawback)):
			npc.skillsHolder.addPerk(HK_Perk.DeepTranceDrawback)
			flashDrawbackMessage(GlobalRegistry.getPerk(HK_Perk.DeepTranceDrawback))
			
func flashDrawbackMessage(drawbackPerk: PerkBase):
	if(npc != GM.pc):
		return;
	if(GM.ui):
		GM.main.addMessage("You have gained a new drawback: "+drawbackPerk.getVisibleName()+"!")
