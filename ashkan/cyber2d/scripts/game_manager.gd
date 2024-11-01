extends Node

@export var pumpkin: Node
@export var player: Node
@onready var announcer_voice: AudioStreamPlayer = $AnnouncerVoice
@onready var sfx: AudioStreamPlayer = $SFX
@onready var announcer_text: Label = $"../UI/CenterContainer/AnnouncerText"
@onready var wave_timer: Timer = $WaveTimer
@onready var wave_text: Label = $"../UI/CenterContainer2/WaveText"
@onready var time_remaining: Label = $"../UI/CenterContainer3/TimeRemaining"
@onready var enemies_remaining: Label = $"../UI/CenterContainer4/EnemiesRemaining"
@onready var game_over_container: CenterContainer = $"../UI/GameOverContainer"

const ZOMBIE = preload("res://scenes/entities/zombie.tscn")
var text
var praise_sounds = ["excellent", "god like", "great", "my god", "perfect", "wow", "sick", 
"untouchable", "over the top", "you're incredible"]
var game_over = false

var wave = 1:
	set(value):
		wave = value
		wave_text.text = "Wave " + str(wave)

var spawn_count = 0

var enemies_killed_count = 0:
	set(value):
		enemies_killed_count = value
		enemies_remaining.text = str(spawn_count - enemies_killed_count) + " remaining"
		if enemies_killed_count >= spawn_count and !game_over:
			enemies_killed_count = 0
			wave_timer.stop()
			wave += 1
			player.health = 100
			player.stamina = 100
			start_next_wave()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_next_wave()

func _process(_delta: float) -> void:
	time_remaining.text = format_time(wave_timer.time_left)

func choose(l: Array):
	return l[randi()%len(l)]
	
func play_praise_voice(enemy_health):
	if enemy_health > 0:
		text = choose(praise_sounds)
	else:
		text = "ko"
	announcer_voice.stream = load("res://assets/audio/announcer/"+text+".wav")
	announcer_text.text = text + "!"
	announcer_text.visible = true
	announcer_voice.play()
	await announcer_voice.finished
	announcer_text.visible = false

func start_next_wave():
	if pumpkin.animation == "close":
		pumpkin.play("open")
	await get_tree().create_timer(1).timeout
	spawn_count += 1
	enemies_remaining.text = str(spawn_count - enemies_killed_count) + " remaining"
	wave_timer.wait_time = spawn_count * 5 + 10
	wave_timer.start()
	spawn()

func spawn():
	for i in spawn_count:
		var zombie = ZOMBIE.instantiate()
		zombie.direction = -1
		zombie.position = pumpkin.position
		zombie.scale = Vector2(1.9, 1.9)
		zombie.died.connect(inc_enemies_killed_count)
		get_tree().root.add_child.call_deferred(zombie)
		await get_tree().create_timer(0.5).timeout
	pumpkin.play("close")

func inc_enemies_killed_count():
	enemies_killed_count += 1

func _on_wave_timer_timeout() -> void:
	show_game_over()

func show_game_over():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over_container.visible = true
	game_over = true

func format_time(time : float):
	var mins = int(time) / 60
	time -= mins * 60
	var secs = int(time) 
	return str("%0*d" % [2, mins]) + ":" + str("%0*d" % [2, secs])

func _on_button_pressed() -> void:
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.queue_free()
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func play_sound_effect(path, count):
	if !sfx.playing:
		sfx.stream = load(path+str(randi_range(1,count))+".wav")
		sfx.play()
