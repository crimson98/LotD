extends CharacterBody2D

var move_speed = 50
@export var health = 100
var damage = 10

var dead = false
var player_in_area = false
var player = null


func _ready():
	dead = false


func _physics_process(delta):	
	if !dead:
		$Detection_Area/CollisionShape2D.disabled = false
		if player_in_area:
			position += (player.position - position) / move_speed
		else:
			pass
	
	if dead:
		$Detection_Area/CollisionShape2D.disabled = true


func _on_detection_area_body_entered(body):
	if body.has_method("shooter_player"):
		print("ENTERED")
		player_in_area = true
		player = body


func _on_detection_area_body_exited(body):
	if body.has_method("shooter_player"):
		player_in_area = false
		player = null


@rpc
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)


		
