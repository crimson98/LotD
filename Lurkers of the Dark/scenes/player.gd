extends CharacterBody2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@export var bullet_scene: PackedScene

@export var speed = 200
@export var health = 100:
	get:
		return health
	set(val):
		health = max(val, 0)
		if health <= 0:
			dead = true

var dead = false:
	get:
		return dead
	set(val):
		dead = val


@export var score = 1 :
	set(value):
		score = value
		Debug.log("Player %s score %d" % [name, score])


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = move_dir * speed
		send_data.rpc(global_position, velocity)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc(Game.get_current_player().name)
			var bullet = bullet_scene.instantiate()
			# spawner will spawn a bullet on every simulated
			multiplayer_spawner.add_child(bullet, true)
			# triggers syncronizer
			score += 1


func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	

func kill():
	if dead:
		return
	dead = true
	$Graphics/Alive.hide()
	$Graphics/Dead.show()
	z_index = -1


func take_damage(damage):
	if is_multiplayer_authority():
		health -= damage


func shooter_player():
	pass	


@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.log(message)
	Debug.log(sender_player.name)


@rpc
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	
	
