extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var bullet: PackedScene

func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	handle_movement(delta)
	if Input.is_action_pressed("fire"):
		handle_shooting.rpc()
	$GunRotation.look_at(get_viewport().get_mouse_position())

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

@rpc("any_peer", "call_local")
func handle_shooting():
	var shooted_bullet = bullet.instantiate()
	shooted_bullet.global_position = $GunRotation/BulletSpawn.global_position
	shooted_bullet.global_rotation = $GunRotation.global_rotation
	get_tree().root.add_child(shooted_bullet)
