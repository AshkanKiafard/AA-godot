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
var MAX_HEALTH = 100.0
var current_health = MAX_HEALTH

# Stamina variables
var stamina_depleted = false
var jumps_left = 2
var max_stamina = 100.0
var current_stamina = max_stamina
var recovery_timer = 0.0

# Oxygen related variables
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

# References
@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $"../CanvasLayer/HealthBar"
@onready var stamina_bar: ProgressBar = $"../CanvasLayer/StaminaBar"
@onready var oxygen_bar: ProgressBar = $"../CanvasLayer/OxygenBar"

func _physics_process(delta: float) -> void:
	var current_speed = SPEED
	var current_jump_velocity = JUMP_VELOCITY

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
		health_bar.value = current_health

func increase_health(amount: float) -> void:
	current_health += amount
	if current_health > MAX_HEALTH:
		current_health = MAX_HEALTH
	health_bar.value = current_health
