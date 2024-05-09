extends SceneBase

var isNaked = false
var isCaged = false
var corruption = 0.0
var isSlut = false
var isVerySlut = false
var isLusty = false
var nakedAndShy = false
var visorID = ""
var didFeed = false
var cagedByNova = false

func _init():
	sceneID = "articaSexHypnovisorScene"

func _run():
	if(state == ""):
		addCharacter("artica")
		isNaked = getFlag("ArticaModule.NoClothes", false)
		isCaged = getCharacter("artica").isWearingChastityCage()
		corruption = getModule("ArticaModule").getCorruption()
		isSlut = getModule("ArticaModule").isSlut()
		isVerySlut = getModule("ArticaModule").isVerySlut()
		isLusty = getModule("ArticaModule").isLusty()
		nakedAndShy = (isNaked && !isSlut)
		saynn("Which hypnovisor do you want to put on Artica?")

		addPumpButtons("do_pick_visor")
		addButton("Cancel", "You changed your mind", "endthescene")
		if (false):
			addButton("Nope", "You shouldn't see this", "do_pick_visor")
			addButton("Nope2", "Shouldn't see this either", "endthescene2")
	if(state == "do_pick_visor"):
		saynn("You show Artica some fancy hi-tech goggles. Curiosity flashes in her eyes.")

		saynn("[say=artica]Mmm.. What is that?..[/say]")

		saynn("[say=pc]Wanna try it? It's more of a toy than anything.[/say]")

		saynn("[say=artica]I.. I d-don't know..[/say]")

		saynn("Despite her hesitation, you just put the thing on her.")

		saynn("[say=artica]Eep..[/say]")

		saynn("What program do you want to run?")

		addButton("Obedient pet", "Make Artica act like a good obedient puppy", "obedient_pet")
		addButton("Public use slut", "(Sharing!) Turn Artica into a mindless whore that will be fucked by everyone..", "public_use")
	if(state == "obedient_pet"):
		addCharacter("artica", ["hypno"])
		saynn("You turn on the visor and choose a program..")

		saynn("[sayOther]Running pet.exe.. please stand by..[/sayOther]")

		saynn("[say=artica]W-wha.. W-what is it g-gonna do?[/say]")

		saynn("[say=pc]It will make you feel good, don't worry.[/say]")

		saynn("She is clearly still nervous, her cornered eyes looking through the glass of the visor.. until a warm yellow glow begins to spread throughout it.")

		saynn("[sayOther]Subject detected.. Artica.. Checking and suppressing resistance..[/sayOther]")

		saynn("The fluff is blinking rapidly, her gaze struggles to focus now..")

		saynn("[say=artica]Um.. c-can w-we.. w-wha.. what is.. ohh-h..[/say]")

		saynn("[sayOther]No resistance detected.. Creating a personality backup.. done.. Initiating a mind reprogramming procedure..[/sayOther]")

		saynn("[say=artica]Wait.. What was t-tha.. ah.. haha..[/say]")

		saynn("Artica forgets to close her mouth after her last sentence, her tongue rolls out, drooling, while various hypnotic lights dance before her eyes.. creating patterns.. gradients and spirals.. which for some reason.. reflect in her own eyes..")

		saynn("The fluff is swaying in place, her tail curling around her leg.. her hind paws stand high on her toes.. her arms spread slightly..")

		saynn("[sayOther]High levels of psycho-neutral hyperplasticity detected.. Subject's mind is highly receptive to suggestion.. Brainwashing.. 0%.. 20%.. 40%..[/sayOther]")

		saynn("Wow, that is going fast indeed. Artica is standing completely still, just watching the glowing colors and drooling, all her fidgeting seems to be gone..")

		saynn("[sayOther]60%.. 80%.. 90%.. 99%.. Done. Uploading a new personality.. Done.. Obedience levels set to 100%, willpower set to 0%.. Pet.exe returned status 0.[/sayOther]")

		saynn("The visor continues to idly shine a warm yellow glow into Artica's hypnotized eyes..")

		saynn("[say=pc]Artica?[/say]")

		saynn("She notices you..")

		addButton("Continue", "See what happens next", "artica_brainwashed")
	if(state == "artica_brainwashed"):
		addCharacter("artica", ["naked", "hypno"])
		playAnimation(StageScene.Duo, "stand", {npc="artica", npcAction="kneel", npcBodyState={hard=true,naked=true}})
		if (!isNaked):
			saynn("Slowly, almost involuntarily, Artica begins to strip off her uniform. Her hands unbutton her shirt, revealing her {artica.breasts} to you.. followed by her pulling her shorts down and then wiggling out of them, exposing her"+str(" hard" if !isCaged else "")+" {artica.penis} and a wet pussy slit.")

			saynn("After fully exposing herself to you, Artica lowers herself to her knees before you and smiles, her gaze directed up at you.. an extremely obedient gaze..")

		else:
			saynn("Slowly, almost involuntarily, Artica begins to run her paws along her fur, first bringing them to her {artica.breasts} and cupping them.. before teasing her"+str(" hard" if !isCaged else "")+" {artica.penis} and a wet pussy slit.")

			saynn("After fully exposing herself to you, Artica lowers herself to her knees before you and smiles, her gaze directed up at you.. an extremely obedient gaze..")

		addButton("Tricks", "See if she will really obey", "do_tricks")
	if(state == "do_tricks"):
		playAnimation(StageScene.Beg, "beg", {pc="artica", npc="pc", bodyState={naked=true, hard=true, leashedBy="pc"}})
		saynn("Artica doesn't resist as you attach a leash to her collar.. She smiles with her tongue out and awaits your commands, her ears perked up.")

		saynn("[say=pc]Voice?[/say]")

		saynn("[say=artica]Yip..[/say]")

		saynn("You hear the response instantly.")

		saynn("[say=pc]Louder.[/say]")

		saynn("[say=artica]Yip! Yip![/say]")

		saynn("Kinda adorable. Inmates around you begin to take note of the obedient puppy that you have.. a little crowd starts gathering around.")

		saynn("[say=pc]Give paw.[/say]")

		saynn("Artica darts her hand out as soon as she hears the order.. You shake it and hum..")

		saynn("[say=pc]Beg.[/say]")

		saynn("The fluff instantly brings her arms close to her chest, her clenched hands imitating paws. She is bouncing cutely.. proudly displaying you her tits,"+str(" pregnant belly," if getCharacter("artica").isVisiblyPregnant() else "")+", "+str("locked drippy cock that twitches from every command" if isCaged else "hard canine cock that twitches from every command")+" and her wet cyan slit.")

		saynn("[say=artica]Yip.. yi-i-ip..[/say]")

		saynn("She looks up at you with her big hypnotized eyes, her lips still parted, her tongue out..")

		addButtonWithChecks("Feed her", "She clearly wants a big bone", "bj_pet", [], [[ButtonChecks.HasReachablePenis]])
		addButton("Good girl", "Praise her for being such a good puppy", "pet_goodgirl")
	if(state == "bj_pet"):
		playAnimation(StageScene.SexOral, "sex", {pc="pc", npc="artica", bodyState={exposedCrotch=true, hard=true}, npcBodyState={naked=true, hard=true}})
		saynn("Might as well reward the obedient puppy for doing so well. The crowd watches as you present Artica your {pc.penis}.")

		saynn("[say=pc]Want this bone? Come here.[/say]")

		saynn("With a hungry look in her eyes, Artica eagerly complies and crawls towards you, her tongue making her lips wet in anticipation.")

		saynn("Without any hesitation, Artica buries her face in your crotch, her snout nuzzling against your balls as she inhales deeply, savoring the intoxicating scent that makes her pussy drip.. She lets out a needy yip as her tongue darts out to lap up the shiny drop of precum from the tip of your cock, her own canine member twitching as she does it..")

		saynn("Then, while everyone is watching, she takes you into her mouth, her lips wrapping tightly around the shaft as she starts working head back and forth, sucking you off. With each thrust, you feel your dick hitting the back of her throat.. until Artica suddenly impales herself onto your member, letting it curve down her throat, stretching it.")

		saynn("[say=pc]Ah. Wow, your throat is tight, puppy.[/say]")

		saynn("The crowd admires the pup's ability to deepthroat you, some are enjoying themselves..")

		addButton("Continue", "See what happens next", "bj_pet_cum")
	if(state == "bj_pet_cum"):
		playAnimation(StageScene.SexOral, "fast", {pc="pc", npc="artica", bodyState={exposedCrotch=true, hard=true}, npcBodyState={naked=true, hard=true}})
		saynn("Artica looks up at you with her obedient hypnotized eyes as she completely ignores her gag-reflex, throwing her head forward each time until her snout hits your crotch, your cock bulging her neck and making her choke.")

		saynn("The way her long canine tongue is still swirling around your shaft is making your legs want to give, you put your hand on the back of Artica's head.. and then wait for a moment when you're just about to cum.. before forcing her to take your full length..")

		saynn("[say=pc]GHrr.. Ah..[/say]")

		saynn("With a grunt, her wet tight walls push you over the edge, your {pc.penis} pulsing in Artica's throat as you release your load.. Inmates are cheering as they see your {pc.cum} flooding her mouth.. so much that the poor fluff is clearly choking on it, the excesses flying out of her nostrils, making her look like a messy slut..")

		saynn("[say=pc]Yeah.. swallow it all, girl.[/say]")

		saynn("Her throat is doing her best, gulping your seed as much as she can while she is struggling to breathe..")

		addButton("Good girl", "Praise her for being such a good puppy", "pet_goodgirl")
	if(state == "pet_goodgirl"):
		if (didFeed):
			playAnimation(StageScene.Beg, "pat", {pc="artica", npc="pc", bodyState={naked=true, hard=true}, npcBodyState={exposedCrotch=true,hard=true}})
			saynn("You yank your cock out and let Artica clean it up while you're patting her on the head.")

			saynn("[say=pc]Good girl.. such a good girl..[/say]")

			saynn("The fluff chrrrs happily while licking up the mess before swallowing it all.")

		else:
			playAnimation(StageScene.Beg, "pat", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
			saynn("You pat Artica on the head while she is still bouncing.")

			saynn("[say=pc]Good girl.. such a good girl..[/say]")

		saynn("You notice that each time you praise her, a wave of pleasure seems to be rocking through her, causing her cock to throb"+str(" in its little cage" if isCaged else"")+" and her pussy to drip juices more.")

		saynn("Makes you wonder how far you can push this hypnotized cutie.. You better get a good view out of it too.")

		saynn("[say=pc]Present yourself, Artica. I wanna see all your fuckholes. The whole crowd does.[/say]")

		addButton("Continue", "See what happens next", "pet_presents")
	if(state == "pet_presents"):
		playAnimation(StageScene.Zonked, "tease", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
		saynn("Without any hesitation, Artica lays down on the floor and spreads her legs wide, exposing every inch of her body to your gazes."+str(" Her canine cock stands proudly erect, knot pulsing as precum slides down the cyan shaft" if !isCaged else " Her caged cock is pulsing in its cage")+" while her wet pussy and tight asshole are begging for attention.")

		saynn("[say=artica]Yip![/say]")

		saynn("She is panting softly, reveling in all the attention that she is getting. She was such a shy girl before.. but now she is eagerly presenting her fuckholes to anyone..")

		addButton("Stroke!", "Order the girl to touch herself in front of you all", "pet_cum_stroke")
		addButton("Cum!", "Order the girl to cum hands-free", "pet_cum_handsfree")
	if(state == "pet_cum_stroke"):
		if (isCaged):
			playAnimation(StageScene.Zonked, "rub", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
			saynn("[say=pc]Touch yourself, Artica.[/say]")

			saynn("Her paws instantly dart to her cock.. but the chastity cage prevents her from getting any kind of erection. The fluff makes noises of frustration as she tugs on her cage.. until she gives up and reaches her paws under her balls, spreading her needy pussy for everyone, little ropes of juices hanging between her folds..")

			saynn("She stuffs her exposed fuckhole with her digits, fingering herself while everyone is staring at her..")

		else:
			playAnimation(StageScene.Zonked, "stroke", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
			saynn("[say=pc]Touch yourself, Artica.[/say]")

			saynn("Her paws instantly dart to her cock.. digits wrap around the shaft and start stroking it as soon as you allow it. The fluff is moaning cutely while her whole body reacts to the influx of pleasure, her needy holes visibly clenching while her canine shaft leaks pre that she quickly spreads along the whole length..")

			saynn("She keeps stroking while everyone is staring at her.. Her knot is inflating to its full size..")

		addButton("Continue", "See what happens next", "pet_cum_stroke_cum")
	if(state == "pet_cum_stroke_cum"):
		if (isCaged):
			playAnimation(StageScene.Zonked, "rubcum", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
		else:
			playAnimation(StageScene.Zonked, "rubcum", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
		saynn("Then, with a cute moan, pent-up Artica suddenly throws her head back, her {artica.penis} erupting in a torrent of hot, sticky cum that splatters across her tits and stomach. Each pulse is sending waves of pleasure through her body, her toes curling in ecstasy, her needy pussy gushing with girlcum!")

		saynn("Completely spent, Artica lays panting on the floor, her body covered in her own cum as she enjoys the afterglow of her orgasm.")

		saynn("[say=pc]Good.. very good..[/say]")

		addButton("Hypnovisor", "Turn it off", "pet_turnoffvisor")
	if(state == "pet_cum_handsfree"):
		playAnimation(StageScene.Zonked, "cum", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
		saynn("You notice that Artica is already on the edge of her orgasm. Makes you curious..")

		saynn("[say=pc]Cum, Artica. Paws away from your cock and cunt though.[/say]")

		saynn("Whimpers of desire escape her lips as she hears that. Her cock is throbbing in anticipation, her pussy clenching around the air, her hips bucking involuntarily..")

		saynn("The fluff is wiggling more and more on the floor, her hypnotized eyes watching you as you await patiently. Pressure seems to be rising in her cock, her muscles tensing up..")

		saynn("Then, with a cute moan, pent-up Artica suddenly throws her head back, her {artica.penis} erupting in a torrent of hot, sticky cum that splatters across her tits and stomach. Each pulse is sending waves of pleasure through her body, her toes curling in ecstasy, her needy pussy gushing with girlcum!")

		saynn("Completely spent, Artica lays panting on the floor, her body covered in her own cum as she enjoys the afterglow of her orgasm.")

		saynn("[say=pc]Good.. very good..[/say]")

		addButton("Hypnovisor", "Turn it off", "pet_turnoffvisor")
	if(state == "pet_turnoffvisor"):
		playAnimation(StageScene.Duo, "stand", {npc="artica", npcBodyState={naked=true}})
		addCharacter("artica", ["naked"])
		saynn("After all this fun, it was finally time to stop. You press a button on the hypnovisor to stop the session..")

		saynn("[sayOther]Do you wanna restore the old personality?[/sayOther]")

		saynn("As much as you don't mind having a mindless obedient fucktoy.. You'd rather let Artica keep her memories. You press the yes button.")

		saynn("[sayOther]Restoring personality backup.. Done.. Shutting down..[/sayOther]")

		saynn("The warm yellow glow in front of Artica's hypnotized eyes fades away.. You snap your fingers in front of her face a few times and then help her to get up.")

		saynn("[say=artica]Hah.. Um.. oh.. what..[/say]")

		saynn("Artica looks down at her and sees the mess on her tits. She confirms her suspicions by grabbing some of it and licking it..")

		saynn("[say=artica]T-that's.. my cum..[/say]")

		saynn("Then she looks around and finally realizes how big of a crowd is surrounding her.")

		saynn("[say=artica]..yip.. uhm-m.. eep..[/say]")

		saynn("She covers up and hides behind you, her cheeks burning red.")

		saynn("[say=artica]What is..[/say]")

		saynn("[say=pc]It's okay, Artica. You were such a good puppy.[/say]")

		saynn("[say=artica]Y-yip.. yy-yip.. I mean.. e-eep..[/say]")

		saynn("Looks like she remembers something. Her mind does. Since the show is over, the crowd begins to disperse.")

		saynn("[say=pc]Do you remember what happened?[/say]")

		saynn("She rubs her snout..")

		saynn("[say=artica]I.. was on my knees.. and it was.. f-fun..[/say]")

		saynn("You chuckle and pat her. But not too much.. you don't want her lusty so soon.")

		addButton("Continue", "See what happens next", "endthescene")
	if(state == "public_use"):
		addCharacter("artica", ["hypno"])
		saynn("You turn on the visor and choose a program..")

		saynn("[sayOther]Running public_use.exe.. please stand by..[/sayOther]")

		saynn("[say=artica]W-wha.. P-public use?..[/say]")

		saynn("[say=pc]It will be fun for a slut like you, trust me.[/say]")

		saynn("She is clearly still nervous, her cornered eyes looking through the glass of the visor.. until a warm yellow glow begins to spread throughout it.")

		saynn("[sayOther]Subject detected.. Artica.. Checking and suppressing resistance..[/sayOther]")

		saynn("The fluff is blinking rapidly, her gaze struggles to focus now..")

		saynn("[say=artica]Um.. c-can w-we.. w-wha.. what is.. ohh-h..[/say]")

		saynn("[sayOther]No resistance detected.. Creating a personality backup.. done.. Initiating a mind reprogramming procedure..[/sayOther]")

		saynn("[say=artica]Wait.. What was t-tha.. ah.. haha..[/say]")

		saynn("Artica forgets to close her mouth after her last sentence, her tongue rolls out, drooling, while various hypnotic lights dance before her eyes.. creating patterns.. gradients and spirals.. which for some reason.. reflect in her own eyes..")

		saynn("The fluff is swaying in place, her tail curling around her leg.. her hind paws stand high on her toes.. her arms spread slightly..")

		saynn("[sayOther]High levels of psycho-neutral hyperplasticity detected.. Subject's mind is highly receptive to suggestion.. Brainwashing.. 0%.. 20%.. 40%..[/sayOther]")

		saynn("Wow, that is going fast indeed. Artica is standing completely still, just watching the glowing colors and drooling, all her fidgeting seems to be gone..")

		saynn("[sayOther]60%.. 80%.. 90%.. 99%.. Done. Uploading a new personality.. Done.. Desire levels set to 100%, willpower set to 0%.. Public_use.exe returned status 0.[/sayOther]")

		saynn("The visor continues to idly shine a warm yellow glow into Artica's hypnotized eyes..")

		saynn("[say=pc]Artica?[/say]")

		saynn("She notices you..")

		addButton("Continue", "See what happens next", "slut_brainwashed")
	if(state == "slut_brainwashed"):
		addCharacter("artica", ["naked", "hypno"])
		playAnimation(StageScene.Grope, "watchrub", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
		saynn("The fluff admires your face.. and your crotch.. while one of her hands reaches straight for her pussy, sneaking under the balls and spreading her folds, revealing how wet they are.")

		saynn("Artica shows zero shame as she starts masturbating out in public, her digits plunging in and out of her sex, making wet noises.")

		saynn("[say=pc]Hah. I guess it worked.[/say]")

		saynn("A sight like that is quick to attract people.. A crowd begins to gather around the girl.. But she keeps fingering her needy cyan pussy, her back arched so anyone would be able to see her slick folds and her twitching {artica.penis}..")

		saynn("[sayMale]Look at this whore! She is really going at it, ahaha.[/sayMale]")

		saynn("Brave ones already step out and get closer.. Artica rubs her heated body against them, her tongue is still out, her lips curled into a smile, her hypnotized eyes enjoying the attention. Inmates are spreading her ass while she obediently pulls her tail up for them, exposing her tight asshole..")

		saynn("[sayMale]I knew she would snap![/sayMale]")

		saynn("[sayFemale]It's only because of the hypnovisor, you dumb fucks.[/sayFemale]")

		saynn("[sayMale]I don't care, I'm breeding the slut![/sayMale]")

		saynn("[say=risha]The fuck is going on here? Let me through or I will step on your dicks.[/say]")

		saynn("It's her..")

		addButton("Continue", "See what happens next", "risha_encounter")
	if(state == "risha_encounter"):
		addCharacter("risha")
		playAnimation(StageScene.Zonked, "rub", {pc="artica", npc="risha", bodyState={naked=true, hard=true}})
		saynn("Risha, the lady that she is, rams her way through the crowd, hitting Artica in the process as well. Artica collapses.. but doesn't stop touching herself, inviting anyone to finally use her slutty holes.")

		saynn("[say=risha]Oh, wow, look at that. The girl finally made her choice. I knew that you would never be a mineshaft slave anyway. Now come here, slut.[/say]")

		saynn("Things are getting heated..")

		addButton("Continue", "See what happens next", "artica_fucked_by_risha")
	if(state == "artica_fucked_by_risha"):
		playAnimation(StageScene.SexPinnedBehind, "sex", {pc="risha", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true}})
		aimCameraAndSetLocName("main_hallroom5")
		saynn("Risha picks up the girl by the collar and pins her against the nearest wall..")

		if (getCharacter("artica").isVisiblyPregnant()):
			saynn("[say=risha]Someone knocked your slutty cunt up already, what a shame.[/say]")

		else:
			saynn("[say=risha]Do you bark while getting bred, slut?[/say]")

		saynn("Seconds later, a big barbed cock pierces Artica's slit. Risha forces herself inside the fluff and already starts pounding her raw. Why waste time with the foreplay if that pussy is begging to be stretched already..")

		saynn("Even though Artica's inner walls get scratched by the barbs and her face is pressed against the cold concrete, she is chrrring happily, her"+str(" swollen lactating" if getCharacter("artica").isLactating() else " perky ")+" tits bouncing during each thrust.")

		saynn("[say=risha]Oh yeah, you love that cock, don't you? Gonna get you addicted to it, make you a painslut that craves her pussy to be torn each time.[/say]")

		addButton("Continue", "See what happens next", "risha_cums_in_artica")
	if(state == "risha_cums_in_artica"):
		playAnimation(StageScene.SexPinnedBehind, "fast", {pc="risha", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true}})
		saynn(""+str("Artica's caged cock shoots weak spurts of cum onto the concrete wall in front of her" if isCaged else "Artica's hard cock shoots spurts of cum onto the concrete wall in front of her")+", legs shaking, pussy clenching hard around Risha's feline member..")

		saynn("The guard grabs Artica's face by the cheek, her clawed digits inside that cyan mouth.. while the fluff is just chrrring and drooling, her hypnotized eyes show only desire..")

		if (getCharacter("artica").isVisiblyPregnant()):
			saynn("[say=risha]Ngh.. Enjoy your new life, breeding bitch.[/say]")

		else:
			saynn("[say=risha]Ngh.. Enjoy the kittens, bitch.[/say]")

		saynn("And with that, Risha rams her full length inside, breaking into Artica's womb and creating a bump on her belly.. that only gets bigger as her cock starts pumping it full of her thick semen, the barbs keep scratching at the womb's walls.")

		saynn("Artica stands high on her toes, her tail curling around Risha's waist.. while her pussy already gets creampied.")

		saynn("Risha yanks her cock out, leaving Artica's stuffed pussy to pulse-drip seed.. The guard quickly scribbles something on Artica's snow-white fur..")

		saynn("[say=risha]Glad I got to be the first, sweetheart. Now, who here is a cockslave that will clean my messy shaft?[/say]")

		addButton("Continue", "See what happens next", "artica_after_risha")
	if(state == "artica_after_risha"):
		removeCharacter("risha")
		playAnimation(StageScene.Grope, "watchrub", {pc="artica", npc="pc", bodyState={naked=true, hard=true}})
		aimCameraAndSetLocName("yard_firstroom")
		saynn("After Risha fucks off to use someone else's throat, Artica is just following along the wall of the hall, stumbling occasionally, her gaze spaced out and lusty.. still lusty..")

		saynn("She leaves a trail of white behind her.. so it's not too hard to keep track of her. Other inmates are still surrounding her, some reach out to grope her tits and ass, stroke her fluffy tail.. and some sick fucks just seem to want to hold her hand..")

		saynn("They all scatter off when another guard announces her presence..")

		saynn("[say=nova]Wow, who is this cutie~? Are you lost?[/say]")

		addButton("Continue", "See what happens next", "artica_finds_nova")
	if(state == "artica_finds_nova"):
		addCharacter("nova")
		aimCameraAndSetLocName("yard_westCorridor")
		playAnimation(StageScene.Beg, "beg", {pc="artica", npc="nova", bodyState={naked=true, hard=true}})
		saynn("Artica notices a husky.. and drops to all fours before crawling closer to her. White fluff bounces happily, holding her paws close to her chest, like a puppy.")

		saynn("[say=nova]That is so adorable~."+str(" With a cage on your cock and everything.." if isCaged else "")+" Cute goggles you got there, hope you weren't forced to wear them. Should I take them off?[/say]")

		saynn("When Nova reaches out to do that, Artica quickly nuzzles her crotch, probably sniffing a big bone that's hiding under that fancy armor.. That nuzzling makes the guard stop and reconsider, her crotch bulging..")

		saynn("[say=nova]Or.. maybe we can have some fun first.[/say]")

		addButton("Continue", "See what happens next", "nova_sniff_balls")
	if(state == "nova_sniff_balls"):
		playAnimation(StageScene.SexOral, "tease", {pc="nova", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true}})
		saynn("Nova unzips her undersuit, exposing her own sheath that has a hard red rocket peeking out of it already. Artica is quick to push her snout into it and start licking the tip, making Nova get nice and hard while her own member is locked tight in its cage..")

		saynn("You're just watching Artica's adventures from a far away, making sure she doesn't get into trouble.")

		saynn("[say=nova]Such a hungry girl.. You want mommy's cock, don't you?"+str(" You seem to be a future mommy yourself, hah.." if getCharacter("artica").isVisiblyPregnant() else "")+"[/say]")

		saynn("Artica keeps obediently sniffing and licking Nova's member while the husky is scratching her behind the ears in return.")

		addButton("Continue", "See what happens next", "artica_sucks_nova_off")
	if(state == "artica_sucks_nova_off"):
		playAnimation(StageScene.SexOral, "sex", {pc="nova", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true}})
		saynn("The fluff isn't afraid to part her lips and let the tip of that rocket past her teeth.. and then more.. Artica eagerly swallows more of that shaft, letting it hit the back of her mouth and go down her throat while her long canine tongue swirls around it.")

		saynn("[say=nova]Ooh~.. You're making me so needy too, cutie..[/say]")

		saynn("Nova moans and pants softly while Artica casually stretches her throat against that cock, bobbing her head back and forth, sucking it well. Her gag-reflex is making her choke, wet slurps making Nova eager for more..")

		saynn("[say=nova]Mommy might cum already.. Let's switch pose before she does, shall we?[/say]")

		addButton("Continue", "See what happens next", "nova_start_fucks_artica")
	if(state == "nova_start_fucks_artica"):
		if (!isCaged):
			playAnimation(StageScene.SexPawLick, "stroketease", {pc="nova", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true}})
		else:
			playAnimation(StageScene.SexPawLick, "tease", {pc="nova", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true}})
		if (!isCaged):
			saynn("Nova notices Artica's pulsing cock.")

			saynn("[say=nova]One thing though..[/say]")

			addButton("Continue", "See what happens next", "nova_cages_artica")
		else:
			addButton("Continue", "See what happens next", "nova_fucks_artica")
	if(state == "nova_cages_artica"):
		playAnimation(StageScene.SexPawLick, "tease", {pc="nova", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true, caged=true}})
		saynn("Nova reaches into her pouches and produces a small metal object.. a cage.")

		saynn("[say=nova]Let's lock that cute cock~. What do you say?[/say]")

		saynn("Artica just licks her lips playfully while the guard sits near. Nova slides the cockring part of the cage along Artica's cyan shaft.. before pulling her balls through it. Then she puts the second piece on the pointy canine cock head.. and starts trying to make the two parts meet, battling squirming Artica's erection.. until the cage clicks together, forcing that cyan cock to stay in its sheath..")

		saynn("[say=nova]There we go.. A proper pet should be locked~.[/say]")

		saynn("Artica looks at her locked cock.. and doesn't look sad about it, her fuckhole is dripping just as much..")

		saynn("[say=nova]Now..[/say]")

		addButton("Continue", "See what happens next", "nova_fucks_artica")
	if(state == "nova_fucks_artica"):
		playAnimation(StageScene.SexPawLick, "sex", {pc="nova", npc="artica", bodyState={naked=true, hard=true}, npcBodyState={naked=true, hard=true, caged=true}})
func addPumpButtons(go_id):
	var pumps = GM.pc.getInventory().getItemsWithTag(ItemTag.Hypnovisor)
	for pump in pumps:
		addButton(pump.getVisibleName(), pump.getVisibleDescription(), go_id, [pump])


func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return

	if(_action == "do_pick_visor"):
		var pump = _args[0]
		visorID = pump.getUniqueID()
		GM.pc.getInventory().removeItem(pump)
		getCharacter("artica").getInventory().forceEquipRemoveOther(pump)

	if(_action == "endthescene2"):
		if(visorID != ""):
			var visor = getCharacter("artica").getInventory().getItemByUniqueID(visorID)
			if(visor != null):
				getCharacter("artica").getInventory().removeEquippedItem(visor)
				GM.pc.getInventory().addItem(visor)
		endScene()
		return

	if(_action == "obedient_pet"):
		processTime(5*60)

	if(_action == "public_use"):
		processTime(5*60)

	if(_action == "artica_brainwashed"):
		processTime(5*60)

	if(_action == "do_tricks"):
		processTime(5*60)

	if(_action == "bj_pet"):
		processTime(5*60)
		didFeed = true

	if(_action == "pet_goodgirl"):
		processTime(5*60)

	if(_action == "bj_pet_cum"):
		processTime(5*60)
		getCharacter("artica").cummedInMouthBy("pc")
		GM.pc.orgasmFrom("artica")
		getModule("ArticaModule").addCorruption(0.01)

	if(_action == "pet_presents"):
		processTime(5*60)

	if(_action == "pet_cum_stroke"):
		processTime(5*60)

	if(_action == "pet_cum_handsfree"):
		processTime(5*60)
		getCharacter("artica").cummedOnBy("artica")
		getModule("ArticaModule").triggerCorruption(0.02)

	if(_action == "pet_cum_stroke_cum"):
		processTime(5*60)
		getCharacter("artica").cummedOnBy("artica")
		getModule("ArticaModule").triggerCorruption(0.02)

	if(_action == "pet_turnoffvisor"):
		if(visorID != ""):
			var visor = getCharacter("artica").getInventory().getItemByUniqueID(visorID)
			if(visor != null):
				getCharacter("artica").getInventory().removeEquippedItem(visor)
				GM.pc.getInventory().addItem(visor)
				visorID = ""

	if(_action == "slut_brainwashed"):
		processTime(5*60)

	if(_action == "risha_encounter"):
		processTime(5*60)

	if(_action == "artica_fucked_by_risha"):
		processTime(5*60)

	if(_action == "risha_cums_in_artica"):
		processTime(5*60)
		getModule("ArticaModule").triggerCorruption(0.01)
		getCharacter("artica").cummedInVaginaBy("risha")
		getCharacter("artica").addBodywritingRandom()
		getCharacter("artica").addBodywritingRandom()

	if(_action == "artica_after_risha"):
		processTime(5*60)

	if(_action == "artica_finds_nova"):
		processTime(5*60)

	if(_action == "nova_sniff_balls"):
		processTime(5*60)

	if(_action == "artica_sucks_nova_off"):
		processTime(5*60)

	if(_action == "nova_start_fucks_artica"):
		processTime(5*60)

	if(_action == "nova_cages_artica"):
		processTime(2*60)
		cagedByNova = true

	if(_action == "nova_fucks_artica"):
		processTime(5*60)

	setState(_action)

func saveData():
	var data = .saveData()

	data["isNaked"] = isNaked
	data["isCaged"] = isCaged
	data["corruption"] = corruption
	data["isSlut"] = isSlut
	data["isVerySlut"] = isVerySlut
	data["isLusty"] = isLusty
	data["nakedAndShy"] = nakedAndShy
	data["visorID"] = visorID
	data["didFeed"] = didFeed
	data["cagedByNova"] = cagedByNova

	return data

func loadData(data):
	.loadData(data)

	isNaked = SAVE.loadVar(data, "isNaked", false)
	isCaged = SAVE.loadVar(data, "isCaged", false)
	corruption = SAVE.loadVar(data, "corruption", 0.0)
	isSlut = SAVE.loadVar(data, "isSlut", false)
	isVerySlut = SAVE.loadVar(data, "isVerySlut", false)
	isLusty = SAVE.loadVar(data, "isLusty", false)
	nakedAndShy = SAVE.loadVar(data, "nakedAndShy", false)
	visorID = SAVE.loadVar(data, "visorID", "")
	didFeed = SAVE.loadVar(data, "didFeed", false)
	cagedByNova = SAVE.loadVar(data, "cagedByNova", false)
