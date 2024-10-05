extends TextureProgressBar

@export var player : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	player.stamina_changed.connect(_update)
	
func _update() -> void:
	visible = player.stamina != 0
	value = player.stamina + 100
