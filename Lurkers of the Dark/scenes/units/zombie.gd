extends CharacterBody2D
class_name Zombie

@export var dead = false:
	get:
		return dead
	set(val):
		dead = val
		
@export var health = 10:
	get:
		return health
	set(val):
		health = max(val, 0)
		if health <= 0:
			kill()
		update_health()

var move_speed
var damage
@onready var attack_cooldown

var player_in_area = false
var players = []
var player_in_attack_range  = false
var players_being_attacked = []


func _ready():
	pass


func _physics_process(delta):
	if dead:
		return
		
	zombie_movement()
	attack_player()
	
	
func zombie_movement():
	if !dead:
		$Detection_Area/CollisionShape2D.disabled = false
		if len(players) > 0 and player_in_area:
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
		players_being_attacked[0].health -= damage
		
		if players_being_attacked[0].dead:
			players.erase(players_being_attacked[0])
			
			if players.is_empty():
				player_in_area = false
				
		attack_cooldown.start()
	

func take_damage(damage):
	if is_multiplayer_authority():
		health -= damage


func kill():
	if dead:
		return
	dead = true
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CollisionShape2D.disabled = true
	z_index = -1


func update_health():
	var health_bar = $HealthBar
	health_bar.value = health
	
	if health >= 100 or health <= 0:
		health_bar.visible = false
	else:
		health_bar.visible = true


func enemy():
	pass

@rpc
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
