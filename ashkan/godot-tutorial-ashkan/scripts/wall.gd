extends StaticBody2D

@export var player : CharacterBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	player.set_stamina(0)
	player.set_jump_count(0)
