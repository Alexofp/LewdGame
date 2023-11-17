extends Attack

func _init():
	id = HK_Attack.TriggerKneel
	category = Category.Special
	aiCategory = AICategory.Offensive
	
func getVisibleName(_context = {}):
	return "Trigger: Kneel"
	
func getVisibleDesc(_context = {}):
	return "Use their posthypnotic suggestion to force them to kneel."
	
func _doAttack(_attacker, _receiver, _context = {}):
	var texts = [
		"{attacker.name} snaps {attacker.his} fingers, triggering {receiver.nameS} hypnotic command."
	]
	var text = RNG.pick(texts)
	
	#if(_receiver.addEffect(StatusEffect.Stunned, [1])):
	#	text += "\n[b]{receiver.name} is briefly stunned![/b]"
	
	if(!_receiver.hasEffect(StatusEffect.Collapsed)):
		if(_receiver.addEffect(StatusEffect.Collapsed)):
			text += "\n[b]{receiver.name} drops to {receiver.his} knees[/b]."
	
	_receiver.addEffect(HK_StatusEffect.PosthypnoticTriggerUsedUp)
	
	return {
		text = text
	}
	
func _canUse(_attacker, _receiver, _context = {}):
	if(_attacker.hasBlockedHands()):
		return false
		
	if(_receiver.statusEffects.has(HK_StatusEffect.ImplantedPosthypnoticTrigger) && !_receiver.statusEffects.has(HK_StatusEffect.PosthypnoticTriggerUsedUp)):
		return true
		
	return false

func getAnticipationText(_attacker, _receiver):
	return "{attacker.name} raises {attacker.his} hand, fingers poised to snap."

func getAttackSoloAnimation():
	return "throw"

func getAttackHitReactAnimation(_attacker, _receiver, _result):
	return "kneel"

func getRequirements():
	return [AttackRequirement.FreeHands, AttackRequirement.CanTalk]

func getExperience():
	return [[HK_Skill.HypnosisSkill, 10]]

func getRecieverArmorScaling(_attacker, _receiver, _damageType) -> float:
	return 0.0
