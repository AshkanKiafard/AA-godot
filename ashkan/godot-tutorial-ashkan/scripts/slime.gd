class_name Slime
extends CharacterBody2D

const SPEED = 60
const JUMP_VELOCITY = -300.0
var direction = 1
var in_water = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

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
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
