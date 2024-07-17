extends RaycastWeapon
class_name BARifle

func _ready():
	clip= 7
	ammo= 20
	burst= 1
	damage= 55
	penetration= 5
	cone_deg= 2
	current_clip = clip
	current_ammo = ammo

	for _pellet in raycast_cluster.get_children():
		_pellet.rotation= deg_to_rad(rng.randf_range(-cone_deg, cone_deg))
