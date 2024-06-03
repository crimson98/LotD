extends CharacterBody2D

var MAX_SPD= 1000
var SPD_DAMP= 850
var fireable= true

@onready var clip= 2
@onready var ammo= 5
@onready var burst= 1
@onready var p_reload= true
@onready var damage= 2

@onready var cone_deg= 10
@onready var fire_rate: Timer= $ROF
@onready var reload_time: Timer= $ReloadTimer
@onready var vanish_time: Timer= $VanishTimer
@onready var pick_area: Area2D= $PickArea
@onready var raycast_cluster= $RaycastsNode
@onready var rng= RandomNumberGenerator.new()

@export var move_dir= Vector2.ZERO
@export var speed= 0
@export var pickable = true
@onready var current_clip = clip
@onready var current_ammo = ammo

signal empty

# func _process(delta):
	# if pickable:
		
		# check if player area enters this weapon's pickable area, then 
		# send this node's reference to the player's weapon_pickables array
		
		# check if player area exits this weapon's pickable area, then 
		# remove this node's reference from the player's weapon_pickables array
		# pass

func _ready():
	for _pellet in raycast_cluster.get_children():
		_pellet.rotate(deg_to_rad(rng.randf_range(-cone_deg, cone_deg)))
	
	set_collision_layer_value(16, true)
	set_collision_mask_value(0, true)

func _physics_process(delta):
	if speed >0:
		velocity= move_dir * speed
		move_and_slide()
		speed-= SPD_DAMP * delta

func partial_reload():
	Debug.log("partial reload")
	var ammo_to_reload= min(clip - current_clip, current_ammo)
	
	current_clip+= ammo_to_reload
	current_ammo-= ammo_to_reload

func total_reload():
	Debug.log("total reload")
	var ammo_to_reload= min(clip, current_ammo)
	
	current_clip= ammo_to_reload
	current_ammo-= ammo_to_reload

func fire():
	Debug.log("fire")
	# instantiate some raycasts
	# get the colissions
	# trigger damage on colissions
	
	# maybe check if fireable on _process
	
	if fireable and current_clip> 0:
		fireable= false
		current_clip-= min(burst, current_clip)
		fire_rate.start()
		
		for pellet in raycast_cluster.get_children():
			var target= pellet.get_collider()
			if target and target.has_method("enemy"):
				target.health-= damage
		
		for _pellet in raycast_cluster.get_children():
			_pellet.rotation= deg_to_rad(rng.randf_range(-cone_deg, cone_deg))
	
	return get_current_ammo()

func reload():
	Debug.log("reload")
	# maybe check if fireable on _process
	if fireable: 
		fireable= false
		Debug.log("reload_timer_start")
		reload_time.start()
	
	await reload_time.timeout
	return get_current_ammo()

func get_current_ammo():
	return str(current_clip) + "/" + str(current_ammo)

@rpc("any_peer", "call_local", "reliable")
func pick_up():
	Debug.log("pick up")
	pickable = false
	$PickArea.set_monitoring(false)
	get_parent().remove_child(self)
	move_dir= Vector2.ZERO
	speed= 0
	# $Graphics/Dropped.hide()
	# $Graphics/OnHand.show()

@rpc("any_peer", "call_local", "reliable")
func drop(position: Vector2= global_position, direction: Vector2= Vector2.ZERO):
	Debug.log("drop")
	# throw a rpc to update the state of the gun to other players
	# move gun according to direction 
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
	fireable= false
	vanish_time.start()
	await vanish_time.timeout
	queue_free()

func _on_rof_timeout():
	if current_ammo + current_clip == 0:
		Debug.log("current clip: " + str(current_clip) + "current_ammo: " + str(current_ammo))
		empty.emit()
		$PickArea.set_monitoring(false)
	else: 
		fireable= true

func _on_reload_timer_timeout():
	Debug.log("reload timer timeout")
	if p_reload:
		partial_reload()
	else: 
		total_reload()
	fireable= true

func _on_vanish_timer_timeout():
	_delete_self.rpc()

@rpc("any_peer", "call_local", "reliable")
func _delete_self():
	Debug.log("delete self")
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func _on_pick_area_body_entered(body):
	Debug.log(body.get_collision_layer())
	if body.has_method("shooter_player") and body.get_collision_layer()== 2:
		body.pickable_weapons_in_range.append(self)

@rpc("any_peer", "call_local", "reliable")
func _on_pick_area_body_exited(body):
	Debug.log(body.get_collision_layer())
	if body.has_method("shooter_player") and body.get_collision_layer()== 2:
		var remove_index= body.pickable_weapons_in_range.find(self)
		if remove_index >= 0: body.pickable_weapons_in_range.pop_at(remove_index)
