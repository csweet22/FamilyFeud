extends CanvasLayer


func _on_Restart_pressed() -> void:
	get_tree().change_scene("res://Main.tscn")

func _on_Quit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	$Score_Display.text = "SCORE: " + str(Singleton.score)

func _on_Quit_ready():
	$PanelContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Restart.grab_focus()
