extends CharacterBody2D

var direction = 1
var speed = 500
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play("1")
	animated_sprite_2d.flip_h = false if direction == 1 else true

func _process(_delta: float) -> void:
	velocity.x = speed * direction
	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
