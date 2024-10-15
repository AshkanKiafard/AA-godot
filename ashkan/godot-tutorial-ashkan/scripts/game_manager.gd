extends Node

var score = 0

@onready var score_label: Label = $ScoreLabel
@onready var time: Label = $"../UI/Control/CenterContainer/Time"
@onready var coin_count: Label = $"../UI/AnimatedSprite2D/CoinCount"
var elapsed_time = 0

func _process(delta: float) -> void:
	elapsed_time += delta
	time.text = format_time(elapsed_time)

func add_point():
	score += 1
	score_label.text = "YOU COLLECTED " + str(score) + " COINS!"
	coin_count.text = str(score)

func format_time(time : float):
	var mins = int(time) / 60
	time -= mins * 60
	var secs = int(time) 
	var mili = int((time - int(time)) * 100)
	return str("%0*d" % [2, mins]) + ":" + str("%0*d" % [2, secs]) + ":" + str("%0*d" % [2, mili]) 
