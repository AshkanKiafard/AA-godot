extends TextureProgressBar

@export var player : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(_update)
	value = player.health
	
func _update() -> void:
	value = player.health
