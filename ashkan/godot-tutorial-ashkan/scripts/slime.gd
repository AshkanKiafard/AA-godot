class_name Slime
extends CharacterBody2D

const SPEED = 60
const JUMP_VELOCITY = -500.0
var direction = 1
var v_direction = 0
var in_water = false

@onready var jump_cooldown: Timer = $JumpCooldown
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var gravity = get_gravity() if not in_water else get_gravity() / 2
		velocity += gravity * delta
		
	if in_water:
		velocity.y /= 1.2
		
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		if ray_cast_right.get_collider().is_in_group("Mushroom"):
			v_direction = 1
		else:
			direction = -1
			animated_sprite.flip_h = true

	if ray_cast_left.is_colliding():
		if ray_cast_left.get_collider().is_in_group("Mushroom"):
			v_direction = 1
		else:
			direction = 1
			animated_sprite.flip_h = false
			
	if not ray_cast_left.is_colliding() and not ray_cast_right.is_colliding():
		v_direction = 0
	
	if v_direction == 0:
		position.x += direction * SPEED * delta
	if v_direction == 1 and jump_cooldown.is_stopped():
		jump_cooldown.start()
	position.y += v_direction * JUMP_VELOCITY * delta


func _on_jump_cooldown_timeout() -> void:
	v_direction = 0
