class_name Player
extends CharacterBody2D

@export var game_manager: Node
@export var armed: bool
# camera shake
@export var shake_fade: float = 10.0
var shake_strength: float = 0.0

@onready var dash_particles: GPUParticles2D = $DashParticles2D
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
@onready var blood: AnimatedSprite2D = $Blood

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
const SHOCK_WAVE = preload("res://scenes/objects/shock_wave.tscn")

const SPEED = 300.0
const JUMP_VELOCITY = -300.0
var jump_count = 0

var x_direction
var x_speed

var last_frame
var last_anim
var last_melee
var last_attack
var attack

var announce

var shout = true
var grunt = true

signal health_changed
var dead = false
var health := 100.0 :
	set(value):
		if not is_dashing() and !game_manager.game_over:
			if value <= 0 and health > 0:
				print("DEAD")
				hurt_timer.stop()
				dead = true
				play_voice(1, choose(DEATH_AUDIOS))
				play_anim("death", false, false)
				game_manager.show_game_over()
			if value < health and value > 0 and not dead:
				if is_on_floor():
					hurt_timer.start()
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
	
func is_special_attacking():
	return player_sprite.is_playing() and player_sprite.animation == "special"

func _physics_process(delta: float) -> void:
	if dead || game_manager.game_over:
		velocity += get_gravity() * delta
		velocity.x = 0
		move_and_slide()
		return
	# shake camera
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
		$Camera2D.offset = rand_offset()
	handle_combat()
	handle_movement(delta)
	handle_animation()

func handle_combat():
	if len(collided_enemies) >= 1:
		var enemy = collided_enemies[0]
		if attack and enemy.health > 0:
			enemy.knockback = true
			enemy.knockback_force_y = 0
			enemy.attack_side = 1 if position.x <= enemy.position.x else 0
			var critical = 2 if randi() % 5 == 0 else 1
			enemy.is_critical = true if critical == 2 else false
			if !armed:
				if stamina > 80:
					if player_sprite.frame == 4 or player_sprite.frame == 7:
						frame_freeze(0.1, 0.4)
						stamina -= 70
						enemy.knockback_force_x = 500
						enemy.knockback_force_y = 500
						enemy.is_critical = true
						enemy.health -= 70 + randi_range(0, 5)
						game_manager.play_praise_voice(enemy.health)
						if enemy.health <= 0:
							game_manager.play_sound_effect("res://assets/audio/combat/fist/ko/", 3)
						else:
							game_manager.play_sound_effect("res://assets/audio/combat/fist/superpunch/", 3)
						apply_shake(20)
						collided_enemies.remove_at(collided_enemies.find(enemy))
				else:
					game_manager.play_sound_effect("res://assets/audio/combat/fist/punch/", 4)
					enemy.knockback_force_y = 0
					if player_sprite.frame == 4 or player_sprite.frame == 7:
						enemy.knockback_force_x = 20
						apply_shake(1)
					else:
						enemy.knockback_force_x = 0
					enemy.health -= (0.3 + randi_range(0, 3) / 10.0) * critical
			else:
				game_manager.play_sound_effect("res://assets/audio/combat/melee/", 2)
				enemy.knockback_force_x = 10
				enemy.health -= (1.5 + randi_range(0, 10) / 10.0) * critical
	
	if Input.is_action_just_pressed("swap_weapon"):
		armed = !armed
		$AttackArea/CollisionShape2D.disabled = armed
		$AttackAreaArmed/CollisionShape2D.disabled = !armed
	
	if Input.is_action_just_pressed("special_attack"):
		play_anim("special", false, false)

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
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_count = 0
		jump_count += 1
		if jump_count <= 3 and (stamina > 25 or jump_count == 1) :
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
	flip_sprites()
	
	var regen_stamina = true
	attack = Input.is_action_pressed("attack") and stamina > 0 and (hurt_timer.is_stopped() or !armed)
	if attack:
		if grunt:
			play_voice(1+randf_range(-0.1, 0.1), choose(GRUNT_AUDIOS["attack"]))
			grunt = false
			grunt_timer.wait_time = randf_range(2, 5)
			grunt_timer.start()
		stamina -= 0.2 if armed else 0.1
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
			collision_mask = 1
			dash_particles.emitting = true
		else:
			collision_mask = 5
			dash_particles.emitting = false
		velocity.x = x_direction * x_speed
		if regen_stamina:
			restore_stamina(0.3)
	else:
		if regen_stamina:
			restore_stamina(1)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_special_attacking():
		velocity.x = 0
		
	if velocity.x == 0:
		dash_particles.emitting = false
	
	move_and_slide()

func handle_animation():
	if dead:
		return
	if hurt_timer.is_stopped() or (!armed and attack):
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
		if blood.frame == 4:
			apply_shake(3)
			if !voice.playing:
				play_voice(1+randf_range(-0.05, 0.05), choose(DAMAGE_AUDIOS))
			blood.play(str(randi()%4+1))
		hand_sprite.visible = armed
		weapon_sprite.visible = armed

func play_anim(anim:String, is_attacking: bool, melee: bool):
	# reset sprites
	player_sprite.position.y = -48
	hand_sprite.visible = false
	legs_sprite.visible = false
	
	if is_special_attacking() and !dead:
		weapon_sprite.visible = false
		if player_sprite.frame > 5:
			if announce:
				announce = false
				game_manager.play_praise_voice(100)
			apply_shake(30)
			frame_freeze(0.3, 0.3)
			var shock_wave1 = SHOCK_WAVE.instantiate()
			shock_wave1.direction = 1
			var shock_wave2 = SHOCK_WAVE.instantiate()
			shock_wave2.direction = -1
			if not player_sprite.flip_h:
				shock_wave1.position = Vector2(position.x + 100, position.y)
				shock_wave2.position = Vector2(position.x - 50, position.y)
			else:
				shock_wave1.position = Vector2(position.x + 50, position.y)
				shock_wave2.position = Vector2(position.x - 100, position.y)
			get_tree().root.add_child(shock_wave1)
			get_tree().root.add_child(shock_wave2)
		return
	else:
		announce = true
		
	# can't attack when jump-/dash-/specialing
	if "jump" in anim or anim == "dash":
		hurt_timer.stop()
		melee = false
	
	weapon_sprite.visible = melee
	
	var melee_str = "_melee" if melee else ""
	var attack_str = "_attack" if is_attacking else ""
	
	player_sprite.play(anim+attack_str+melee_str)
	
	if melee:
		# walk does not have melee animations
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
	if body.is_in_group("Enemy"):
		collided_enemies.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body in collided_enemies:
		collided_enemies.remove_at(collided_enemies.find(body))

func _on_attack_area_armed_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		collided_enemies.append(body)

func _on_attack_area_armed_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body in collided_enemies:
		collided_enemies.remove_at(collided_enemies.find(body))

func frame_freeze(time_scale, duration):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration*time_scale).timeout
	Engine.time_scale = 1
	
func flip_sprites():
	# flip sprites
	var flip_h = false if x_direction == 1 else true if x_direction == -1 else player_sprite.flip_h
	dash_particles.scale.x = 1 if x_direction == 1 else -1 if x_direction == -1 else dash_particles.scale.x 
	if player_sprite.flip_h != flip_h:
		player_sprite.flip_h = flip_h
		weapon_sprite.flip_h = flip_h
		hand_sprite.flip_h = flip_h
		legs_sprite.flip_h = flip_h
		blood.flip_h = flip_h
		# correct the sprite offset
		player_sprite.position.x += 40 * x_direction
		weapon_sprite.position.x += 40 * x_direction
		legs_sprite.position.x += 40 * x_direction
		blood.position.x -= 45 * x_direction
		hand_sprite.position.x += 20 * x_direction
		hand_sprite.rotation += 45 * x_direction
		attack_area.position.x += 60 * x_direction
		attack_area_armed.position.x += 80 * x_direction

# camera shake
func apply_shake(strength):
	shake_strength = strength

func rand_offset():
	return Vector2(randf_range(-shake_strength, shake_strength), 0)

func check_for_grabs():
	pass
