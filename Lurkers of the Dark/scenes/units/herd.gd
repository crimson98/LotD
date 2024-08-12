extends Node2D
class_name Herd

var members: Array
var n_members: int

var cohesion: Vector2= Vector2.ZERO
var allignment: Vector2= Vector2.ZERO

var destination: Vector2

func _ready():
	members= []
	n_members= 0

@rpc("any_peer", "call_local", "reliable")
func assign_members(some_members: Array):
	members.append_array(some_members)
	n_members= len(members)
	for unit in members:
		if not destination: 
			destination= unit.destination
		Debug.log("Assigned " + str(unit) + "to herd")
		unit.set_herd(self)

@rpc("any_peer", "call_local", "reliable")
func leave_herd(unit: CharacterBody2D):
	# sDebug.log("called leave herd on: " + str(unit))
	members.erase(unit)
	unit.herd= null

@rpc("any_peer", "call_local", "unreliable")
func _cohesion_allignment():
	var gravcenter= Vector2.ZERO
	var meandirection= Vector2.ZERO
	for member in members: if is_instance_valid(member):
		gravcenter+= member.global_position
		meandirection+= member.move_direction
	cohesion= gravcenter / n_members
	cohesion= cohesion.normalized()
	allignment= meandirection / n_members
	allignment= allignment.normalized()

func _process(_delta):
	_cohesion_allignment()
	if len(members) and global_position.distance_to(destination) <= 500:
		end_herd.rpc()
	if not len(members):
		end_herd.rpc()

@rpc("any_peer", "call_local", "reliable")
func end_herd():
	for member in members: if is_instance_valid(member):
		member.herd= null
	queue_free()


# Work to be done: 
# implement separation of zombies, that should be done in zombie scene

# implement states: idle v, moving wip, chasing, searching
# chasing is the same as moving, but the target is not given by RTSplayer

# implement changes between states:
# idle -> moving *, idle -> chasing
# moving -> idle
# chasing -> searching, chasing -> moving *

# moving should take precedent over chasing.

# RTS shouldn't be able to click on player, the zombies should do the discovering, 
# chasing and attacking player alone

# zombies should move towards the milestone set by RTSplayer, with slight influences
# from herd and nearby zombies

# something like:
# - the closer a zombie is from the horde, the more effect it has on its alignment
# - on long ranges, reaching the ccenter of gravity is what matters the most
