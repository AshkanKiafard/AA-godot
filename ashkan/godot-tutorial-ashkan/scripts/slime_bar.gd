extends Node2D

@export var player: Player
@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var slime_timer: Timer = $SlimeTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $ProgressBar/AnimatedSprite2D
var last_count

func _ready() -> void:
	progress_bar.value = 100
	label.text = str(player.slime_count)
	last_count = player.slime_count
	player.slime_count_changed.connect(update_text)
	slime_timer.start()

func _process(delta: float) -> void:
	if player.slime_count < 3:
		progress_bar.value = (5 - slime_timer.time_left) * 20

func update_text():
	if player.slime_count < last_count:
		progress_bar.value = 0
		if last_count == 3:
			slime_timer.start()
	if player.slime_count == 0:
		animated_sprite_2d.stop()
	else:
		animated_sprite_2d.play("idle")
	label.text = str(player.slime_count)
	last_count = player.slime_count
	
func _on_slime_timer_timeout() -> void:
	player.slime_count += 1
	if player.slime_count < 3:
		progress_bar.value = 0
		slime_timer.start()
