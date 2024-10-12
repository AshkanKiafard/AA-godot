extends CharacterBody2D

# Movement and jump constants
const SPEED = 100.0
const RUN_SPEED = 180.0
const SLOWED_SPEED = 60.0
const JUMP_VELOCITY = -250.0
const SLOWED_JUMP_VELOCITY = -150.0
const STAMINA_DEPLETION_RATE = 20
const STAMINA_RECOVERY_RATE = 20
const JUMP_STAMINA_COST = 20.0
const RECOVERY_DELAY = 0.5

# Oxygen related variables
var max_oxygen = 100.0
var current_oxygen = max_oxygen
var oxygen_depletion_rate = 20.0
var oxygen_recovery_rate = 30.0
var oxygen_depleted = false
var is_in_water = false
var swim_speed = 50.0

# Stamina variables
var stamina_depleted = false
var jumps_left = 2
var max_stamina = 100.0
var current_stamina = max_stamina
var recovery_timer = 0.0

# References
@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $"../CanvasLayer/HealthBar"
@onready var stamina_bar: ProgressBar = $"../CanvasLayer/StaminaBar"
@onready var oxygen_bar: ProgressBar = $"../CanvasLayer/OxygenBar"

func _physics_process(delta: float) -> void:
	var current_speed = SPEED
	var current_jump_velocity = JUMP_VELOCITY

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
		# Swimming in water (free movement)
		current_speed = swim_speed
		velocity.y = move_toward(velocity.y, 0, swim_speed * delta)
		
		# Deplete oxygen over time
		current_oxygen -= oxygen_depletion_rate * delta
		if current_oxygen <= 0:
			current_oxygen = 0
			oxygen_depleted = true
			# Handle drowning or other effects here
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

	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		if stamina_depleted:
			velocity.y = SLOWED_JUMP_VELOCITY
		elif current_stamina >= JUMP_STAMINA_COST:
			velocity.y = current_jump_velocity
			current_stamina -= JUMP_STAMINA_COST
		jumps_left -= 1

	# Handle movement direction
	var direction = Input.get_axis("ui_left", "ui_right")
	if is_in_water:
		# Allow full swimming control (up, down, left, right)
		var swim_direction_y = Input.get_axis("ui_up", "ui_down")
		velocity.y = swim_direction_y * swim_speed
		velocity.x = direction * swim_speed
	else:
		# Normal movement on land
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
