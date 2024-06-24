extends CanvasLayer

@onready var pause_screen: Control = $PauseScreen


func esc():
	Debug.log("esc pressed")
	if Input.is_action_just_pressed("esc") and pause_screen.visible:
		pause_screen.hide()
		
	if Input.is_action_just_pressed("esc") and !pause_screen.visible:
		pause_screen.show()


func _on_resume_pressed():
	pause_screen.hide()


func _on_quit_pressed():
	get_tree().quit()
