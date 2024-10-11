extends Area2D

@onready var timer: Timer = $Timer
@export var damage: int
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health -= damage
		audio_player.play()
		if body.health == 0:
			print("DEAD")
			body.get_node("CollisionShape2D").queue_free()
			Engine.time_scale = 0.5
			timer.start()
	elif body is Slime:
		body.queue_free()
	

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
