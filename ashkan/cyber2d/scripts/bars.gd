extends Node2D

var health
var stamina
@export var player : CharacterBody2D
@onready var health_bar_1: TextureProgressBar = $Health/HealthBar1
@onready var health_bar_2: TextureProgressBar = $Health/HealthBar2
@onready var stamina_bar_1: TextureProgressBar = $Stamina/StaminaBar1
@onready var stamina_bar_2: TextureProgressBar = $Stamina/StaminaBar2
@onready var stamina_bar_3: TextureProgressBar = $Stamina/StaminaBar3
@onready var stamina_bar_4: TextureProgressBar = $Stamina/StaminaBar4

func _ready() -> void:
	update_health()
	player.health_changed.connect(update_health)
	player.stamina_changed.connect(update_stamina)
	
func update_health() -> void:
	health = player.health
	health_bar_1.value = health
	health_bar_2.value = health - 50
	
func update_stamina() -> void:
	stamina = player.stamina
	stamina_bar_1.value = stamina
	stamina_bar_2.value = stamina - 25
	stamina_bar_3.value = stamina - 50
	stamina_bar_4.value = stamina - 75

	
