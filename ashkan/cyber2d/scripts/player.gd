extends CharacterBody2D

@export var armed: bool
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var weapon_sprite: AnimatedSprite2D = $MeleeWeapon
@onready var hand_sprite: Sprite2D = $Hand
@onready var legs_sprite: AnimatedSprite2D = $Legs
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

var attack

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
				#player_sprite.play("hurt")
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
	return player_sprite.is_playing() and player_sprite.animation == "dash"


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		weapon_sprite.visible = false
		velocity += get_gravity() * delta
		if not ground_ray_cast.is_colliding() and not voice.playing and shout:
			shout = false
			play_voice(1, SHOUUTING_AUDIO)
	else:
		jump_count = 0
		shout = true
	handle_movement()
	handle_animation()

func handle_movement():
	# Handle jump
	# TODO add coyote time
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_count = 0
		jump_count += 1
		if jump_count <= 3:
			if jump_count == 1:
				play_anim("jump", false, false)
			else:
				play_anim("double_jump", false, false)
			if randi() % 2:
				play_voice(1, choose(GRUNT_AUDIOS["jump"]))
			stamina -= 25
			velocity.y = JUMP_VELOCITY - (stamina * 2)

	# Get the input direction and handle the movement/deceleration.
	x_direction = Input.get_axis("move_left", "move_right")
	var flip_h = false if x_direction == 1 else true if x_direction == -1 else player_sprite.flip_h
	if player_sprite.flip_h != flip_h:
		player_sprite.flip_h = flip_h
		weapon_sprite.flip_h = flip_h
		hand_sprite.flip_h = flip_h
		legs_sprite.flip_h = flip_h
		# correct the sprite offset
		player_sprite.position.x += 40 * x_direction
		weapon_sprite.position.x += 40 * x_direction
		legs_sprite.position.x += 40 * x_direction
		hand_sprite.position.x += 20 * x_direction
		hand_sprite.rotation += 45 * x_direction
		
	var regen_stamina = true
	attack = Input.is_action_pressed("attack")
	if attack:
		# TODO play grunting sound
		stamina -= 0.1 if armed else 0.05
		regen_stamina = false
		
	x_speed = SPEED
	if x_direction:
		if Input.is_action_pressed("run"):
			regen_stamina = false
			x_speed += 100 + stamina
			stamina -= 0.2
		if Input.is_action_just_pressed("dash") and stamina > 50:
			play_voice(1+randf_range(-0.05, 0.05), WOO_AUDIO)
			play_anim("dash", false, false)
			regen_stamina = false
			stamina -= 50
		if is_dashing():
			x_speed *= 7
		velocity.x = x_direction * x_speed
		if regen_stamina:
			restore_stamina(1)
	else:
		if regen_stamina:
			restore_stamina(1.5)
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()	

func handle_animation():
	# if hurt_timer.is_stopped():
	if is_on_floor():
		if not is_dashing():
			if x_direction == 0:
				play_anim("idle", attack, armed)
			else:
				if Input.is_action_pressed("run"):
					play_anim("run", attack, armed)
				else:
					play_anim("walk", attack, armed)
	else:
		if jump_count == 0 and player_sprite.animation != "jump":
			play_anim("jump", false, false)

func play_anim(anim:String, attack: bool, melee: bool):
	# reset sprites
	player_sprite.position.y = -48
	hand_sprite.visible = false
	legs_sprite.visible = false
	
	# can't attack when jump-/dashing
	if "jump" in anim or "dash" in anim:
		weapon_sprite.visible = false
		melee = false
	else:
		weapon_sprite.visible = armed
	
	var melee_str = "_melee" if melee else ""
	var attack_str = "_attack" if attack else ""
	
	player_sprite.play(anim+attack_str+melee_str)
	
	# walk does not have an attack animation
	if anim != "walk":
		weapon_sprite.play(anim+attack_str)
	elif anim == "walk" and melee:
		if not attack:
			# add extra hand for holding melee weapon while walking
			weapon_sprite.animation = "idle"
			weapon_sprite.frame = 0
			hand_sprite.visible = true
		else:
			# stich upper and lower body together
			# upper: idle attack
			# lower: walk
			legs_sprite.visible = true
			weapon_sprite.play("idle_attack")
			legs_sprite.play("walk")
			player_sprite.position.y -= 10
	
	# sync
	weapon_sprite.frame = player_sprite.frame
	legs_sprite.frame = player_sprite.frame

func play_voice(pitch_scale, audio):
	voice.pitch_scale = pitch_scale
	voice.stream = audio
	voice.play()

func choose(l: Array):
	return l[randi()%len(l)]
