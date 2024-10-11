extends Area2D

@onready var player: Player = $Player


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.stamina < 0:
		body.stamina = 0
		queue_free()
