extends TextureProgressBar

@export var player: CharacterBody2D

func _ready() -> void:
	value = player.current_stamina

func _process(delta: float) -> void:
	value = player.current_stamina
	visible = player.current_stamina < player.max_stamina
