extends CharacterBody2D

signal health_changed(value)

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var gun_position= $GunPos
@onready var gui: CanvasLayer = $GUI
@onready var game_over_screen: Control = $GameOverScreen/GameOverScreen

@export var bullet_scene: PackedScene
@export var db_shotgun_scene: PackedScene

@export var speed = 800
@export var look_direction = Vector2.ZERO
@export var health = 100:
	get:
		return health
	set(val):
		health = max(val, 0)
		health_changed.emit(health)
		if health <= 0:
			kill()

@export var dead = false:
	get:
		return dead
	set(val):
		dead = val


@export var score = 1 :
	set(value):
		score = value
		# Debug.log("Player %s score %d" % [name, score])

var player_id:
	set(value):
		player_id = value

@onready var weapon_in_hand: Node2D = null
var pickable_weapons_in_range= []

func _ready():
	gui.update_health(health)
	health_changed.connect(gui.update_health)
	gui.hide()
	game_over_screen.hide()

func _physics_process(delta: float) -> void:
	if dead:
		return
	if is_multiplayer_authority():
		var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		velocity = move_dir * speed
		look_direction= lerp(look_direction, get_global_mouse_position(), 0.05)
		send_data.rpc(global_position, velocity, look_direction)
	move_and_slide()
	look_at(look_direction)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("interact") and len(pickable_weapons_in_range)> 0:
			if weapon_in_hand== null:
				_pick_up_weapon.rpc(get_multiplayer_authority())
			else:
				_drop_weapon.rpc(get_multiplayer_authority())
				_pick_up_weapon.rpc(get_multiplayer_authority())
		
		if event.is_action_pressed("fire") and weapon_in_hand!= null:
			weapon_in_hand.fire.rpc(get_multiplayer_authority())
			gui.update_ammo(weapon_in_hand.get_current_ammo())
		
		if event.is_action_pressed("drop_weapon") and weapon_in_hand!= null:
			_drop_weapon.rpc(get_multiplayer_authority())
		
		if event.is_action_pressed("reload") and weapon_in_hand!= null:
			weapon_in_hand.reload.rpc()
			gui.update_ammo(weapon_in_hand.get_current_ammo())
		
		if event.is_action_pressed("call_1"):
			_spawn_weapon.rpc()


func setup(player_data: Statics.PlayerData):
	player_id = player_data.id
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	
	if multiplayer.get_unique_id() == player_data.id:
		gui.show()

# func _update_ammo_counter():
	# if weapon_in_hand!= null:
		# ammo_counter.text= str(weapon_in_hand.current_clip) + "/" + str(weapon_in_hand.current_ammo)

@rpc("any_peer", "call_local", "reliable")
func _spawn_weapon():
	var spawn_point= position + Vector2(210,0).rotated(global_rotation)
	var db_shotgun= db_shotgun_scene.instantiate()
	get_tree().get_root().get_node("Main/Weapons").add_child(db_shotgun)
	db_shotgun.global_position= spawn_point

@rpc("any_peer", "call_local", "reliable")
func _pick_up_weapon(caller: int):
	Debug.log(str(caller) + " wants to pick up a weapon")
	weapon_in_hand= pickable_weapons_in_range.pop_front()
	if weapon_in_hand!= null:
		weapon_in_hand.pick_up(get_multiplayer_authority())
		weapon_in_hand.get_parent().remove_child(weapon_in_hand)
		gun_position.add_child(weapon_in_hand)
		weapon_in_hand.position= Vector2.ZERO
		weapon_in_hand.empty.connect(_weapon_empty)
		weapon_in_hand.ammo_change.connect(_update_ammo)
		gui.update_ammo(weapon_in_hand.get_current_ammo())

@rpc("any_peer", "call_local", "reliable")
func _drop_weapon(caller: int):
	Debug.log(str(caller) + " wants to drop a weapon")
	if weapon_in_hand!= null:
		weapon_in_hand.empty.disconnect(_weapon_empty)
		weapon_in_hand.ammo_change.disconnect(_update_ammo)
		gun_position.remove_child(weapon_in_hand)
		get_tree().get_root().get_node("Main/Weapons").add_child(weapon_in_hand)
		if is_multiplayer_authority():
			Debug.log(str(get_multiplayer_authority()) + " passed the multiplayer authority test, throwing")
			var throw_direction= get_global_mouse_position() - global_position
			weapon_in_hand.drop.rpc(get_multiplayer_authority(), gun_position.global_position, throw_direction.normalized())
		weapon_in_hand= null
		gui.clear_gui()

func _weapon_empty():
	if weapon_in_hand!= null: 
		weapon_in_hand.vanish.rpc()
		_drop_weapon.rpc(get_multiplayer_authority())

func _update_ammo():
	gui.update_ammo(weapon_in_hand.get_current_ammo())

func receive_dmg(dmg: int):
	health =- dmg
	if health <= 0:
		kill()
	

func kill():
	if dead:
		return
	dead = true
	# $Graphics/Alive.hide()
	# $Graphics/Dead.show()
	if multiplayer.get_unique_id() == player_id:
		game_over_screen.show()
	z_index = -1


func take_damage(damage):
	if is_multiplayer_authority():
		health -= damage


func shooter_player():
	pass	


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
	
	
