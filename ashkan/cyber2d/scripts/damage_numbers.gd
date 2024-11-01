extends Node

func display_number(value: int, pos: Vector2, is_critical: bool = false):
	var number = Label.new()
	number.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	number.global_position = pos
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	if is_critical:
		color = "#B22"
	if value == 0:
		color = "#FF8"
	
	number.label_settings.font_color = color
	number.label_settings.font = preload("res://assets/fonts/Cyberphont 2.0.ttf")
	number.label_settings.font_size = 25 if is_critical else 15
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale",Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	
	await tween.finished
	number.queue_free()
