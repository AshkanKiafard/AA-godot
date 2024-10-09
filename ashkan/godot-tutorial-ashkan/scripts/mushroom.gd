extends StaticBody2D

var multiplier

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		multiplier = 5 if body.in_water else 2
	else:
		multiplier = 1
	body.velocity.y = body.JUMP_VELOCITY * multiplier
	if body is Player:
		body.stamina = 0
		body.jump_count = 0
