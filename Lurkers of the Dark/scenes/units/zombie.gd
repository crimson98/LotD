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
var move_direction: Vector2
@onready var attack_cooldown 
@onready var despawn_timer = $Despawn_Timer
@onready var nav= $Pathfinder

var player_in_area = false
var players = []
var player_in_attack_range  = false
var players_being_attacked = []
var zombies_near= []

var destination= null
# movement destiny assigned by RTS player
var herd: Node2D= null
# node that calculates and holds boid info for movement
var separation: Vector2
# Vector used for calculating the separation of this zombie to others near 

func _ready():
	pass

func _physics_process(delta):
	_separation()
	move_and_slide()
	if dead:
		return
	attack_player()

func _process(delta):
	if multiplayer.get_unique_id()== 1:
		send_data.rpc(global_position, velocity)

func zombie_movement():
	if !dead:
		$Detection_Area/CollisionShape2D.disabled = false
		if len(players) > 0 and player_in_area:
			position += (players[0].position - position) / move_speed
		else:
			pass
	else:
		$Detection_Area/CollisionShape2D.disabled = true

func _on_detection_area_body_entered(body):
	if body.has_method("shooter_player"):
		player_in_area = true
		players.push_back(body)
	elif body.has_method("zombie"):
		zombies_near.push_back(body)

func _on_detection_area_body_exited(body):
	if body.has_method("shooter_player"):
		players.erase(body)
		if players.is_empty():
			player_in_area = false
	elif body.has_method("zombie"):
		zombies_near.erase(body)

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

func _separation():
	var mean_push= Vector2.ZERO
	for zombie in zombies_near:
		mean_push+= global_position - zombie.global_position
	separation= mean_push / len(zombies_near)
	separation= separation.normalized()

@rpc("any_peer", "call_local")
func get_damaged(dmg):
	Debug.log(str(get_class() + " has been damaged for " + str(dmg) + " damage"))
	health -= dmg

func set_herd(some_herd):
	herd= some_herd

func erase_from_herd():
	if herd!= null: 
		herd.leave_herd(self)
	herd= null

func kill():
	if dead:
		return
	dead = true
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CollisionShape2D.disabled = true
	z_index = -1
	erase_from_herd()
	despawn_timer.start()

func update_health():
	var health_bar = $HealthBar
	health_bar.value = health
	
	if health >= 100 or health <= 0:
		health_bar.visible = false
	else:
		health_bar.visible = true

@rpc("authority", "call_remote", "unreliable")
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)

@rpc ("any_peer", "call_local")
func free():
	queue_free()

func _on_despawn_timer_timeout():
	free.rpc()

func enemy():
	pass

func zombie():
	pass
