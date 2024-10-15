extends Control

@export var game: PackedScene

func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(game)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
