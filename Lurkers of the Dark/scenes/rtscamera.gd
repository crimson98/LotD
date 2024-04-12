extends Camera2D
# Speed of camera movement
var speed = 1000.0

func _process(delta):
	# Get the mouse position
	var mouse_pos = get_viewport().get_mouse_position()

	# Get the size of the viewport
	var screen_size = get_viewport_rect().size
	print(screen_size)
	print(self.global_position)
	# Set a margin for mouse movement
	var margin = 50

	# Check if the mouse is near the edges of the screen
	if mouse_pos.x < margin:
		# Move camera left
		translate(Vector2(-speed * delta * 100000, 0))
	
	elif mouse_pos.x > screen_size.x - margin:
		# Move camera right
		translate(Vector2(speed * delta *100000, 0))

	if mouse_pos.y < margin:
		# Move camera up
		translate(Vector2(0, -speed * delta))
	
	elif mouse_pos.y > screen_size.y - margin:
		# Move camera down
		translate(Vector2(0, speed * delta))

	# Optionally clamp camera position to prevent it from moving too far from the game world
	#clamp_position()

func clamp_position():
	# Define boundaries of the game world
	var min_position = Vector2(0, 0) # Minimum position
	var max_position = Vector2(1000, 1000) # Maximum position

	# Clamp camera position within boundaries
	position.x = clamp(position.x, min_position.x, max_position.x)
	position.y = clamp(position.y, min_position.y, max_position.y)
