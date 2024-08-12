extends Node2D

@export var zombie_scene = PackedScene
@export var heavy_scene = PackedScene
@export var points = 1000
@export var zscene = 0
@export var cost = 10
var sagrario_scene = preload("res://scenes/units/sagrario.tscn")
@export var score = 1 :
	set(value):
		score = value
@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var camera= $RtsCamera
@export var herd_scene: PackedScene

var player_id:
	set(value):
		player_id = value

		# Debug.log("Player %s score %d" % [name, score])
# Called when the node enters the scene tree for the first time.
#func _ready():
#	for child in get_children():
#		if child.has_method("spawn_mob"):
#			spawn_points.append(child)

# Spawn a mob from a random spawn point

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc(Game.get_current_player().name)
			# spawner will spawn a bullet on every simulated
			# triggers syncronizer
			score += 1
		if event.is_action_pressed("invoke"):
			if points >= cost:
				invoke(zscene)
				points -= cost
			else:
				pass
		if event.is_action_pressed("inst_h"):
			zscene = 1
			cost = 30
		if event.is_action_pressed("inst_z"):
			zscene = 0
			cost = 10
		if event.is_action_pressed("fire"):
			move_all_zombies.rpc()

@rpc("any_peer", "call_local", "reliable")
func move_all_zombies():
	var some_herd= herd_scene.instantiate()
	var herds= get_tree().get_root().get_node("Main/Herds")
	var zombies= []
	herds.add_child(some_herd, true)
	var zombie_destination= get_global_mouse_position()
	for zombie in get_tree().get_root().get_node("Main/Zombies").get_children():
		zombie.destination= zombie_destination
		zombies.append(zombie)
	some_herd.assign_members(zombies)

func setup(player_data: Statics.PlayerData):
	player_id= player_data.id
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)


#func spawner(spawn_object):
	#if Input.is_action_pressed("mouse_click"):
		#var obj = spawn_object.instance()
		#obj.position = get_global_mouse_position()
		#add_child(obj)
		
func player():
	return Statics.Role.ROLE_B

@rpc("authority", "call_local", "reliable")
func test(some_name):
	var message = "test " + some_name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.log(message)
	Debug.log(sender_player.name)


func invoke(some_zscene) -> void:
	if not sagrario_scene:
		points += cost
		return
	var sag_inst= get_tree().get_root().get_node("Main/Sagrarios")
	for i in range(sag_inst.get_child_count()):
		var sagr = sag_inst.get_child(i)
		if sagr.entered:
			sagr.invoke.rpc(get_global_mouse_position(), zscene)

@rpc("authority", "call_local", "reliable")
func init_position(pos:Vector2):
	global_position= pos

func _on_score_time_timeout():
	points += 10
