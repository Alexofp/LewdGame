extends EventBase

func _init():
	id = HK_Event.HypnoEncounter

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)
	es.addTrigger(self, Trigger.PCLookingForTrouble)

func react(_triggerID, _args):
	var isLookingForTrouble = (_triggerID == Trigger.PCLookingForTrouble)
	
	if(not GM.pc.hasPerk(HK_Perk.FamousDrawback)):
		return
	
	if(GM.main.getFlag("HypnokinkModule.HypnoEncounterCooldown", 0) > 0 && !isLookingForTrouble):
		GM.main.increaseFlag("HypnokinkModule.HypnoEncounterCooldown", -1)
		return
	
	if(WorldPopulation.Inmates in GM.pc.getLocationPopulation()):
		var baseChance = 1.0 + HK_CharUtil.getSuggestibleStacks(GM.pc) * 0.5
		baseChance *= GM.pc.getEncounterChanceModifierInmates()
		
		if(RNG.chance(baseChance) || isLookingForTrouble):
			GM.main.setFlag("HypnokinkModule.HypnoEncounterCooldown", RNG.randi_range(5, 10))
			
			var encounterLevel = RNG.randi_range(0, Util.maxi(0, GM.pc.getLevel() + RNG.randi_range(-1, 1)))
			encounterLevel = Util.maxi(encounterLevel, 0)
			encounterLevel = Util.mini(encounterLevel, 15+RNG.randi_range(-1, 1))
			
			return GM.ES.triggerReact(HK_Trigger.HypnoEncounter, [encounterLevel, WorldPopulation.Inmates])

		return false

func getPriority():
	return -5
