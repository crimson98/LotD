extends Area2D
signal invoked(zombie_scene)
var entered = false
var zombie_scene = preload("res://scenes/units/basic_zombie.tscn")
#@export var zombie_scene = PackedScene

#var zombie_in = zombie_scene.instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	mouse_entered.connect(_on_Area2D_mouse_entered)
	mouse_exited.connect(_on_Area2D_mouse_exited)
 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



@rpc("any_peer", "call_local")
func invoke(mouse_pos) -> void:
	var zombie_inst = zombie_scene.instantiate()
	zombie_inst.position = mouse_pos
	invoked.emit(zombie_inst)


func _on_Area2D_mouse_entered():
	entered = true
	return entered


func _on_Area2D_mouse_exited():
	entered = false
	return entered
