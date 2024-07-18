extends Area2D
signal invoked(zombie_scene)
var entered = false
var zombie_scene = preload("res://scenes/units/basic_zombie.tscn")
@export var health = 100:
	get:
		return health
	set(val):
		health = max(val, 0)
		if health <= 0:
			kill()
		update_health()

@export var dead = false

#@export var zombie_scene = PackedScene

#var zombie_in = zombie_scene.instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	mouse_entered.connect(_on_Area2D_mouse_entered)
	mouse_exited.connect(_on_Area2D_mouse_exited)
 # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
@rpc("any_peer", "call_local")
func _process(delta):
	if dead:
		self.queue_free()



@rpc("any_peer", "call_local")
func invoke(mouse_pos) -> void:
	var zombie_inst = zombie_scene.instantiate()
	zombie_inst.position = mouse_pos
	invoked.emit(zombie_inst)



func enemy():
	pass

func update_health():
	var health_bar = $HealthBar
	health_bar.value = health
	
	if health >= 99 or health <= 0:
		health_bar.visible = false
	else:
		health_bar.visible = true


func take_damage(damage):
	if is_multiplayer_authority():
		health -= damage

@rpc("any_peer", "call_local")
func get_damaged(dmg):
	health -= dmg
	if health <= 0:
		kill()

@rpc("any_peer", "call_local")
func kill():
	dead = true


func _on_Area2D_mouse_entered():
	entered = true
	return entered


func _on_Area2D_mouse_exited():
	entered = false
	return entered
