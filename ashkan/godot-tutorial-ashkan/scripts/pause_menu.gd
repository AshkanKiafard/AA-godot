extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()
	
func resume():
	hide()
	get_tree().paused = false
	animation_player.play_backwards("blur")

func pause():
	show()
	$VBoxContainer/ResumeButton.grab_focus()
	get_tree().paused = true
	animation_player.play("blur")

func restart():
	resume()
	get_tree().reload_current_scene()

func quit():
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_resume_button_pressed() -> void:
	resume()


func _on_restart_button_pressed() -> void:
	restart()


func _on_quit_button_pressed() -> void:
	quit()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
