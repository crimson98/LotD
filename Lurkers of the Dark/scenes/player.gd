extends CharacterBody2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var gun_position= $GunPos
@onready var ammo_counter= $AmmoCounter
@export var bullet_scene: PackedScene
@export var speed = 200
@export var health = 100
@export var curr_health = health
@export var look_direction = Vector2.ZERO

var dead = false
var pickable_weapons_in_range= []
var weapon_in_hand: Node2D = null

@export var score = 1 :
	set(value):
		score = value
		# Debug.log("Player %s score %d" % [name, score])

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		velocity = move_dir * speed
		look_direction= lerp(look_direction, get_global_mouse_position(), 0.05)
		send_data.rpc(global_position, velocity, look_direction)
	move_and_slide()
	look_at(look_direction)
	# funny thing, it still works even if you are outside the window
	

func _process(_delta):
	Debug.log(pickable_weapons_in_range)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc(Game.get_current_player().name)
			var bullet = bullet_scene.instantiate()
			# spawner will spawn a bullet on every simulated
			multiplayer_spawner.add_child(bullet, true)
			# triggers syncronizer
			# score += 1
	
	if event.is_action_pressed("interact") and len(pickable_weapons_in_range)> 0:
		_pick_up_weapon.rpc()
		# if weapon_in_hand!= null:
			# ammo_counter.text= str(weapon_in_hand.current_clip) + "/" + str(weapon_in_hand.current_ammo)
		
	if event.is_action_pressed("drop_weapon") and weapon_in_hand!= null:
		_drop_weapon.rpc()
		# if weapon_in_hand== null:
			# ammo_counter.text= ""
	
	if event.is_action_pressed("fire") and weapon_in_hand!= null:
		weapon_in_hand.fire()

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)

func _update_ammo_counter():
	if weapon_in_hand!= null:
		ammo_counter.text= str(weapon_in_hand.current_clip) + "/" + str(weapon_in_hand.current_ammo)

@rpc("any_peer", "call_local", "reliable")
func _pick_up_weapon():
	weapon_in_hand= pickable_weapons_in_range.pop_front()
	if weapon_in_hand!= null:
		weapon_in_hand.pick_up.rpc()
		gun_position.add_child(weapon_in_hand)
		weapon_in_hand.position= Vector2.ZERO
	# this is giving some problems

@rpc("any_peer", "call_local", "reliable")
func _drop_weapon():
	if weapon_in_hand!= null:
		gun_position.remove_child(weapon_in_hand)
		get_parent().add_child(weapon_in_hand)
		var throw_direction= get_global_mouse_position() - global_position
		if is_multiplayer_authority():
			weapon_in_hand.drop.rpc(gun_position.global_position, throw_direction.normalized())
		weapon_in_hand= null

func receive_dmg(dmg: int):
	curr_health =- dmg
	if curr_health <= 0:
		kill()

func kill():
	if dead:
		return
	dead = true
	$Graphics/Alive.hide()
	$Graphics/Dead.show()
	z_index = -1	
	
@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	# Debug.log(message)
	# Debug.log(sender_player.name)

@rpc
func send_data(pos: Vector2, vel: Vector2, look: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	look_direction= lerp(look_direction, look, 0.75)
	
	
