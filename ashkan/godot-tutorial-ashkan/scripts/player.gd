class_name Player
extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var jump_count = 0

signal stamina_changed
var stamina := 0.0 :
	set(value):
		var cond = true
		if value > stamina:
			cond = is_on_floor()
		if cond:
			stamina = clamp(value, -100, 0)
			stamina_changed.emit()
		
signal oxygen_changed
var oxygen := 100.0 :
	set(value):
		oxygen = clamp(value, 0, 100)
		oxygen_changed.emit()
var in_water = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = $".."

const FRIENDLY_SLIME = preload("res://scenes/friendly_slime.tscn")

func set_jump_count(value) -> void:
	jump_count = value

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var gravity = get_gravity() if not in_water else get_gravity() / 2
		velocity += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_count = 0
		jump_count += 1
		if jump_count <= 1 or (jump_count == 2 and stamina > -75):
			stamina -= 25
			velocity.y = JUMP_VELOCITY - (stamina * 2)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	animated_sprite.flip_h = false if direction == 1 else true if direction == -1 else animated_sprite.flip_h
	
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	var temp_speed = SPEED
	if direction:
		if stamina > -100 and Input.is_key_pressed(KEY_SHIFT):
			temp_speed += 100 + stamina
			stamina -= 1
		else:
			stamina += 1
		velocity.x = direction * temp_speed
	else:
		stamina += 1
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# handle oxygen
	if oxygen == 0:
		print("DEAD no oxygen")
		visible = false
		get_tree().reload_current_scene()
	if in_water:
		var v_direction := Input.get_axis("move_up", "move_down")
		if v_direction:
			velocity.y += v_direction * 20
		velocity.y /= 1.2
		oxygen -= 0.25
	else:
		oxygen += 1
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_sllime"):
		var f_slime = FRIENDLY_SLIME.instantiate()
		var player_direction = -1 if animated_sprite.flip_h else 1
		f_slime.position = Vector2(position.x + player_direction*3, position.y - 20)
		f_slime.get_node("AnimatedSprite2D").flip_h = animated_sprite.flip_h
		f_slime.direction = player_direction
		game.add_child(f_slime)
		
