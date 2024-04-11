extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 100
@export var dmg = 10
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")

var dead = false

func _physics_process(delta):
	if dead:
		return
	
	var dir_to_player = global_position.direction_to(player.global_position)
	velocity = dir_to_player * move_speed
	move_and_slide()
	
	global_rotation = dir_to_player.angle() + PI/2.0
	
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		player.receive_damage(dmg)

func kill():
	if dead:
		return
	
	dead = true
	$Graphics/Alive.hide()
	$Graphics/Alive.show()
	$CollisionShape2D.disabled = true
	z_index = -1
	
func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)

@rpc
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
