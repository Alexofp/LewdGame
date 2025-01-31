extends EventBase

func _init():
	id = "DrugDenStartEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "medical_nursery") # CHANGE TO yard_deadend2

func run(_triggerID, _args):
	if(getModule("ElizaModule") != null && getModule("ElizaModule").canStartDrugDenRun()):
		addButtonUnlessLate("Drug Den", "Begin your adventure", "start")
	
func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "start"):
		GM.main.DrugDenRun = DrugDen.new()
		GM.main.DrugDenRun.start()
