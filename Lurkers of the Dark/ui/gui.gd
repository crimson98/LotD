extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthMargin/HealthBar
@onready var ammo_counter: Label = $AmmoCounter
@onready var point_counter: Label = $PointCounter

func update_health(value):
	health_bar.value = value

func update_ammo(ammo_string: String):
	ammo_counter.text= ammo_string

func clear_gui():
	ammo_counter.text= ""

func update_points(value: int):
	point_counter.text= str(value)
