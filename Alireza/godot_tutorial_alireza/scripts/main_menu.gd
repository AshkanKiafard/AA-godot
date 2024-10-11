extends Control

@onready var player: CharacterBody2D = $menu_player
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Start.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	player.velocity.x = -100
	player.velocity.y = -300
	timer.start(1.5)
	$VBoxContainer/Start.disabled = true


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
