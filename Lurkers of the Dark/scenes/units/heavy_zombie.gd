extends Zombie
class_name HeavyZombie

var attacking = 0
var attack_windup 

func _ready():
	dead = false
	health = 200
	move_speed = 400
	damage = 30
	attack_cooldown = $Attack_Cooldown
	attack_windup = $Attack_Windup


func _on_hitbox_body_entered(body):
	if body.has_method("shooter_player"):
		player_in_attack_range = true
		players_being_attacked.push_back(body)
		attacking = 1
		attack_windup.start()


func _on_hitbox_body_exited(body):
	if body.has_method("shooter_player"):
		players_being_attacked.erase(body)
		if players_being_attacked.is_empty():
			player_in_attack_range = false
			attacking = 0
			attack_windup.stop()


func attack_player():
	if player_in_attack_range and attack_cooldown.is_stopped() and attacking == 1 and attack_windup.is_stopped():
		players_being_attacked[0].health -= damage
		attack_cooldown.start()
		if players_being_attacked.is_empty():
			attacking = 0
