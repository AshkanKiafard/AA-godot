extends StaticBody2D

var multiplier

@onready var jump_sound: AudioStreamPlayer = $JumpSound
var player_body


func _on_timer_timeout() -> void:
	player_body.jump_count = 1


func _on_top_body_entered(body: Node2D) -> void:
	make_body_jump_up(body, 2, 5)


func _on_left_body_entered(body: Node2D) -> void:
	make_body_jump_up(body, 1, 5)
	push_body(body, -1)

func _on_right_body_entered(body: Node2D) -> void:
	make_body_jump_up(body, 1, 5)
	push_body(body, 1)

func make_body_jump_up(body: Node2D, normal_mult, water_mult):
	jump_sound.play()
	if body is Player:
		multiplier = water_mult if body.in_water else normal_mult
	else:
		multiplier = 1
	body.velocity.y = body.JUMP_VELOCITY * multiplier
	if body is Player:
		player_body = body
		body.stamina = 0
		$Timer.start()

func push_body(body: Node2D, direction: int):
	if body is Player:
		body.override_x = true
		body.direction = direction
