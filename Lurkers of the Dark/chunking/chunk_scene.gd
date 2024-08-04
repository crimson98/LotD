extends Node2D

@onready var ground_texture: Sprite2D= $Ground
@onready var chunk_coords: Vector2
@onready var chunk_scale: int

func _ready():
	_load_texture()

func set_parameters(some_coords: Vector2, some_scale: int):
	chunk_coords= some_coords
	chunk_scale= some_scale

func _load_texture():
	var path_to_string= "res://mapsectioned/" + str(chunk_coords.y) + "-" \
	 + str(chunk_coords.x) + ".png"
	# Debug.log("loading from: " + path_to_string)
	var image= load(path_to_string)
	if image!= null:
		ground_texture.centered= false
		ground_texture.texture= image
		ground_texture.position= Vector2(chunk_coords.x * 352 * chunk_scale, (chunk_coords.y * 256 * chunk_scale))
		ground_texture.scale= Vector2(chunk_scale, chunk_scale)
		ground_texture.show_behind_parent= true
		ground_texture.texture_filter= CanvasItem.TEXTURE_FILTER_NEAREST
		# for pixel_art backgrounds

func delete():
	queue_free()
