extends CanvasLayer

func _ready():
	load_game()

func _on_Restart_pressed() -> void:
	get_tree().change_scene("res://Main.tscn")

func _on_Quit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	$Score_Display.text = "SCORE: " + str(Singleton.score)

func _on_Quit_ready():
	$PanelContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Restart.grab_focus()

func refresh_score_board():
	pass

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.READ_WRITE)
	save_game.seek_end()

	var player_name = $VBoxContainer/Container/TextEdit.text

	var save_dict = {
		player_name : Singleton.score
	}


	var node_data = save_dict

	save_game.store_line(to_json(node_data))
	save_game.close()

func load_game():
	
	for c in $Score_Board.get_children():
		c.queue_free()
	
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		var l = Label.new()
		print(node_data)
		l.text = node_data.keys()[0] + ": " + str(node_data[node_data.keys()[0]])
		$Score_Board.add_child(l)

	save_game.close()


func _on_Button_button_down():
	save_game()
	load_game()
