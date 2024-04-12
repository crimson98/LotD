extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@export var rts_player: PackedScene
@onready var players: Node2D = $Players
@onready var player_a = $SpawnMarker/PlayerA
@onready var player_b = $SpawnMarker/PlayerB


func _ready() -> void:
	
	var player = player_scene.instantiate()
	var playerrts = rts_player.instantiate()
	var player_1 = Game.players[0]
	var player_2 = Game.players[1]
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
	
	Debug.log(player_1.id)
	Debug.log(player_2.id)
	
