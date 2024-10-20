extends CharacterBody2D

@export var walk_speed := 200.0
@export var run_speed := 350
@onready var vision_ray_cast: RayCast2D = $VisionRayCast
@onready var vision_ray_cast2: RayCast2D = $VisionRayCast2
@onready var attack_range_ray_cast: RayCast2D = $AttackRangeRayCast
@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var hurt_timer: Timer = $HurtTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stun_timer: Timer = $StunTimer

var collided_players: Array
var speed = walk_speed

var health = 100: 
	set(value):
		if value <= 0 and health > 0:
			state = DEAD
			animated_sprite.play("death")
			$CollisionShape2D.disabled = true
			vision_ray_cast.enabled = false
			vision_ray_cast2.enabled = false
			ground_ray_cast.enabled = false
			attack_range_ray_cast.enabled = false
		if value < health - 0.1 and state != DEAD:
			hurt_timer.start()
			state = HURT
		health = clamp(value, 0, 100)
		health_bar.value = health
var taken_damage = 0

enum {IDLE, WALK, CHASE, ATTACK, HURT, DEAD, EAT, STUN, WAKE_UP}
var state

var direction

func _ready() -> void:
	state = IDLE

func _physics_process(delta: float) -> void:
	if state in [DEAD, EAT]: return
	for player in collided_players:
		if state == ATTACK and !player.dead:
			player.health -= 0.1
	brain()
	handle_movement(delta)
	handle_animation()

func brain():
	if not hurt_timer.is_stopped() or not stun_timer.is_stopped():
		return
		
	if state in [IDLE, WALK]:
		# change state
		if not randi() % 10:
			state = IDLE if state==WALK else WALK
	
	if state != CHASE and is_seeing_player():
		var player = get_seen_player()
		if !player.dead:
			if state == ATTACK and not attack_range_ray_cast.is_colliding():
				await get_tree().create_timer(0.5).timeout
			state = CHASE
	
	if state in [CHASE, ATTACK] and not is_seeing_player():
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
		WALK:
			speed = walk_speed
			direction = -1 if animated_sprite.flip_h else 1
			# change direction
			if not ground_ray_cast.is_colliding() or not randi() % 20:
				direction *= -1
		
		CHASE: 
			speed = run_speed
			direction = 1 if is_seeing_player() and get_seen_player().position.x > position.x else -1
		
		_: direction = 0
	
	velocity.x = direction * speed

	move_and_slide()

func handle_animation():
	var flip_h = false if direction == 1 else true if direction == -1 else animated_sprite.flip_h
	if animated_sprite.flip_h != flip_h:
		animated_sprite.flip_h = not animated_sprite.flip_h
		animated_sprite.position.x += 20 * direction
		attack_area.position.x += 20 * direction
		vision_ray_cast.target_position.x *= -1
		vision_ray_cast2.target_position.x *= -1
		attack_range_ray_cast.target_position.x *= -1
		ground_ray_cast.target_position.x *= -1
	match state:
		IDLE: animated_sprite.play("idle")
		WALK: animated_sprite.play("walk")
		CHASE: animated_sprite.play("walk")
		ATTACK: animated_sprite.play("attack")
		HURT: animated_sprite.play("hurt")
		EAT: animated_sprite.play("eat")
		STUN: animated_sprite.play("death")
		WAKE_UP: animated_sprite.play("wake_up")

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collided_players.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collided_players.remove_at(collided_players.find(body))

func _on_stun_area_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("Player") and state != DEAD:
		state = STUN
		stun_timer.start()

func _on_stun_timer_timeout() -> void:
	if state == STUN and state != DEAD:
		state = WAKE_UP
		stun_timer.start()
	else:
		state = IDLE
		stun_timer.stop()

func is_seeing_player():
	return ray_cast_sees_player(vision_ray_cast) or ray_cast_sees_player(vision_ray_cast2)
	
func get_seen_player():
	return vision_ray_cast.get_collider() if ray_cast_sees_player(vision_ray_cast) else vision_ray_cast2.get_collider()

func ray_cast_sees_player(ray_cast: RayCast2D):
	return ray_cast.is_colliding() and ray_cast.get_collider() is Player
