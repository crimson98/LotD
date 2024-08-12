extends State
class_name NZIdle

@export var holder: Zombie

var hang_around: Vector2
var time: float

func randomize_variables():
	# Debug.log("entered randomize")
	time= randf_range(1, 3)
	
	if randf_range(0, 1)>= 0.5:
		# Debug.log("Zombie moving")
		holder.move_direction= Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	else:
		# Debug.log("Zombie still")
		holder.move_direction= Vector2.ZERO

@rpc("any_peer", "call_local", "reliable")
func enter_state(idlepos= holder.global_position):
	holder.destination= null
	hang_around= idlepos
	randomize_variables()

@rpc("any_peer", "call_local", "reliable")
func exit_state():
	pass

func update_process(delta):
	if time> 0:
		time-= delta
	else:
		randomize_variables()
	if holder.destination and multiplayer.get_unique_id()== 1:
		transition.emit(self, "nzmovement")

func update_physics(_delta):
	if holder:
		if holder.global_position.distance_to(hang_around)> 50:
			holder.move_direction.lerp((hang_around - holder.global_position).normalized(), 0.5) 
		holder.velocity= holder.move_direction * holder.move_speed
