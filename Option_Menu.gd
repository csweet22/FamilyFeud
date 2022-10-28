extends Control

func _ready():
	$VBoxContainer/Back.grab_focus()


func _on_Back_pressed():
	get_tree().change_scene("res://Main_Menu.tscn")
