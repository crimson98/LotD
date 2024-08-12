extends Node2D

@onready var players_node: Array
@export var player_following: Node2D= null
@export var render_distance: int= 1
@export var chunk_scene: PackedScene

var chunk_l= 352
var chunk_h= 256
var chunk_scale= 10
# chunk_l is the length (horizontal axis) of the chunk of map in pixels
# chunk_h is the heigth (vertical axis) of the chunk of map in pixels
# chunk_scale is used to apply a scale transform to each chunk when loading 

var player_on_chunk_coords: Vector2
var last_chunk_coords_player_was_in: Vector2

var active_chunks= {}
var loading_chunk_coords= []
var chunk_loaded= false

func _ready():
	pass

func _process(_delta):
	if player_following!= null:
		player_on_chunk_coords= _get_chunk_coordinates(player_following.global_position)
		# Debug.log("player in chunk: " + str(player_on_chunk_coords))
		if last_chunk_coords_player_was_in != player_on_chunk_coords:
			if !chunk_loaded:
				# Debug.log("Loading more chunks")
				_load_chunks()
		else:
			chunk_loaded = false
		last_chunk_coords_player_was_in = player_on_chunk_coords

func _get_chunk_coordinates(where: Vector2):
	return Vector2(int(where.x / (chunk_l * chunk_scale)), int(where.y / (chunk_h * chunk_scale)))

# checks for valid coordinates which inside and including the edges of the map
# default is a 10x10 chunks big map
func valid_chunk_coords(coords: Vector2):
	return coords.x >= 0 and coords.x < 10 and coords.y >= 0 and coords.y < 10 

func _load_chunks():
	for row in range(player_on_chunk_coords.x - render_distance, player_on_chunk_coords.x + render_distance + 1):
		for col in range(player_on_chunk_coords.y - render_distance, player_on_chunk_coords.y + render_distance + 1):
			var chunk_coords= Vector2(row, col)
			
			if valid_chunk_coords(chunk_coords):
				loading_chunk_coords.append(chunk_coords)
			# Debug.log("loading: " + str(loading_chunk_coords))
			# Debug.log("active: " + str(active_chunks))
			if not active_chunks.has(chunk_coords) and valid_chunk_coords(chunk_coords):
				# Debug.log("Loading chunk at position: " + str(chunk_coords))
				var chunk_instance= chunk_scene.instantiate()
				chunk_instance.set_parameters(chunk_coords, chunk_scale)
				active_chunks[chunk_coords]= chunk_instance
				add_child(chunk_instance)
	
	var delete_coords= []
	for coords in active_chunks:
		if not loading_chunk_coords.has(coords):
			delete_coords.append(coords)
	for coords in delete_coords:
		active_chunks[coords].delete()
		active_chunks.erase(coords)
	loading_chunk_coords.clear()


func _on_players_child_entered_tree(_node):
	players_node= get_tree().get_root().get_node("Main/Players").get_children()
	
	var follow_whose_id= int(multiplayer.get_unique_id())
	# Debug.log("following id" + str(follow_whose_id))
	for player in players_node:
		# Debug.log("player id: " + str(player.player_id))
		if player.player_id== follow_whose_id:
			player_following= player
			# Debug.log("Following player: " + str(player_following.player_id))
			break
	if player_following!= null: 
		_load_chunks()
