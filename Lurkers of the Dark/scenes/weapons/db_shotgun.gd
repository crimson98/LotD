extends RaycastWeapon
class_name DBShotgun

func _ready():
	# clip= 2
	# ammo= 10
	# burst= 1
	# p_reload= true
	# damage= 37
	# penetration= 2
	# cone_deg= 13
	
	for _pellet in raycast_cluster.get_children():
		_pellet.rotation= deg_to_rad(rng.randf_range(-cone_deg, cone_deg))
