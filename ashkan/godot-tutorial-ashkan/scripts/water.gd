extends TileMapLayer


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	body.in_water = true

func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	body.in_water = false
