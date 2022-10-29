extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Main.tscn")
	$Select.play()

func _on_OptionButton_pressed():
	get_tree().change_scene("res://Option_Menu.tscn")
	$Select.play()


func _on_ExitButton_pressed():
	get_tree().quit()
	$Select.play()


func _on_StartButton_focus_entered():
	changed_focus()


func _on_OptionButton_focus_entered():
	changed_focus()

func changed_focus():
	$Click.play()

func _on_ExitButton_focus_entered():
	changed_focus()
