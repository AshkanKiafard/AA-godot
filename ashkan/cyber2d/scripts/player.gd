extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var camera: Camera2D = $Camera2D
@export var bullet: PackedScene


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_gun()

func handle_movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func handle_gun():
	$GunRotation.look_at(get_viewport().get_mouse_position())
	if Input.is_action_pressed("fire"):
		var shooted_bullet = bullet.instantiate()
		shooted_bullet.global_position = $GunRotation/BulletSpawn.global_position
		shooted_bullet.global_rotation = $GunRotation.global_rotation
		get_tree().root.add_child(shooted_bullet)
