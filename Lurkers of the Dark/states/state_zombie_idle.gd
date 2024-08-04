extends State
class_name NZombieIdle

@export var holder: Zombie

var hang_around: Vector2
var move_direction: Vector2
var time: float

func randomize_variables():
	# Debug.log("entered randomize")
	time= randf_range(1, 3)
	
	if randf_range(0, 1)>= 0.5:
		# Debug.log("Zombie moving")
		move_direction= Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	else:
		# Debug.log("Zombie still")
		move_direction= Vector2.ZERO

func enter_state(idlepos= holder.global_position):
	# Debug.log("enter state entered")
	hang_around= idlepos
	randomize_variables()

func exit_state():
	pass

func update_process(delta):
	if time> 0:
		time-= delta
	else:
		randomize_variables()

func update_physics(_delta):
	if holder:
		if holder.global_position.distance_to(hang_around)> 50:
			move_direction.lerp((hang_around - holder.global_position).normalized(), 0.5) 
		holder.velocity= move_direction * holder.move_speed
