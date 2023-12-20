extends "res://Modules/HypnokinkModule/Scenes/Sessions/HK_SessionBodyBase.gd"

func _init():
	sceneID = HK_Sessions.BodySessionZero
	
func _initScene(_args = []):
	onBody()

func _run():
	if(state == ""):
		addCharacter("HK_Vion")
		playAnimation(StageScene.Duo, "sit", {npc="HK_Vion", npcAction="sit"})
		
		saynn("[say=HK_Vion]Think about how you're feeling. No need to say anything, just consider it.[/say]")

		saynn("You feel oddly floaty, but calm and relaxed. On some level, you are aware enough to know you can wake up at any time if you need to, but you also feel no desire to do so. In fact, you want to play along, and stay in this comfortable, dreamy slumber...")

		saynn("[say=HK_Vion]That's good. Now let's try some simple exercises, shall we? Nod for me.[/say]")

		saynn("You nod...")

		saynn("[say=HK_Vion]There's a good {pc.boy}~[/say]")
		
		saynn("[say=HK_Vion]When I tell you to, you'll open your eyes. You'll stay nice and hypnotized, and as soon as I tell you to drop you'll close them again and fall even deeper. Nod.[/say]")

		saynn("You nod...")

		saynn("[say=HK_Vion]Good. Open your eyes.[/say]")
		
		saynn("You drowsily open your eyes, but before you have a chance to focus them on anything in particular-")
		
		saynn("[say=HK_Vion]And drop.[/say]")
		
		saynn("And your eyelids fall closed.")
		
		saynn("[say=HK_Vion]Good {pc.boy}. Now that I've got your undivided attention, let us establish some ground rules, shall we?[/say]")

		saynn("[say=HK_Vion]What you need to understand is that hypnosis can't make you do anything you're unwilling to... but what you're unwilling to do depends on your inhibitions and boundaries.[/say]")

		saynn("[say=HK_Vion]Inhibitions can be broken. Boundaries can be expanded. Given enough time, hypnosis can lead you places where you'd never have dared go before your journey started.[/say]")
		
		saynn("[say=HK_Vion]Get it? Nod if you do.[/say]")

		saynn("You nod...")

		saynn("[say=HK_Vion]Good~[/say]")

		saynn("[say=HK_Vion]With that in mind, tell me, what are your expectations for these sessions? And be honest, with yourself as well as with me~[/say]")

		saynn("[say=pc]Mmh...[/say]")

		saynn("[say=HK_Vion]Take your time, no need to rush answering.[/say]")

		addButton("Decide", "Think about it", "meta_desc")
	if(state == "meta_desc"):
		saynn("Make a choice of how {HK_Vion.name} will approach your sessions.")

		saynn("A caring approach will result in slower Hypnosis skill xp gain, but {HK_Vion.name} will always make sure to snap you out of hypnosis and the buffs gained will last longer.")

		saynn("A mean approach will result in rapid Hypnosis skill xp gain, but you will be left in a vulnerable mental state after your sessions, with your buffs expiring quickly to encourage frequent returns.")

		saynn("The professional approach offers a healthy balance.")

		saynn("While the content of specific sessions will always depend primarily on that session's topic, {HK_Vion.name} may be more (or less) likely to use specific phrasing depending on your choice.")

		saynn("Your choice can be changed later by repeating Session Zero.")

		addButton("Caring", "Escapism from indefinite imprisonment please", "good")
		addButton("Professional", "Trust the professional to do his job", "neutral")
		addButton("Fuck me up", "Adult novella hypno-villain sounds good actually", "evil")
	if(state == "good"):
		saynn("[say=pc]I... just want to stop hurting.[/say]")

		saynn("[say=HK_Vion]I understand. Life isn't easy at the best of times, and these are hardly the best of times for of you, are they?[/say]")

		saynn("He gently pats you on the head.")

		saynn("[say=HK_Vion]I'll take care to ensure that time you spend with me is pleasant and safe.[/say]")
		
		addButton("Continue", "", "endthescene")

	if(state == "neutral"):
		saynn("[say=pc]I... think you'll know best.[/say]")

		saynn("[say=HK_Vion]Trusting my professionalism? Some might argue that's a dangerous game in a prison full of deviants...[/say]")

		saynn("He rests a hand on your shoulder.")
		
		saynn("[say=HK_Vion]Don't you worry though, your mind is in good hands with me.[/say]")
		
		addButton("Continue", "", "endthescene")

	if(state == "evil"):
		saynn("[say=pc]I... want you to break me. Bend me to your will. Turn my mind into mush.[/say]")

		saynn("[say=HK_Vion]Ah, I see.[/say]")

		saynn("[say=HK_Vion]I consider myself a professional, {pc.name}. That being said...[/say]")

		saynn("He hooks a claw under your collar, leans closer, and whispers in your ear.")

		saynn("[say=HK_Vion]I don't mind [i]occasionally[/i] indulging the fantasies of an eager hypnoslut~[/say]")
		
		addButton("Continue", "", "endthescene")


func _react(_action: String, _args):

	if(_action == "good"):
		setFlag("HypnokinkModule.VionMode", HK_Consts.VionGood)
		
	if(_action == "neutral"):
		setFlag("HypnokinkModule.VionMode", HK_Consts.VionNeutral)
		
	if(_action == "evil"):
		setFlag("HypnokinkModule.VionMode", HK_Consts.VionEvil)
		
	if(_action == "endthescene"):
		setFlag("HypnokinkModule.DidSessionZero", true)
		endScene()
		afterBody()
		return

	setState(_action)
