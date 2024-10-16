extends CharacterBody2D


var speed = 500.0
var direction: Vector2

func _ready() -> void:
	direction = direction.rotated(rotation)

func _physics_process(delta: float) -> void:
	velocity = speed * direction

	move_and_slide()
