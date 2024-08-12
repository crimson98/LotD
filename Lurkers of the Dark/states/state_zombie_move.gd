extends State
class_name NZMovement

@export var holder: Zombie

var next_milestone: Vector2
var final_milestone: Vector2
var ponderator: Vector2
var cohesion_contribution= 0.1
var allignment_contribution= 0.1
var separation_contribution= 0.1

func _set_destination():
	if holder.nav: holder.nav.target_position= holder.destination

func _next_step():
	if holder.nav: 
		next_milestone= holder.nav.get_next_path_position() - holder.global_position
		next_milestone= next_milestone.normalized()

func _final_step():
	if holder.nav:
		final_milestone= holder.nav.get_final_position()

@rpc("any_peer", "call_local", "reliable")
func enter_state():
	_set_destination()
	_final_step()
	_next_step()

@rpc("any_peer", "call_local", "reliable")
func exit_state():
	pass

func update_process(_delta: float):
	pass

func update_physics(_delta: float):
	if holder.global_position.distance_to(final_milestone) < 50:
		transition.emit(self, "nzidle")
		if multiplayer.get_unique_id()== 1: holder.erase_from_herd()
	_next_step()
	holder.move_direction= holder.move_direction.lerp(next_milestone, 0.1).normalized() 
	holder.velocity= holder.move_direction * holder.move_speed
