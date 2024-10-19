extends CharacterBody2D

@onready var vision_ray_cast: RayCast2D = $VisionRayCast
@onready var attack_range_ray_cast: RayCast2D = $AttackRangeRayCast
@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var hurt_timer: Timer = $HurtTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: TextureProgressBar = $HealthBar

var speed = 200.0

var health = 100: 
	set(value):
		if value <= 0 and health > 0:
			state = DEAD
			animated_sprite.play("death")
			$CollisionShape2D.disabled = true
			vision_ray_cast.enabled = false
			ground_ray_cast.enabled = false
			attack_range_ray_cast.enabled = false
		if value < health and state != DEAD:
			hurt_timer.start()
			state = HURT
		health = clamp(value, 0, 100)
		health_bar.value = health
var taken_damage = 0

enum {IDLE, WALK, CHASE, ATTACK, HURT, DEAD, EAT}
var state

var direction

func _ready() -> void:
	state = IDLE

func _physics_process(delta: float) -> void:
	if state in [DEAD, EAT]: return
	brain()
	handle_movement(delta)
	handle_animation()

func brain():
	if not hurt_timer.is_stopped():
		return
		
	if state in [IDLE, WALK]:
		# change state
		if not randi() % 10:
			state = IDLE if state==WALK else WALK
	
	if state != CHASE and vision_ray_cast.is_colliding():
		var player = vision_ray_cast.get_collider()
		if player is Player and !player.dead:
			if state == ATTACK and not attack_range_ray_cast.is_colliding():
				await get_tree().create_timer(0.5).timeout
			state = CHASE
	
	if state in [CHASE, ATTACK] and not vision_ray_cast.is_colliding():
		state = IDLE if randi() % 3 else WALK

	if attack_range_ray_cast.is_colliding():
		var player = attack_range_ray_cast.get_collider()
		if player is Player:
			if !player.dead:
				if state == CHASE:
					state = ATTACK
			else:
				state = EAT
				animated_sprite.play("eat")

func handle_movement(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match state:
		IDLE: direction = 0
		
		WALK:
			speed = 200
			direction = -1 if animated_sprite.flip_h else 1
			# change direction
			if not ground_ray_cast.is_colliding() or not randi() % 20:
				direction *= -1
		
		CHASE: 
			speed = 450
			direction = 1 if vision_ray_cast.get_collider().position.x > position.x else -1
		
		ATTACK: direction = 0
		
		HURT: direction = 0
		
		EAT: direction = 0
		
		DEAD: direction = 0
	
	velocity.x = direction * speed

	move_and_slide()

func handle_animation():
	var flip_h = false if direction == 1 else true if direction == -1 else animated_sprite.flip_h
	if animated_sprite.flip_h != flip_h:
		animated_sprite.flip_h = not animated_sprite.flip_h
		animated_sprite.position.x += 20 * direction
		attack_area.position.x += 20 * direction
		vision_ray_cast.target_position.x *= -1
		attack_range_ray_cast.target_position.x *= -1
		ground_ray_cast.target_position.x *= -1
	match state:
		IDLE: animated_sprite.play("idle")
		WALK: animated_sprite.play("walk")
		CHASE: animated_sprite.play("walk")
		ATTACK: animated_sprite.play("attack")
		HURT: animated_sprite.play("hurt")
		EAT: animated_sprite.play("eat")

func _on_attack_area_body_entered(body: Node2D) -> void:
	# TODO only when attack?
	if state != DEAD and body is Player:
		body.taken_damage += 0.3

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is Player:
		body.taken_damage = 0
