extends Area2D

@onready var gm = %GameManager
@onready var ap =$AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	gm.add_point()
	ap.play("PickupAnimation")
