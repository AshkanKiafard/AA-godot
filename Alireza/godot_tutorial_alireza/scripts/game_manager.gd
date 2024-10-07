extends Node

var score = 0

@onready var score_label = $ScoreLabel

func add_point():
	score += 1
	update_score_label("You are stuck here forever!\nCoins: " + str(score))

func update_score_label(input_text):
	score_label.text = input_text
