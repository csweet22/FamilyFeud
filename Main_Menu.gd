extends Control

func _ready():
	pass # Replace with function body.

func _on_StartButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_OptionButton_pressed():
	get_tree().change_scene("res://Option_Menu.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()
