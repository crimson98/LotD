extends Camera2D
var player_to_follow = get_parent()
var follow_speed = 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_to_follow:
		var target_position = player_to_follow.global_position + offset
		global_position = global_position.lerp(target_position, follow_speed * delta)
