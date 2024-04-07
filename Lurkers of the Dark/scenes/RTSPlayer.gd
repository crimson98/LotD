extends Node2D

@export var zombie_scene = PackedScene

var spawn_points := []
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child.has_method("spawn_mob"):
			spawn_points.append(child)

# Spawn a mob from a random spawn point
func spawn_mob():
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		var mob = zombie_scene.instance()
		spawn_point.add_child(mob)
