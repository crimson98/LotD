extends CharacterBody2D

signal health_changed(value)

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var gui: CanvasLayer = $GUI
@onready var game_over_screen: Control = $GameOverScreen/GameOverScreen
@onready var point_timer= $PointTimer

@onready var short_weapon_stance: Sprite2D= $Graphics/ShortWeapon
@onready var short_gun_position= $SGunPos
@onready var long_weapon_stance: Sprite2D= $Graphics/LongWeapon
@onready var long_gun_position= $LGunPos

@onready var handgun= $HGun

@export var db_shotgun_scene: PackedScene
@export var ba_rifle_scene: PackedScene

@export var points= 0
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
	long_weapon_stance.hide()
	short_weapon_stance.show()
	handgun.empty.connect(_weapon_empty)
	handgun.ammo_change.connect(_update_ammo)
	gui.update_ammo(handgun.get_current_ammo())
	gui.update_points(points)
	point_timer.start()

# add a new variable "sidearm", which will contain a pistol
# if not weapon in hand, call sidearm methods
# make GunPos a child of the graphic, so whatever weapon you equip,
# you always have to call the same thing
# sidearm should have infinite ammo and not partial reload


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
		if event.is_action_pressed("drop_weapon") and weapon_in_hand!= null and weapon_in_hand.fireable :
			_drop_weapon.rpc(get_multiplayer_authority())
		
		if event.is_action_pressed("interact") and weapon_in_hand== null and len(pickable_weapons_in_range)> 0:
			_pick_up_weapon.rpc(get_multiplayer_authority())
		
		if event.is_action_pressed("fire"):
			if weapon_in_hand!= null:
				weapon_in_hand.fire(get_multiplayer_authority())
			else: 
				handgun.fire(get_multiplayer_authority())
		
		if event.is_action_pressed("reload"):
			if weapon_in_hand!= null:
				weapon_in_hand.reload(get_multiplayer_authority())
			else:
				handgun.reload(get_multiplayer_authority())
		
		if event.is_action_pressed("call_1"):
			if points>= 55:
				_spawn_weapon.rpc(1)
				points-= 55
				gui.update_points(points)
		
		elif event.is_action_pressed("call_2"):
			if points>= 35:
				_spawn_weapon.rpc(2)
				points-= 35
				gui.update_points(points)


func setup(player_data: Statics.PlayerData):
	player_id = player_data.id
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	
	if multiplayer.get_unique_id() == player_data.id:
		gui.show()


# Could change the instantiate and name sections to a separate script
@rpc("any_peer", "call_local", "reliable")
func _spawn_weapon(wtype: int):
	var spawn_point= position + Vector2(210,0).rotated(global_rotation)
	var weapon: RaycastWeapon= null
	if wtype== 1:
		weapon= db_shotgun_scene.instantiate()
	elif wtype== 2:
		weapon= ba_rifle_scene.instantiate()
	var weapons_node= get_tree().get_root().get_node("Main/Weapons")
	weapons_node.add_child(weapon, true)
	if wtype== 1:
		weapon.name= "Weapon_DBShotgun" + str(weapons_node.weapon_counter)
	elif wtype== 2:
		weapon.name= "Weapon_BARifle" + str(weapons_node.weapon_counter)
	weapon.global_position= spawn_point
	if is_multiplayer_authority():
		weapons_node.increase_weapon_counter.rpc()

@rpc("any_peer", "call_local", "reliable")
func _pick_up_weapon(caller: int):
	weapon_in_hand= pickable_weapons_in_range.pop_front()
	if weapon_in_hand!= null:
		# Debug.log(str(caller) + " passed weapon_in_hand_check")
		if is_multiplayer_authority():
			Debug.log(str(caller) + " passed pick_up multiplayer_authority_check")
			weapon_in_hand.rpc('pick_up', get_multiplayer_authority())
		weapon_in_hand.get_parent().remove_child(weapon_in_hand)
		if weapon_in_hand.short_gun:
			short_gun_position.add_child(weapon_in_hand)
			long_weapon_stance.hide()
			short_weapon_stance.show()
		else:
			long_gun_position.add_child(weapon_in_hand)
			short_weapon_stance.hide()
			long_weapon_stance.show()
		handgun.empty.disconnect(_weapon_empty)
		handgun.ammo_change.disconnect(_update_ammo)
		handgun.hide()
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
		if weapon_in_hand.short_gun: 
			short_gun_position.remove_child(weapon_in_hand)
		else:
			long_gun_position.remove_child(weapon_in_hand)
		long_weapon_stance.hide()
		short_weapon_stance.show()
		get_tree().get_root().get_node("Main/Weapons").add_child(weapon_in_hand)
		if is_multiplayer_authority():
			Debug.log(str(get_multiplayer_authority()) + " passed the multiplayer authority test, throwing")
			var throw_direction= get_global_mouse_position() - global_position
			if weapon_in_hand.short_gun: 
				weapon_in_hand.rpc('drop', get_multiplayer_authority(), short_gun_position.global_position, throw_direction.normalized())
			else:
				weapon_in_hand.rpc('drop', get_multiplayer_authority(), long_gun_position.global_position, throw_direction.normalized())
		weapon_in_hand= null
		handgun.show()
		handgun.empty.connect(_weapon_empty)
		handgun.ammo_change.connect(_update_ammo)
		gui.update_ammo(handgun.get_current_ammo())

func _weapon_empty():
	if weapon_in_hand!= null and is_multiplayer_authority(): 
		weapon_in_hand.vanish.rpc()
		_drop_weapon.rpc(get_multiplayer_authority())

func _update_ammo():
	if weapon_in_hand!= null:
		gui.update_ammo(weapon_in_hand.get_current_ammo())
	else:
		gui.update_ammo(handgun.get_current_ammo())

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

func player():
	return Statics.Role.ROLE_A

@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)

@rpc("authority", "call_local", "reliable")
func init_position(pos:Vector2):
	global_position= pos

@rpc
func send_data(pos: Vector2, vel: Vector2, look: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	look_direction= lerp(look_direction, look, 0.75)


func _on_point_timer_timeout():
	points+= 5
	gui.update_points(points)
