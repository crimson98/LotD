extends Zombie
class_name BasicZombie


func _ready():
	dead = false
	health = 100
	move_speed = 300
	damage = 10
	attack_cooldown = $Attack_Cooldown


func _on_players_child_entered_tree(node):
	player_in_area= true
	players.push_back(node)
