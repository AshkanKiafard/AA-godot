extends TileMapLayer

@onready var player: CharacterBody2D = $"../Player"

func _on_area_2d_body_entered(body: Node2D) -> void:
	player.set_in_water(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	player.set_in_water(false)
