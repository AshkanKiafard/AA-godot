extends TextureProgressBar

@export var player : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	player.oxygen_changed.connect(_update)
	
func _update() -> void:
	visible = player.oxygen != 100
	value = player.oxygen
