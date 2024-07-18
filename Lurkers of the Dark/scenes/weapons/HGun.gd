extends RaycastWeapon
class_name HGun

func _ready():
	clip= 12
	ammo= 100
	burst= 1
	damage= 20
	penetration= 1
	cone_deg= 1
	current_clip = clip
	current_ammo = ammo
	p_reload= false
	short_gun= true
	infinite_ammo= true
	$PickArea.set_monitoring(false)

	for _pellet in raycast_cluster.get_children():
		_pellet.rotation= deg_to_rad(rng.randf_range(-cone_deg, cone_deg))

func get_current_ammo():
	return str(current_clip) + "/-"
