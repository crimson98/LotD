extends Node2D

@export var weapon_counter= 0

@rpc("any_peer", "call_local", "reliable")
func increase_weapon_counter():
	weapon_counter+= 1
