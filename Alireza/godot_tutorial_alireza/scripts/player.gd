extends CharacterBody2D

# Movement and jump constants
const SPEED = 100.0
const RUN_SPEED = 180.0
const SLOWED_SPEED = 60.0
const JUMP_VELOCITY = -250.0
const ROLL_SPEED = 200.0
const ROLL_COST = 20.0
const SLOWED_JUMP_VELOCITY = -150.0
const STAMINA_DEPLETION_RATE = 20
const STAMINA_RECOVERY_RATE = 20
const JUMP_STAMINA_COST = 20.0
const RECOVERY_DELAY = 0.5
const ROLL_DURATION = 0.5
const WATER_MOVEMENT_RATE = 0.75

# Health variables
@export var max_health: float = 100.0
var current_health: float = max_health

# Stamina variables
var stamina_depleted = false
var jumps_left = 2
var max_stamina = 100.0
var current_stamina = max_stamina
var recovery_timer = 0.0

# Oxygen variables
var max_oxygen = 100.0
var current_oxygen = max_oxygen
var oxygen_depletion_rate = 15.0
var oxygen_recovery_rate = 30.0
var oxygen_depleted = false
var is_in_water = false
var SWIM_SPEED = 50.0
const FAST_SWIM_SPEED = 80.0

# Roll
var is_invulnerable = false
var is_rolling = false
var roll_timer = 0.0

# Damage animation
var damage_animation_timer = 0.0
var damage_animation_duration = 0.1
var is_damaged = false
var hurt_audio_cooldown = 0.5
var hurt_audio_timer = 0.0 

# Death animation variables
var is_dead = false
var death_animation_duration = 0.375
var death_timer = 0.0

# References
@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $"../CanvasLayer/HealthBar"
@onready var stamina_bar: ProgressBar = $"../CanvasLayer/StaminaBar"
@onready var oxygen_bar: ProgressBar = $"../CanvasLayer/OxygenBar"

# Audios
@onready var jump_audio: AudioStreamPlayer2D = $JumpAudio
@onready var hurt_audio: AudioStreamPlayer2D = $HurtAudio

func _physics_process(delta: float) -> void:
	var current_speed = SPEED
	var current_jump_velocity = JUMP_VELOCITY
	
	if is_dead:
		death_timer += delta
		if death_timer >= death_animation_duration:
			restart_game()
		return
	
	if hurt_audio_timer > 0:
		hurt_audio_timer -= delta
		
	# Roll handling
	if is_rolling:
		roll_timer += delta
		if roll_timer >= ROLL_DURATION:
			is_rolling = false
			is_invulnerable = false
			roll_timer = 0.0
		else:
			velocity.x = Input.get_axis("ui_left", "ui_right") * ROLL_SPEED
			animation_sprite.play("roll")
			move_and_slide()
			return

	# Allow rolling only when not in water
	if Input.is_action_just_pressed("ui_down") and not stamina_depleted and not is_rolling and is_on_floor() and not is_in_water:
		if current_stamina >= ROLL_COST:
			current_stamina -= ROLL_COST
			is_rolling = true
			is_invulnerable = true
			velocity.x = Input.get_axis("ui_left", "ui_right") * ROLL_SPEED
			animation_sprite.play("roll")
		else:
			return

	# Handle running and stamina depletion
	if Input.is_physical_key_pressed(KEY_SHIFT) and current_stamina > 0:
		current_speed = RUN_SPEED
		current_stamina -= STAMINA_DEPLETION_RATE * delta
		if current_stamina <= 0:
			current_stamina = 0
			stamina_depleted = true
			recovery_timer = 0.0
	else:
		current_speed = SPEED

	# Stamina recovery logic
	if not Input.is_physical_key_pressed(KEY_SHIFT):
		if stamina_depleted:
			recovery_timer += delta
			if recovery_timer >= RECOVERY_DELAY:
				if current_stamina < max_stamina:
					current_stamina += STAMINA_RECOVERY_RATE * delta
					if current_stamina > max_stamina:
						current_stamina = max_stamina
		else:
			if current_stamina < max_stamina:
				current_stamina += STAMINA_RECOVERY_RATE * delta
				if current_stamina > max_stamina:
					current_stamina = max_stamina

	# If stamina is depleted, slow down movement and jump velocity
	if stamina_depleted:
		current_speed = SLOWED_SPEED
		current_jump_velocity = SLOWED_JUMP_VELOCITY
		if current_stamina > 0:
			stamina_depleted = false
			recovery_timer = 0.0

	stamina_bar.value = current_stamina

	# Oxygen depletion and swimming control
	if is_in_water:
		current_speed *= WATER_MOVEMENT_RATE
		velocity.y = move_toward(velocity.y, 0, current_speed * delta)

		# Deplete oxygen over time
		current_oxygen -= oxygen_depletion_rate * delta
		if current_oxygen <= 0:
			current_oxygen = 0
			decrease_health(0.5)
			oxygen_depleted = true
	else:
		# Recover oxygen when out of water
		if current_oxygen < max_oxygen:
			current_oxygen += oxygen_recovery_rate * delta
			if current_oxygen > max_oxygen:
				current_oxygen = max_oxygen
		oxygen_depleted = false

	oxygen_bar.value = current_oxygen

	# Handle jumping
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps_left = 2

	# Allow jumping only when not in water
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0 and not is_in_water:
		if stamina_depleted:
			velocity.y = SLOWED_JUMP_VELOCITY
		elif current_stamina >= JUMP_STAMINA_COST:
			velocity.y = current_jump_velocity
			current_stamina -= JUMP_STAMINA_COST
			jump_audio.play() 
		jumps_left -= 1

	# Handle movement direction
	var direction = Input.get_axis("ui_left", "ui_right")

	if is_in_water:
		var swim_direction_y = Input.get_axis("ui_up", "ui_down")
		if swim_direction_y:
			velocity.y = swim_direction_y * (current_speed * WATER_MOVEMENT_RATE)
		else:
			velocity.y /= 1.25
		velocity.x = direction * (current_speed * WATER_MOVEMENT_RATE)
	else:
		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)

	# Handle animations
	
	if is_damaged:
		animation_sprite.play("damage")
		damage_animation_timer += delta
		if damage_animation_timer >= damage_animation_duration:
			is_damaged = false
			damage_animation_timer = 0.0
	else:
		if direction < 0:
			animation_sprite.flip_h = true
		elif direction > 0:
			animation_sprite.flip_h = false

		if is_on_floor():
			if direction == 0:
				animation_sprite.play("idle")
			else:
				animation_sprite.play("run")
		else:
			animation_sprite.play("jump")

	move_and_slide()

func set_in_water(in_water: bool) -> void:
	is_in_water = in_water

func decrease_health(amount: float) -> void:
	if not is_invulnerable:
		current_health -= amount
		if current_health < 0:
			current_health = 0
			if not is_dead:
				is_dead = true
				Engine.time_scale = 0.2
				animation_sprite.play("death")
				return

		if hurt_audio_timer <= 0:
			hurt_audio.play()
			hurt_audio_timer = hurt_audio_cooldown
		update_health_bar()

		is_damaged = true
		damage_animation_timer = 0.0
		
		if velocity.x < 0:
			animation_sprite.flip_h = true
		elif velocity.x > 0:
			animation_sprite.flip_h = false


func increase_health(amount: float) -> void:
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	update_health_bar()

func update_health_bar() -> void:
	health_bar.value = current_health / max_health * 100.0
	
func restart_game() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
