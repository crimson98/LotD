extends CharacterBody2D

var MAX_SPD= 1000
var SPD_DAMP= 850

var p_reload= true
var clip = 2
var ammo= 6
var fireable= true
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
@export var burst= 1
@export var current_clip = clip
@export var current_ammo = ammo

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

func _physics_process(delta):
	if speed >0:
		velocity= move_dir * speed
		move_and_slide()
		speed-= SPD_DAMP * delta

func partial_reload():
	var ammo_to_reload= min(clip - current_clip, current_ammo)
	
	current_clip+= ammo_to_reload
	current_ammo-= ammo_to_reload

func total_reload():
	var ammo_to_reload= min(clip, current_ammo)
	
	current_clip= ammo_to_reload
	current_ammo-= ammo_to_reload

func fire():
	# instantiate some raycasts
	# get the colissions
	# trigger damage on colissions
	
	# maybe check if fireable on _process
	
	if fireable:
		current_clip-= min(burst, current_clip)
		fireable= false
		fire_rate.start()
		
		for _pellet in raycast_cluster.get_children():
			_pellet.rotation= deg_to_rad(rng.randf_range(-cone_deg, cone_deg))

func reload():
	# maybe check if fireable on _process
	
	if fireable: 
		fireable= false
		reload_time.start()

@rpc("any_peer", "call_local", "reliable")
func pick_up():
	pickable = false
	$PickArea.set_monitoring(false)
	get_parent().remove_child(self)
	move_dir= Vector2.ZERO
	speed= 0
	# $Graphics/Dropped.hide()
	# $Graphics/OnHand.show()

@rpc("any_peer", "call_local", "reliable")
func drop(position: Vector2= global_position, direction: Vector2= Vector2.ZERO):
	# throw a rpc to update the state of the gun to other players
	# move gun according to direction 
	# $Graphics/Dropped.show()
	# $Graphics/OnHand.hide()
	move_dir= direction
	speed= MAX_SPD
	global_position= position
	$PickArea.set_monitoring(true)
	pickable= true

func vanish():
	vanish_time.start()

func _on_rof_timeout():
	if current_ammo == 0 and current_clip == 0:
		pickable= false
		fireable= false
		drop()
		vanish()
	else: 
		fireable= true

func _on_reload_timer_timeout():
	if p_reload:
		partial_reload()
	else: 
		total_reload()
	fireable= true

func _on_vanish_timer_timeout():
	if is_instance_valid(self):
		queue_free()

@rpc("any_peer", "call_local", "reliable")
func _on_pick_area_body_entered(body):
	Debug.log(body.get_collision_layer())
	if body.get_collision_layer()== 2:
		body.pickable_weapons_in_range.append(self)

@rpc("any_peer", "call_local", "reliable")
func _on_pick_area_body_exited(body):
	Debug.log(body.get_collision_layer())
	if body.get_collision_layer()== 2:
		var remove_index= body.pickable_weapons_in_range.find(self)
		if remove_index >= 0: body.pickable_weapons_in_range.pop_at(remove_index)
