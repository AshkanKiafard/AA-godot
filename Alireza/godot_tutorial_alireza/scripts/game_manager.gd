extends Node

var score = 0
var lives = 5
var elapsed_time = 0.0

@onready var score_label = $ScoreLabel
@onready var coins: Label = $"../CanvasLayer/Coins"
@onready var time: Label = $"../CanvasLayer/Time"
@onready var health: Label = $"../CanvasLayer/Status"

func _ready() -> void:
	update_lives()

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

func reduce_life() -> void:
	lives -= 1
	update_lives()
	if lives <= 0:
		pass

func update_lives():
	health.text = str(lives)
