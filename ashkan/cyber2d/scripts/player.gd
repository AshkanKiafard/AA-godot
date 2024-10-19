class_name Player
extends CharacterBody2D

@export var armed: bool
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var weapon_sprite: AnimatedSprite2D = $MeleeWeapon
@onready var hand_sprite: Sprite2D = $Hand
@onready var legs_sprite: AnimatedSprite2D = $Legs
@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var voice: AudioStreamPlayer2D = $voice
@onready var grunt_timer: Timer = $GruntTimer
@onready var attack_area: Area2D = $AttackArea
@onready var attack_area_armed: Area2D = $AttackAreaArmed
@onready var hurt_timer: Timer = $HurtTimer

var collided_enemies: Array

const WOO_AUDIO = preload("res://assets/audio/characters/Biker/miscellaneous_4_sean.wav")
const SHOUUTING_AUDIO = preload("res://assets/audio/characters/Biker/shouting_7_sean.wav")
const DAMAGE_AUDIOS = [
	preload("res://assets/audio/characters/Biker/damage_1_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_2_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_3_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_4_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_5_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_6_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_7_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_8_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_9_sean.wav"),
	preload("res://assets/audio/characters/Biker/damage_10_sean.wav"),
]
const DEATH_AUDIOS = [
	preload("res://assets/audio/characters/Biker/death_1_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_2_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_3_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_4_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_5_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_6_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_7_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_8_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_9_sean.wav"),
	preload("res://assets/audio/characters/Biker/death_10_sean.wav"),
]
const GRUNT_AUDIOS = {
	"jump": [preload("res://assets/audio/characters/Biker/grunting_1_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_2_sean.wav")],
	"attack":[preload("res://assets/audio/characters/Biker/grunting_1_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_2_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_3_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_4_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_5_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_6_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_7_sean.wav"),
	preload("res://assets/audio/characters/Biker/grunting_8_sean.wav")]
}

const SPEED = 350.0
const JUMP_VELOCITY = -400.0
var jump_count = 0
var jump_available = true

var x_direction
var x_speed

var last_frame
var last_anim
var last_melee
var last_attack
var attack

var shout = true
var grunt = true

signal health_changed
var dead = false
var health := 100.0 :
	set(value):
		if not is_dashing():
			if value <= 0 and health > 0:
				print("DEAD")
				dead = true
				play_voice(1, choose(DEATH_AUDIOS))
			if value < health and value > 0:
				if hurt_timer.is_stopped():
					play_voice(1, choose(DAMAGE_AUDIOS))
				if is_on_floor():
					hurt_timer.start()
			health = clamp(value, 0, 100)
			health_changed.emit()
var taken_damage = 0

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
	if dead: return
	for enemy in collided_enemies:
		if attack:
			enemy.health -= 0.5
	health -= taken_damage
	handle_movement(delta)
	handle_animation()

func handle_movement(delta):
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
	
	var regen_stamina = true
	attack = Input.is_action_pressed("attack") and stamina > 0 and hurt_timer.is_stopped()
	if attack:
		if grunt:
			play_voice(1+randf_range(-0.1, 0.1), choose(GRUNT_AUDIOS["attack"]))
			grunt = false
			grunt_timer.wait_time = randf_range(2, 5)
			grunt_timer.start()
		stamina -= 0.1 if armed else 0.05
		regen_stamina = false
	else:
		grunt = true
		grunt_timer.stop()
		if Input.is_action_pressed("attack"):
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
			stamina -= 75
		if is_dashing():
			x_speed *= 10
		velocity.x = x_direction * x_speed
		if regen_stamina:
			restore_stamina(0.3)
	else:
		if regen_stamina:
			restore_stamina(1)
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func handle_animation():
	if dead:
		play_anim("death", false, false)
		return
	if hurt_timer.is_stopped():
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
	else:
		play_anim("hurt", false, false)
		hand_sprite.visible = true
		weapon_sprite.visible = armed

func play_anim(anim:String, is_attacking: bool, melee: bool):
	# reset sprites
	player_sprite.position.y = -48
	hand_sprite.visible = false
	legs_sprite.visible = false
	
	# flip sprites
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
		attack_area.position.x += 50 * x_direction
		attack_area_armed.position.x += 70 * x_direction
	
	# can't attack when jump-/dashing
	if "jump" in anim or "dash" in anim:
		hurt_timer.stop()
		melee = false
	
	weapon_sprite.visible = melee
	
	var melee_str = "_melee" if melee else ""
	var attack_str = "_attack" if is_attacking else ""
	
	player_sprite.play(anim+attack_str+melee_str)
	
	# walk does not have an melee attack animation
	if melee:
		if anim != "walk":
			weapon_sprite.play(anim+attack_str)
		elif anim == "walk":
			if not is_attacking:
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
	if anim == last_anim and (last_melee != melee or last_attack != attack):
		player_sprite.frame = last_frame + 1
	weapon_sprite.frame = player_sprite.frame
	legs_sprite.frame = player_sprite.frame
	
	last_anim = anim
	last_melee = melee
	last_attack = is_attacking
	last_frame = player_sprite.frame

func play_voice(pitch_scale, audio):
	voice.pitch_scale = pitch_scale
	voice.stream = audio
	voice.play()

func choose(l: Array):
	return l[randi()%len(l)]

func _on_grunt_timer_timeout() -> void:
	grunt = true

func _on_attack_area_body_entered(body: Node2D) -> void:
	pass
	#if body.is_in_group("Enemy"):
		#collided_enemies.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
	pass

func _on_attack_area_armed_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		collided_enemies.append(body)

func _on_attack_area_armed_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		collided_enemies.remove_at(collided_enemies.find(body))
