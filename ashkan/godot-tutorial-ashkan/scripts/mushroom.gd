extends StaticBody2D

@onready var player: CharacterBody2D = $"../../Player"


func _on_area_2d_body_entered(body: Node2D) -> void:
	var multiplier = 5 if player.in_water else 2
	player.velocity.y = player.JUMP_VELOCITY * multiplier
	player.set_stamina(0)
	player.jump_count = 0


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	player.velocity.y = player.JUMP_VELOCITY
	player.set_stamina(0)
	player.jump_count = 0
