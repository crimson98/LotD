extends CharacterBody2D
class_name RaycastWeapon

var MAX_SPD= 1000
var SPD_DAMP= 850
var shotgun_fire_sound= preload("res://assets/080902_shotgun-39753.mp3")
var shell_reload_sound= preload("res://assets/pump-action-shotgun-101896 (mp3cut.net).mp3")
var shotgun_reload_sound= preload("res://assets/rifle-or-shotgun-reload-6787 (mp3cut.net).mp3")

@export var clip= 1   # number of bullets in the magazine
@export var ammo= 1   # number of extra bullets the player carries 
@export var burst= 1   # number of bullets fired each time the trigger is pulled
@export var p_reload= true   # if true, bullets in the mag are not discarded when reloading
@export var damage= 1   # damage one bullet does to an enemy
@export var penetration= 1   # number of times a bullet hits an enemy on its path (1 or more)
@export var cone_deg= 1   # half angle of probability for raycast opening
@export var infinite_ammo= false

@onready var fire_rate: Timer= $ROF
@onready var reload_time: Timer= $ReloadTimer
@onready var vanish_time: Timer= $VanishTimer
@onready var pick_area: Area2D= $PickArea
@onready var raycast_cluster= $RaycastsNode
@onready var sound_player= $AudioStreamPlayer2D
@onready var rng= RandomNumberGenerator.new()

@onready var move_dir= Vector2.ZERO
@onready var speed= 0
@onready var pickable = true
@export var current_clip = clip
@export var current_ammo = ammo
@export var fireable= true
@export var short_gun= false

signal empty
signal ammo_change

# when the weapons exit the Weapons node on main, the engine does not account for them
# on the creation of new weapon names, so the newly created weapons have the same name
# as the children of players ones. It then causes a name collision, and those who are dropped
# off players now have a random name. Maybe change their names based on a global counter on Weapons

func _physics_process(delta):
	if speed >0:
		velocity= move_dir * speed
		move_and_slide()
		speed-= SPD_DAMP * delta

func fire(caller: int):
	# instantiate some raycasts
	# get the colissions
	# trigger damage on colissions
	Debug.log("fire rpc caller: " + str(caller) + " fireable: " + str(fireable))
	
	if fireable and current_clip> 0:
		Debug.log("fire")
		sound_player.stream = shotgun_fire_sound
		sound_player.play()
		is_fireable.rpc(false)
		var volley= min(burst, current_clip)
		_deplete_ammo.rpc(volley)
		fire_rate.start()
		
		for pellet in raycast_cluster.get_children():
			for i in range(penetration):
				var target= pellet.get_collider()
				if target and target.has_method("enemy"):
					Debug.log(str(get_class()) + " raycasts colliding with enemy")
					target.get_damaged.rpc_id(1, damage * volley) 
					pellet.add_exception(target)
					pellet.force_raycast_update()
				else: break
		
		for _pellet in raycast_cluster.get_children():
			_pellet.rotation= deg_to_rad(rng.randf_range(-cone_deg, cone_deg))
	
	return get_current_ammo()

@rpc("any_peer", "call_local", "reliable")
func _deplete_ammo(volley: int):
	Debug.log("deplete " + str(volley) + "rpc called")
	current_clip-= volley

# you should only call rpcs for sync operations, like changing the ammo of a weapon for 
# everyone
# edit reload in player, shouldn't be an rpc

func reload(caller: int):
	Debug.log("reload")
	if fireable: 
		is_fireable.rpc(false)
		Debug.log("reload_timer_start")
		reload_time.start()

@rpc("any_peer", "call_local", "reliable")
func partial_reload():
	Debug.log("partial reload")
	var ammo_to_reload= min(clip - current_clip, current_ammo)
	
	current_clip+= ammo_to_reload
	if not infinite_ammo: current_ammo-= ammo_to_reload

@rpc("any_peer", "call_local", "reliable")
func total_reload():
	Debug.log("total reload")
	var ammo_to_reload= min(clip, current_ammo)
	
	current_clip= ammo_to_reload
	if not infinite_ammo: current_ammo-= ammo_to_reload

func get_current_ammo():
	return str(current_clip) + "/" + str(current_ammo)

@rpc("any_peer", "call_local", "reliable")
func pick_up(caller: int):
	Debug.log("pick up")
	pickable = false
	$PickArea.set_monitoring(false)
	move_dir= Vector2.ZERO
	speed= 0
	fire_rate.start()
	# $Graphics/Dropped.hide()
	# $Graphics/OnHand.show()

@rpc("any_peer", "call_local", "reliable")
func drop(caller: int, position: Vector2= global_position, direction: Vector2= Vector2.ZERO):
	Debug.log("rpc caller: " + str(caller) + " throwing in direction " + str(direction) + " from: " + str(position))
	# $Graphics/Dropped.show()
	# $Graphics/OnHand.hide()
	move_dir= direction
	speed= MAX_SPD
	global_position= position
	$PickArea.set_monitoring(true)
	pickable= true

@rpc("any_peer", "call_local", "reliable")
func vanish():
	Debug.log("vanish")
	pickable= false
	is_fireable.rpc(false)
	vanish_time.start()

@rpc("any_peer", "call_local", "reliable")
func is_fireable(value: bool):
	fireable= value

func _on_rof_timeout():
	if current_ammo + current_clip == 0:
		Debug.log("weapon empty")
		empty.emit()
		vanish_time.start()
		$PickArea.set_monitoring(false)
	else: 
		is_fireable.rpc(true)
		ammo_change.emit()
		for pellet in raycast_cluster.get_children():
			pellet.clear_exceptions()

func _on_reload_timer_timeout():
	Debug.log("reload timer timeout")
	if p_reload:
		partial_reload.rpc()
	else: 
		total_reload.rpc()
	is_fireable.rpc(true)
	ammo_change.emit()
	sound_player.stream = shotgun_reload_sound
	sound_player.play()

func _on_vanish_timer_timeout():
	_delete_self.rpc()

@rpc("any_peer", "call_local", "reliable")
func _delete_self():
	Debug.log("delete self")
	queue_free()

func _on_pick_area_body_entered(body):
	if body.has_method("shooter_player") and body.get_collision_layer()== 2:
		body.pickable_weapons_in_range.append(self)

func _on_pick_area_body_exited(body):
	if body.has_method("shooter_player") and body.get_collision_layer()== 2:
		var remove_index= body.pickable_weapons_in_range.find(self)
		if remove_index >= 0: body.pickable_weapons_in_range.pop_at(remove_index)
