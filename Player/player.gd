class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealhProgressBar


var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0


signal meat_collected(value:int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): GameManager.meat_counter += 1)

func _process(delta: float)-> void:
	GameManager.player_position = position
	
	# Obter o input_vector
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	
	
	# Apaga o deadzone do input_vector corrigindo o erro do joystick
	var deadzone = 0.15
	# a função matememática abs aceita qualquer valor e transforma em positivo
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
	
	# Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown < 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
	
	# Processar o dano
	update_hitbox_detection(delta)
	
	# Ritual
	update_ritual(delta)
	
	# Atualizar health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
	
func _physics_process(delta: float)-> void:
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity,target_velocity,0.05)
	move_and_slide()
	
	# Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()
	# o is_zero_approx() serve pra determinar se um valor e igual a zero
	
	# Tocar a animação
	 
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
	
	# Girar o sprite
	if not is_attacking:
		if input_vector.x > 0:
			sprite.flip_h = false
		elif input_vector.x < 0:
			sprite.flip_h = true

	# Ataque
	if Input.is_action_just_pressed("attack"):
		attack()
	
	
	
func  update_ritual(delta: float) -> void:
	# Atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	# Criar o ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	
	
	
func attack() -> void:
	
	# Calcular o ângulo do input_vector
	var angle = atan2(input_vector.y, input_vector.x) *  (180.0 / PI)
	var animation_to_play = "attack_side1"
	
	# Arredondar o ângulo para as direções principais
	if angle >= -45 and angle <= 45:
		animation_to_play = "attack_side1"  # Direita
	elif angle > 45 and angle < 135:
		animation_to_play = "attack_down1"  # Baixo
	elif angle >= 135 or angle <= -135:
		animation_to_play = "attack_side1"  # Esquerda
	elif angle > -135 and angle < -45:
		animation_to_play = "attack_up1"    # Cima
	
	# Tocar animação
	animation_player.play(animation_to_play)
	
	# Configurar temporizador
	attack_cooldown = 0.6
	
	# Marcar ataque
	is_attacking = true
	
	
func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage) 
				print("Dot: ", dot_product)


func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0:return
	
	# Frequência
	hitbox_cooldown = 0.5
	
	# Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body 
			var damage_amount = 1
			damage(damage_amount)
	

func damage(amount: int) -> void:
	if health <= 0:return
	
	health -= amount
	print("Player recebeu dano de ", amount, ". A vida total é de ", health, "/", max_health)
	
	# Piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Processar morte
	if health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Player morreu!")
	queue_free()


func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health
		print("Player recebeu cura de ", amount, ". A vida total é de ", health, "/", max_health)
	return health





