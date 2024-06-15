extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
#@export var zombie: PackedScene
@export var player_scene: PackedScene
@export var rts_player: PackedScene
@export var sagrario: PackedScene

@onready var players: Node2D = $Players
@onready var player_a = $SpawnMarker/PlayerA
@onready var player_b = $SpawnMarker/PlayerB
@onready var player_c = $SpawnMarker/PlayerC
@onready var player_d = $SpawnMarker/PlayerD
@onready var zombies = $Zombies
@onready var sagrarios = $Sagrarios
@onready var sagrary_1 = $SpawnMarker/Sagrary1
@onready var sagrary_2 = $SpawnMarker/Sagrary2
@onready var sagrary_3 = $SpawnMarker/Sagrary3
@onready var sagrary_4 = $SpawnMarker/Sagrary4
@export var counter1 = 3


func _ready() -> void:
	var playerA = player_scene.instantiate()
	var playerB = player_scene.instantiate()
	var playerC = player_scene.instantiate()
	var playerrts = rts_player.instantiate()
	var sagrary1 = sagrario.instantiate()
	var sagrary2 = sagrario.instantiate()
	var sagrary3 = sagrario.instantiate()
	var sagrary4 = sagrario.instantiate()
	var player_1 = Game.players[0]
	var player_2 = Game.players[1]
	var player_3 = Game.players[2]
	var player_4 = Game.players[3]

	
	sagrary1.global_position = sagrary_1.global_position
	sagrary2.global_position = sagrary_2.global_position
	sagrary3.global_position = sagrary_3.global_position
	sagrary4.global_position = sagrary_4.global_position
	sagrarios.add_child(sagrary1, true)
	sagrarios.add_child(sagrary2, true)
	sagrarios.add_child(sagrary3, true)
	sagrarios.add_child(sagrary4, true)
	
	#connect_players(player_1, counter1, playerA, playerB, playerC, playerrts)
	#connect_players(player_2, counter1, playerA, playerB, playerC, playerrts)
	#connect_players(player_3, counter1, playerA, playerB, playerC, playerrts)
	#connect_players(player_4, counter1, playerA, playerB, playerC, playerrts)
	
	
	
	if player_1.role == Statics.Role.ROLE_A and counter1 == 1:
		playerA.global_position = player_a.global_position
		players.add_child(playerA)
		playerA.setup(player_1)
		counter1 -= 1
			
	if player_1.role == Statics.Role.ROLE_A and counter1 == 2:
		playerB.global_position = player_b.global_position
		players.add_child(playerB)
		playerB.setup(player_1)
		counter1 -= 1
		
	if player_1.role == Statics.Role.ROLE_A and counter1 == 3:
		playerC.global_position = player_c.global_position
		players.add_child(playerC)
		playerC.setup(player_1)
		counter1 -= 1
		
	if player_1.role == Statics.Role.ROLE_B:
		playerrts.global_position = player_d.global_position
		players.add_child(playerrts)
		playerrts.setup(player_1)
			
	if player_2.role == Statics.Role.ROLE_A and counter1 == 1:
		playerA.global_position = player_a.global_position
		players.add_child(playerA)
		playerA.setup(player_2)
		counter1 -= 1
			
	if player_2.role == Statics.Role.ROLE_A and counter1 == 2:
		playerB.global_position = player_b.global_position
		players.add_child(playerB)
		playerB.setup(player_2)
		counter1 -= 1
		
	if player_2.role == Statics.Role.ROLE_A and counter1 == 3:
		playerC.global_position = player_c.global_position
		players.add_child(playerC)
		playerC.setup(player_2)
		counter1 -= 1
			
	if player_2.role == Statics.Role.ROLE_B:
		playerrts.global_position = player_d.global_position
		players.add_child(playerrts)
		playerrts.setup(player_2)
		
		
	if player_3.role == Statics.Role.ROLE_A and counter1 == 1:
		playerA.global_position = player_a.global_position
		players.add_child(playerA)
		playerA.setup(player_3)
		counter1 -= 1
			
	if player_3.role == Statics.Role.ROLE_A and counter1 == 2:
		playerB.global_position = player_b.global_position
		players.add_child(playerB)
		playerB.setup(player_3)
		counter1 -= 1
		
	if player_3.role == Statics.Role.ROLE_A and counter1 == 3:
		playerC.global_position = player_c.global_position
		players.add_child(playerC)
		playerC.setup(player_3)
		counter1 -= 1
			
	if player_3.role == Statics.Role.ROLE_B:
		playerrts.global_position = player_d.global_position
		players.add_child(playerrts)
		playerrts.setup(player_3)
		
	if player_4.role == Statics.Role.ROLE_A and counter1 == 1:
		playerA.global_position = player_a.global_position
		players.add_child(playerA)
		playerA.setup(player_4)
		counter1 -= 1
			
	if player_4.role == Statics.Role.ROLE_A and counter1 == 2:
		playerB.global_position = player_b.global_position
		players.add_child(playerB)
		playerB.setup(player_4)
		counter1 -= 1
		
	if player_4.role == Statics.Role.ROLE_A and counter1 == 3:
		playerC.global_position = player_c.global_position
		players.add_child(playerC)
		playerC.setup(player_4)
		counter1 -= 1
			
	if player_4.role == Statics.Role.ROLE_B:
		playerrts.global_position = player_d.global_position
		players.add_child(playerrts)
		playerrts.setup(player_4)
	
	sagrary1.invoked.connect(_on_sagrary_invoked)
	sagrary2.invoked.connect(_on_sagrary_invoked)
	sagrary3.invoked.connect(_on_sagrary_invoked)
	sagrary4.invoked.connect(_on_sagrary_invoked)
	Debug.log(player_1.id)
	Debug.log(player_2.id)
	Debug.log(player_3.id)
	Debug.log(player_4.id)
	

func _on_sagrary_invoked(zombie) -> void:
	zombies.add_child(zombie, true)

func connect_players(player_data, counter, player_inst0, player_inst1, player_inst2, player_inst3) -> void:
	if player_data.role == Statics.Role.ROLE_A and counter == 3:
		player_inst0.global_position = player_a.global_position
		players.add_child(player_inst0)
		player_inst0.setup(player_data)
		counter -= 1
		return
	
	if player_data.role == Statics.Role.ROLE_A and counter == 2:
		player_inst1.global_position = player_b.global_position
		players.add_child(player_inst1)
		player_inst1.setup(player_data)
		counter -= 1
		return
		
	if player_data.role == Statics.Role.ROLE_A and counter == 1:
		player_inst2.global_position = player_c.global_position
		players.add_child(player_inst2)
		player_inst2.setup(player_data)
		counter -= 1
		return
		
	if player_data.role == Statics.Role.ROLE_B:
		player_inst3.global_position = player_d.global_position
		players.add_child(player_inst3)
		player_inst3.setup(player_data)
		return
	
