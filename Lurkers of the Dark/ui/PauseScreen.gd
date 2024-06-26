extends CanvasLayer

@onready var pause_screen: Control = $PauseScreen


func _process(delta):
	testEsc()


func testEsc():
	if Input.is_action_just_pressed("esc") and pause_screen.visible:
		pause_screen.hide()
		Debug.log("esc pressed")
	if Input.is_action_just_pressed("esc") and !pause_screen.visible:
		pause_screen.show()
		Debug.log("esc pressed")


func _on_resume_pressed():
	pause_screen.hide()


func _on_quit_pressed():
	get_tree().quit()
