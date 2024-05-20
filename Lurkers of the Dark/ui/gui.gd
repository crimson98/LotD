extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HealthBar

func update_health(value):
	health_bar.value = value
