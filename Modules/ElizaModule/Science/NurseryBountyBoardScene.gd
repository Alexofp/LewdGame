extends SceneBase

var donateText:String = ""

func _init():
	sceneID = "NurseryBountyBoardScene"

func _run():
	if(state == ""):
		playAnimation(StageScene.Solo, "stand")
		
		var nurseryTasks:Array = GM.main.SCI.getNurseryTasks()
		
		saynn("You're standing in front of a holographic bounty board. It scans your collar.. and shows you these tasks:")
		
		if(nurseryTasks.empty()):
			saynn("- No tasks left, come back tomorrow, inmate!")
		else:
			for taskA in nurseryTasks:
				var task:NurseryTaskBase = taskA
				
				sayn("- "+task.getName())
				sayn(task.getDescription())
				var compString:String = task.getCompletionString()
				if(compString != ""):
					sayn(compString)
				sayn("Reward: "+task.getRewardString())
				saynn(task.getDeadlineString())
		
		saynn("Near the board there is a machine that can accept any fluid container. A note says that the container will be fully emptied and then given back.")
		
		addButton("Donate", "Choose a fluid container with fluids that you want to donate", "choose_donate")
		addButtonWithChecks("Reroll (1 credit)", "Pay 1 credit to reroll all the bounties", "do_reroll", [], [[ButtonChecks.HasCredits, 1]])
		addButton("Leave", "Time to go", "endthescene")
	
	if(state == "do_reroll"):
		saynn("You press a button and all the tasks disappear.. just like a single credit from your inmate account.")

		saynn("The board hums as it tries to come up with new bonties..")
		
		addButton("Continue", "See what happens next", "")

	if(state == "choose_donate"):
		saynn("Choose which fluid container you want to use to donate.")
		
		saynn("The container will be fully cleared and returned back to you.")
		
		saynn("The ad claims that 10% of the donated fluids will be directed towards the development of new medical drugs.")
		
		addButton("Back", "You changed your mind", "")
		var equippedItems = GM.pc.getInventory().getAllEquippedItems()
		for slot in equippedItems:
			var equippedItem:ItemBase = equippedItems[slot]
			
			if(equippedItem.getFluids() != null):
				addButton(equippedItem.getStackName(), equippedItem.getVisisbleDescription(), "pickDonate", [equippedItem])
		for theitem in GM.pc.getInventory().getItems():
			if(theitem.getFluids() != null):
				if(theitem.getFluids().isEmpty()):
					addDisabledButton(theitem.getStackName(), "(This item is empty)\n\n"+theitem.getVisisbleDescription())
				else:
					addButton(theitem.getStackName(), theitem.getVisisbleDescription(), "pickDonate", [theitem])
	
	if(state == "pickDonate"):
		saynn("You hand your "+donateText+" to the donation machine and let it do its thing.")
		
		saynn("Soon, the machine beeps and hands you your item back.")
		
		addButton("Continue", "See what happens next", "")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
		
	if(_action == "do_reroll"):
		GM.pc.addCredits(-1)
		GM.main.SCI.rerollTasks()
		
	if(_action == "pickDonate"):
		var item:ItemBase = _args[0]
		donateText = item.getVisibleName()
		
		var fluids:Fluids = item.getFluids()
		
		var fluidAmmounts:Dictionary = fluids.getFluidAmountByType()
		
		for fluidID in fluidAmmounts:
			var fluidAmount:float = fluidAmmounts[fluidID]
			
			GM.main.SCI.handleBountyFluid(fluidID, fluidAmount)
			GM.main.SCI.addFluid(fluidID, fluidAmount*0.1)
		fluids.clear()

	setState(_action)
