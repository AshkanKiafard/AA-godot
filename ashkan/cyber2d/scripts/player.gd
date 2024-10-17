extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $BikerSprite
@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var voice: AudioStreamPlayer2D = $voice

const WOO_AUDIO = preload("res://assets/audio/characters/Biker/miscellaneous_4_sean.wav")
const SHOUUTING_AUDIO = preload("res://assets/audio/characters/Biker/shouting_7_sean.wav")
const GRUNT_AUDIOS = {
	"jump": [preload("res://assets/audio/characters/Biker/grunting_1_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_2_sean.wav")],
	"attack":[preload("res://assets/audio/characters/Biker/grunting_3_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_4_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_5_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_6_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_7_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_8_sean.wav")]
	}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var jump_count = 0
var jump_available = true

var x_direction
var x_speed

var shout = true

signal health_changed
var health := 100.0 :
	set(value):
		if not is_dashing():
			if value <= 0 and health > 0:
				print("DEAD")
				# TODO
			if value < health:
				# TODO
				pass
				#hurt_audio.play()
				#hurt_timer.start()
				#animated_sprite.play("hurt")
			health = clamp(value, 0, 100)
			health_changed.emit()

signal stamina_changed
var stamina := 100.0 :
	set(value):
		stamina = clamp(value, 0, 100)
		stamina_changed.emit()

func restore_stamina(value):
	if is_on_floor():
		stamina += value

func is_dashing():
	return animated_sprite.is_playing() and animated_sprite.animation == "dash"


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not ground_ray_cast.is_colliding() and not voice.playing and shout:
			shout = false
			play_voice(1, SHOUUTING_AUDIO)
	else:
		jump_count = 0
		shout = true
	handle_movement(delta)
	handle_animation()

func handle_movement(delta: float):
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_count = 0
		jump_count += 1
		if jump_count <= 3:
			if jump_count == 1:
				animated_sprite.play("jump")
			else:
				animated_sprite.play("double_jump")
			if randi() % 2:
				play_voice(1, choose(GRUNT_AUDIOS["jump"]))
			stamina -= 25
			velocity.y = JUMP_VELOCITY - (stamina * 2)

	# Get the input direction and handle the movement/deceleration.
	# TODO add coyote time
	x_direction = Input.get_axis("move_left", "move_right")
	var flip_h = false if x_direction == 1 else true if x_direction == -1 else animated_sprite.flip_h
	if animated_sprite.flip_h != flip_h:
		animated_sprite.flip_h = flip_h
		# correct the sprite offset
		animated_sprite.position.x -= 40 * (-x_direction)
		
	var x_speed = SPEED
	var regen_stamina = true
	if x_direction:
		if Input.is_action_pressed("run"):
			regen_stamina = false
			x_speed += 100 + stamina
			stamina -= 0.2
		if Input.is_action_just_pressed("dash") and stamina > 50:
			play_voice(1+randf_range(-0.05, 0.05), WOO_AUDIO)
			animated_sprite.play("dash")
			regen_stamina = false
			stamina -= 50
		if is_dashing():
			x_speed *= 7
		velocity.x = x_direction * x_speed
		if regen_stamina:
			restore_stamina(1)
	else:
		restore_stamina(2)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func handle_animation():
	# if hurt_timer.is_stopped():
	if is_on_floor():
		if not is_dashing():
			if x_direction == 0:
				animated_sprite.play("idle1")
			else:
				if Input.is_action_pressed("run"):
					animated_sprite.play("run")
				else:
					animated_sprite.play("walk")
	else:
		if jump_count == 0 and animated_sprite.animation != "jump":
			animated_sprite.play("jump")

func play_voice(pitch_scale, audio):
	voice.pitch_scale = pitch_scale
	voice.stream = audio
	voice.play()

func choose(l: Array):
	return l[randi()%len(l)]
