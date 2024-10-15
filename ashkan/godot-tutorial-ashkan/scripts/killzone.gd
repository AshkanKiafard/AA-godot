extends Area2D

@export var damage: int


func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		body.health -= damage
	elif body is Slime:
		body.queue_free()
