extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@export var rts_player: PackedScene
@onready var players: Node2D = $Players
@onready var player_a = $SpawnMarker/PlayerA
@onready var player_b = $SpawnMarker/PlayerB


func _ready() -> void:
	for player_data in Game.players:
		var player = player_scene.instantiate()
		if player_data.role == Statics.Role.ROLE_A:
			player.global_position = player_a.global_position
		if player_data.role == Statics.Role.ROLE_B:
			player.global_position = player_b.global_position
		players.add_child(player)
		player.setup(player_data)
		
