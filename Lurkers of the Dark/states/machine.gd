extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary= {}

func _ready():
	# if multiplayer.get_unique_id()== 1:
		# queue_free()
	
	for child in get_children():
		if child is State:
			# Debug.log(str(child.name.to_lower()) + "added to state machine")
			states[child.name.to_lower()]= child
			child.transition.connect(_call_child_transition)
	
	if initial_state:
		# Debug.log("entering initial state")
		initial_state.enter_state()
		current_state= initial_state

func _process(delta):
	if current_state:
		current_state.update_process(delta)

func _physics_process(delta):
	if current_state:
		current_state.update_physics(delta)

func _call_child_transition(state, new_state_name):
	_on_child_transition.rpc(state, new_state_name)

@rpc("any_peer", "call_local", "reliable")
func _on_child_transition(state, new_state_name):
	Debug.log("Changing from state: " + str(current_state.name) + " to: " + new_state_name)
	if state!= current_state:
		return
	
	var new_state= states.get(new_state_name.to_lower())
	if !new_state: 
		return
	
	if current_state:
		current_state.exit_state()
	
	new_state.enter_state()
	current_state= new_state
