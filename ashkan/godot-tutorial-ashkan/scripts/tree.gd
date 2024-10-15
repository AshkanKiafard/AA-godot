extends Node2D

@export var spawn_points: Array[Node2D]
const FRUIT = preload("res://scenes/fruit.tscn")

var time = 0
var last_time = 0

func _process(delta: float) -> void:
	time += delta
	if time - last_time > 3:
		for sp in spawn_points:
			if sp.get_child_count() == 0:
				var fruit = FRUIT.instantiate()
				fruit.position = sp.position
				fruit.type = fruit.fruit_type.HEALTH if randi() % 2 else fruit.fruit_type.STAMINA
				sp.add_child(fruit)
	
