extends StaticBody2D

var multiplier

@onready var jump_sound: AudioStreamPlayer = $JumpSound
var player_body

func _on_area_2d_body_entered(body: Node2D) -> void:
	jump_sound.play()
	if body is Player:
		multiplier = 5 if body.in_water else 2
	else:
		multiplier = 1
	body.velocity.y = body.JUMP_VELOCITY * multiplier
	if body is Player:
		player_body = body
		body.stamina = 0
		$Timer.start()

func _on_timer_timeout() -> void:
	player_body.jump_count = 1
