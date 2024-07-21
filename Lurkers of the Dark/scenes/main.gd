extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
#@export var zombie: PackedScene
@export var shooter_player: PackedScene
@export var rts_player: PackedScene
@export var sagrario: PackedScene

@onready var players: Node2D = $Players
@onready var player_scenes= []

@onready var Spawns= [$SpawnMarker/Spawn1, $SpawnMarker/Spawn2, $SpawnMarker/Spawn3, $SpawnMarker/Spawn4, $SpawnMarker/Spawn5]

@onready var zombies = $Zombies
@onready var sagrarios = $Sagrarios
@onready var sagrary_1 = $SpawnMarker/Sagrary1
@onready var sagrary_2 = $SpawnMarker/Sagrary2
@onready var sagrary_3 = $SpawnMarker/Sagrary3
@onready var sagrary_4 = $SpawnMarker/Sagrary4
@export var counter1 = 3


func _ready() -> void:
	var sagrary1 = sagrario.instantiate()
	var sagrary2 = sagrario.instantiate()
	var sagrary3 = sagrario.instantiate()
	var sagrary4 = sagrario.instantiate()
	
	for player in Game.players:
		if player.role== Statics.Role.ROLE_A:
			player_scenes.append(shooter_player.instantiate())
		elif player.role== Statics.Role.ROLE_B:
			player_scenes.append(rts_player.instantiate())
	
	var shooter_player_ids= []
	
	for index in range(len(Game.players)):
		players.add_child(player_scenes[index])
		player_scenes[index].setup(Game.players[index])
		if Game.players[index].role== Statics.Role.ROLE_A:
			shooter_player_ids.append(Game.players[index].id)
	
	shooter_player_ids.sort()
	for player_node in players.get_children():
		if player_node.player()== Statics.Role.ROLE_A:
			var spawnpos_index= shooter_player_ids.find(player_node.get_multiplayer_authority()) 
			player_node.global_position= Spawns[spawnpos_index].global_position
		else: 
			player_node.global_position= Spawns[4].global_position
	
	sagrary1.global_position = sagrary_1.global_position
	sagrary2.global_position = sagrary_2.global_position
	sagrary3.global_position = sagrary_3.global_position
	sagrary4.global_position = sagrary_4.global_position
	sagrarios.add_child(sagrary1, true)
	sagrarios.add_child(sagrary2, true)
	sagrarios.add_child(sagrary3, true)
	sagrarios.add_child(sagrary4, true)
	
	sagrary1.invoked.connect(_on_sagrary_invoked)
	sagrary2.invoked.connect(_on_sagrary_invoked)
	sagrary3.invoked.connect(_on_sagrary_invoked)
	sagrary4.invoked.connect(_on_sagrary_invoked)

func _on_sagrary_invoked(zombie) -> void:
	zombies.add_child(zombie, true)
