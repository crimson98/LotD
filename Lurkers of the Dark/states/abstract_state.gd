extends Node
class_name State

signal transition

@rpc("any_peer", "call_local", "reliable")
func enter_state():
	pass

@rpc("any_peer", "call_local", "reliable")
func exit_state():
	pass

func update_process(_delta: float):
	pass

func update_physics(_delta: float):
	pass
