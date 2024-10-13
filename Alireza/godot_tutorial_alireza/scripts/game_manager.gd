extends Node

var score = 0
var lives = 5
var elapsed_time = 0.0

@onready var score_label = $ScoreLabel
@onready var coins: Label = $"../CanvasLayer/Coins"
@onready var time: Label = $"../CanvasLayer/Time"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	elapsed_time += delta
	time.text = format_time(elapsed_time)

func add_point():
	score += 1
	coins.text = str(score)
	update_score_label("You are stuck here forever!\nCoins: " + str(score))

func update_score_label(input_text):
	score_label.text = input_text

func format_time(time: float) -> String:
	var mins = int(time) / 60
	var secs = int(time) % 60
	var mili = int((time - int(time)) * 100)
	return str("%0*d" % [2, mins]) + ":" + str("%0*d" % [2, secs]) + ":" + str("%0*d" % [2, mili])
