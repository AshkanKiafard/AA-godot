extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 180.0
const SLOWED_SPEED = 60.0
const JUMP_VELOCITY = -250.0
const SLOWED_JUMP_VELOCITY = -150.0
const STAMINA_DEPLETION_RATE = 20
const STAMINA_RECOVERY_RATE = 20
const JUMP_STAMINA_COST = 20.0
const RECOVERY_DELAY = 0.5

var stamina_depleted = false
var jumps_left = 2
var max_stamina = 100.0
var current_stamina = max_stamina
var recovery_timer = 0.0

@onready var animation_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var current_speed = SPEED
	var current_jump_velocity = JUMP_VELOCITY

	if Input.is_physical_key_pressed(KEY_SHIFT) and current_stamina > 0:
		current_speed = RUN_SPEED
		current_stamina -= STAMINA_DEPLETION_RATE * delta
		if current_stamina <= 0:
			current_stamina = 0
			stamina_depleted = true
			recovery_timer = 0.0
	else:
		current_speed = SPEED

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

	if stamina_depleted:
		current_speed = SLOWED_SPEED
		current_jump_velocity = SLOWED_JUMP_VELOCITY
		if current_stamina > 0:
			stamina_depleted = false
			recovery_timer = 0.0

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps_left = 2

	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		if stamina_depleted:
			velocity.y = SLOWED_JUMP_VELOCITY
			jumps_left -= 1
		elif current_stamina >= JUMP_STAMINA_COST:
			velocity.y = current_jump_velocity
			jumps_left -= 1
			current_stamina -= JUMP_STAMINA_COST

	var direction = Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		if direction == 0:
			animation_sprite.play("idle")
		else:
			animation_sprite.play("run")
	else:
			animation_sprite.play("jump")
	
	
	if direction < 0:
		animation_sprite.flip_h = true
	elif direction > 0:
		animation_sprite.flip_h = false
	
	if direction:
		velocity.x = direction * current_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		
	

	move_and_slide()

	$TextureProgressBar.value = current_stamina
