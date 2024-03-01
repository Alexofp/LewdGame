extends Control

var inGame = false
var freeze = false
var timer = 20.0
var timeLeft = timer
var lastRound = timer
var lastdice = 0
var dices

signal minigameCompleted(finalScore)

func _ready() -> void:
	dices = [$GameScreen/Panel1, $GameScreen/Panel2, $GameScreen/Panel3]
	setIngame(false)
	doRound()
 

func _process(delta):
	if inGame && !freeze:
		timeLeft -= delta
		setTimeBar(timeLeft / timer)
		if timeLeft <= 0:
			finish()
		if lastRound - timeLeft > 0.5:
			lastRound = timeLeft
			doRound()

func doRound():
	if RNG.chance(50):
		lastdice += 1
	else:
		lastdice -= 1
	if lastdice >= dices.size():
		lastdice = 0
	if lastdice < 0:
		lastdice = dices.size() - 1
	if RNG.chance(30):
		updateDice(dices[lastdice], RNG.pick(dices).number)
	else:
		updateDice(dices[lastdice], dices[lastdice].number)

func updateDice(dice, number):
	while number == dice.number: 
		number = RNG.randi_range(1, 6)
		
	dice.number = number
	dice.color = Color.black

			
func _on_Click(event):
	if event is InputEventMouseButton:
		if event.pressed && !freeze:
			finish()

func finish():
	freeze = true
	yield(get_tree().create_timer(0.8), "timeout")
	freeze = false
	emit_signal("minigameCompleted", calcScore())

# calculate score from 	-1.0 to +1.3
func calcScore():
	var score = 0
	if dices[0].number == dices[1].number && dices[1].number == dices[2].number:
		score = 1 + dices[0].number * 2
	elif dices[0].number == dices[1].number || dices[0].number == dices[2].number:
		score = dices[0].number
	elif dices[1].number == dices[2].number:
		score = dices[1].number
	else:
		score = -(dices[0].number + dices[1].number + dices[2].number)/1.5
		if RNG.chance(50):
			score = 0
	return score/10.0

func _on_Button_pressed():
	setIngame(true)

func setIngame(_inGame):
	inGame = _inGame
	$StartMenu.visible = !_inGame
	$GameScreen.visible = _inGame

func setTimeBar(val):
	$GameScreen/ProgressBar.value = clamp(val, 0.0, 1.0)
