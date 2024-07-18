extends Node2D

@export var zombie_scene = PackedScene
var sagrario_scene = preload("res://scenes/sagrario.tscn")
@export var score = 1 :
	set(value):
		score = value
@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer


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
			invoke()




func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)


func spawner(spawn_object):
	if Input.is_action_pressed("mouse_click"):
		var obj = spawn_object.instance()
		obj.position = get_global_mouse_position()
		add_child(obj)
		
func player():
	pass

@rpc("authority", "call_local", "reliable")
func test(some_name):
	var message = "test " + some_name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.log(message)
	Debug.log(sender_player.name)


func invoke() -> void:
	if not sagrario_scene:
		return
	# var sag_inst = get_parent().get_parent().get_child(5)
	var sag_inst= get_tree().get_root().get_node("Main/Sagrarios")
	for i in range(sag_inst.get_child_count()):
		var sagr = sag_inst.get_child(i)
		if sagr.entered:
			sagr.invoke.rpc(get_global_mouse_position())
