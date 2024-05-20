extends CharacterBody2D

@export var dead = false:
	get:
		return dead
	set(val):
		dead = val
		
@export var health = 100:
	get:
		return health
	set(val):
		health = max(val, 0)
		if health <= 0:
			dead = true
		update_health()

var move_speed = 200
var damage = 10
@onready var attack_cooldown = $Attack_Cooldown

var player_in_area = false
var players = []
var player_in_attack_range  = false
var players_being_attacked = []


func _ready():
	dead = false


func _physics_process(delta):
	zombie_movement()
	attack_player()
	
	
func zombie_movement():
	if !dead:
		$Detection_Area/CollisionShape2D.disabled = false
		if player_in_area:
			position += (players[0].position - position) / move_speed
		else:
			pass
	
	if dead:
		$Detection_Area/CollisionShape2D.disabled = true
	

func _on_detection_area_body_entered(body):
	if body.has_method("shooter_player"):
		player_in_area = true
		players.push_back(body)


func _on_detection_area_body_exited(body):
	if body.has_method("shooter_player"):
		players.erase(body)
		if players.is_empty():
			player_in_area = false


func _on_hitbox_body_entered(body):
	if body.has_method("shooter_player"):
		player_in_attack_range = true
		players_being_attacked.push_back(body)


func _on_hitbox_body_exited(body):
	if body.has_method("shooter_player"):
		players_being_attacked.erase(body)
		if players_being_attacked.is_empty():
			player_in_attack_range = false


func attack_player():
	if player_in_attack_range and attack_cooldown.is_stopped():
		players_being_attacked[0].health -= 20
		attack_cooldown.start()
	


func take_damage(damage):
	if is_multiplayer_authority():
		health -= damage
					

func update_health():
	var health_bar = $HealthBar
	health_bar.value = health
	
	if health >= 100:
		health_bar.visible = false
	else:
		health_bar.visible = true


func enemy():
	pass

@rpc
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)