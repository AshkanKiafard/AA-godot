extends Area2D

@onready var player: Player = $Player


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.health < 100:
		body.health += 30
		queue_free()
