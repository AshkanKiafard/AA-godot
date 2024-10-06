extends CharacterBody2D
	
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var jump_count = 0
var stamina = 0
signal stamina_changed;

func set_jump_count(value) -> void:
	jump_count = value

func set_stamina(value) -> void:
	stamina = value
	stamina_changed.emit()
	
func restore_stamina(value) -> void:
	if is_on_floor():
		stamina = min(0, stamina + value)
		stamina_changed.emit()
	
func deplete_stamina(value) -> void:
	stamina = max(-100, stamina - value)
	stamina_changed.emit()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			jump_count = 0
		jump_count += 1
		if jump_count <= 1 or (jump_count == 2 and stamina > -75):
			deplete_stamina(25)
			velocity.y = JUMP_VELOCITY - (stamina * 2)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var temp_speed = SPEED
	if direction:
		if stamina > -100 and Input.is_physical_key_pressed(KEY_SHIFT):
			temp_speed += 100 + stamina
			deplete_stamina(1)
		else:
			restore_stamina(1)
		velocity.x = direction * temp_speed
	else:
		restore_stamina(1)
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
