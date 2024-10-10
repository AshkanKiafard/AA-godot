extends Node

var score = 0

const SLIME = preload("res://scenes/slime.tscn")
@onready var spawn_slimer: Node2D = $SpawnSlimer
@onready var score_label: Label = $ScoreLabel
@onready var time: Label = $"../UI/Control/CenterContainer/Time"
@onready var coin_count: Label = $"../UI/AnimatedSprite2D/CoinCount"
@onready var game: Node2D = $".."
var elapsed_time = 0
var last_time = 0

func _process(delta: float) -> void:
	elapsed_time += delta
	time.text = format_time(elapsed_time)
	if elapsed_time - last_time > 1:
		last_time = elapsed_time
		var slime = SLIME.instantiate()
		var slime_dir = 1 if bool(randi() % 2) else -1
		slime.position = Vector2(spawn_slimer.position.x + slime_dir*5, spawn_slimer.position.y)
		slime.get_node("AnimatedSprite2D").flip_h = true if slime_dir == -1 else false
		slime.direction = slime_dir
		game.add_child(slime)

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
