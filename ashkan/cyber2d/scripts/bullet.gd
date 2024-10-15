extends CharacterBody2D


const SPEED = 500.0
var direction: Vector2

func _ready() -> void:
	direction = Vector2(1,0).rotated(rotation)


func _physics_process(delta: float) -> void:
	velocity = SPEED * direction
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
