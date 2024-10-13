extends Node2D

@export var node : Node
@export var spawn: bool
const SLIME = preload("res://scenes/slime.tscn")
const F_SLIME = preload("res://scenes/friendly_slime.tscn")

var elapsed_time = 0
var last_time = 0

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time - last_time > 1 and spawn:
		last_time = elapsed_time
		var spawned = SLIME.instantiate()
		var spawned_dir = 1 if bool(randi() % 2) else -1
		spawned.position = Vector2(position.x + spawned_dir*5, position.y + 15)
		spawned.get_node("AnimatedSprite2D").flip_h = true if spawned_dir == -1 else false
		spawned.direction = spawned_dir
		node.add_child(spawned)
