extends "res://Modules/HypnokinkModule/Scenes/Sessions/HK_SessionInductionBase.gd"

func _init():
	sceneID = HK_Sessions.InductionFlashlight
	
func _initScene(_args = []):
	onInduction(_args)

func _run():
	if(state == ""):
		addCharacter("Vion")
		playAnimation(StageScene.Duo, "sit", {npc="Vion", npcAction="sit"})
		
		saynn("[say=Vion]Now where did I put that...[/say]")

		saynn("{Vion.name} looks around, searches under his pillow of his bed, then behind one of the sofa's cushions, before finally bending down and rooting under the sofa. He victoriously emerges with a small flashlight in his grasp. You recognize it as the type that comes with some of the mining gear.")

		saynn("[say=Vion]Sit down on the sofa, if you'd please.[/say]")
		
		saynn("You do so. {Vion.name} brings the chair over and seats himself directly opposite of you.")

		saynn("[say=Vion]Now this is very simple. All you have to do is follow the light, alright?[/say]")

		saynn("He turns the flashlight on, then decreases the brightness to the lowest setting. Then he holds it up at arm's length in front of you.")

		saynn("[say=pc]Okay. Easy.[/say]")

		saynn("He raises it slightly, then slowly starts drawing a circle.")

		saynn("[say=Vion]Ah, no, keep your head still please. Follow it with just your eyes.[/say]")
		saynn("[say=Vion]Relax your shoulders. Lean into the cushions. No need to be so stiff.[/say]")

		saynn("You try your best to relax as your eyes follow the circle as {Vion.name} traces it in the air in front of you.")

		saynn("[say=Vion]Focus on the light. Let the world fade into the background. Round and round it goes...[/say]")

		saynn("You somewhat drowsily note how your vision seems to blur around the circle.")

		saynn("[say=Vion]Now imagine little sparks of brightness dripping off the light, slowly falling towards the center of the circle, tracing spirals in the air as they go.[/say]")

		saynn("Maybe its some optical trick or eye fatigue, but little sparks start to dance across your vision, spiraling down...")

		saynn("[say=Vion]In a moment, the light will stop circling. Continue watching it, focusing on it.[/say]")

		saynn("{Vion.name} stops the light, holding in steady and still, right in front of your eyes. Then he slowly brings it closer and closer, until your eyes begin to cross...")

		saynn("[say=Vion]Excellent, you're doing very well...[/say]")

		saynn("He raises the light up, keeping it the same distance from your eyes all the while. It goes past your eyebrows, then your forehead. And as your eyes roll into the back of your head and your eyelids fall closed...")

		sayn("[say=Vion]Now...[/say]")
		saynn("[say=Vion][b]Sleep.[/b][/say]")
		
		addButton("Sleep", "", "endthescene")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		afterInduction()
		return

	setState(_action)
