extends StaticBody2D

@onready var player: CharacterBody2D = $"../Player"

func _on_area_2d_body_entered(body: Node2D) -> void:
	player.velocity.y = player.JUMP_VELOCITY * 2
