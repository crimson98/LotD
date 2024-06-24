extends CanvasLayer

func _on_quit_pressed():
	Debug.log("button_pressed")
	get_tree().quit()
