extends Node2D

@export var zombie_scene = PackedScene
@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
var spawn_points := []

@export var score = 1 :
	set(value):
		score = value
		Debug.log("Player %s score %d" % [name, score])
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



func spawn_mob():
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		var mob = zombie_scene.instance()
		spawn_point.add_child(mob)


func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)


func spawner(spawn_object):
	if Input.is_action_just_pressed("mouse_click"):
		var obj = spawn_object.instance()
		obj.position = get_global_mouse_position()
		add_child(obj)

@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.log(message)
	Debug.log(sender_player.name)
