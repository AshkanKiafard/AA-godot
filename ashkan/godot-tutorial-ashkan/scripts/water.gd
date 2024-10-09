extends TileMapLayer

@onready var player: CharacterBody2D = $"../Player"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player.in_water = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player.in_water = false
