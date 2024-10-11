extends Node2D

@export var node : Node
const SLIME = preload("res://scenes/slime.tscn")

var elapsed_time = 0
var last_time = 0

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time - last_time > 1:
		last_time = elapsed_time
		var spawned = SLIME.instantiate()
		var spawned_dir = 1 if bool(randi() % 2) else -1
		spawned.position = Vector2(position.x + spawned_dir*5, position.y + 15)
		spawned.get_node("AnimatedSprite2D").flip_h = true if spawned_dir == -1 else false
		spawned.direction = spawned_dir
		node.add_child(spawned)
