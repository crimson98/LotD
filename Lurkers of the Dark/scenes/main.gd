extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
#@export var zombie: PackedScene
@export var player_scene: PackedScene
@export var rts_player: PackedScene
@export var sagrario: PackedScene

@onready var players: Node2D = $Players
@onready var player_a = $SpawnMarker/PlayerA
@onready var player_b = $SpawnMarker/PlayerB
@onready var zombies = $Zombies
@onready var sagrarios = $Sagrarios
@onready var sagrary_1 = $SpawnMarker/Sagrary1
@onready var sagrary_2 = $SpawnMarker/Sagrary2
@onready var sagrary_3 = $SpawnMarker/Sagrary3
@onready var sagrary_4 = $SpawnMarker/Sagrary4


func _ready() -> void:
	
	var player = player_scene.instantiate()
	var playerrts = rts_player.instantiate()
	var sagrary1 = sagrario.instantiate()
	var sagrary2 = sagrario.instantiate()
	var sagrary3 = sagrario.instantiate()
	var sagrary4 = sagrario.instantiate()
	var player_1 = Game.players[0]
	var player_2 = Game.players[1]
	sagrary1.global_position = sagrary_1.global_position
	sagrary2.global_position = sagrary_2.global_position
	sagrary3.global_position = sagrary_3.global_position
	sagrary4.global_position = sagrary_4.global_position
	sagrarios.add_child(sagrary1, true)
	sagrarios.add_child(sagrary2, true)
	sagrarios.add_child(sagrary3, true)
	sagrarios.add_child(sagrary4, true)
	
	#for player_data in Game.players:
		
	#	if player_data.role == Statics.Role.ROLE_A:
	#		player.global_position = player_a.global_position
	#		
	#	if player_data.role == Statics.Role.ROLE_B:
	#		playerrts.global_position = player_b.global_position
	#		
	#	player.setup(player_data)
	
	if player_1.role == Statics.Role.ROLE_A:
		player.global_position = player_a.global_position
		players.add_child(player)
		player.setup(player_1)
			
	if player_1.role == Statics.Role.ROLE_B:
		playerrts.global_position = player_b.global_position
		players.add_child(playerrts)
		playerrts.setup(player_1)
			
	if player_2.role == Statics.Role.ROLE_A:
		player.global_position = player_a.global_position
		players.add_child(player)
		player.setup(player_2)
			
	if player_2.role == Statics.Role.ROLE_B:
		playerrts.global_position = player_b.global_position
		players.add_child(playerrts)
		playerrts.setup(player_2)
		
	
	sagrary1.invoked.connect(_on_sagrary_invoked)
	sagrary2.invoked.connect(_on_sagrary_invoked)
	sagrary3.invoked.connect(_on_sagrary_invoked)
	sagrary4.invoked.connect(_on_sagrary_invoked)
	Debug.log(player_1.id)
	Debug.log(player_2.id)
	

func _on_sagrary_invoked(zombie) -> void:
	zombies.add_child(zombie, true)
