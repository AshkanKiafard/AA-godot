extends Area2D

enum fruit_type {STAMINA, HEALTH}
@onready var player: Player = $Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var type: fruit_type

func _ready() -> void:
	match type:
		fruit_type.HEALTH:
			sprite_2d.region_rect = Rect2(0, 50, 16, 14)
		fruit_type.STAMINA:
			sprite_2d.region_rect = Rect2(34, 1, 11, 15)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		match type:
			fruit_type.STAMINA:
				if body.stamina < 0:
					body.stamina = 0
					animation_player.play("eat")
			fruit_type.HEALTH:
				if body.health < 100:
					body.health += 30
					animation_player.play("eat")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "eat":
		queue_free()
