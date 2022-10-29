extends CanvasLayer

func _ready():
	load_game()
	Singleton.singleton_audio.stop()
	$VBoxContainer/Container/TextEdit.grab_focus()
	Engine.set_time_scale(1)


func _on_Restart_pressed() -> void:
	get_tree().change_scene("res://Main.tscn")
	Singleton.score = 0

func _on_Quit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene("res://Main_Menu.tscn")
	$HBoxContainer/Score_Display.text = "SCORE: " + str(Singleton.score)

func _on_Quit_ready():
	pass
#	$PanelContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Restart.grab_focus()

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
		l.text = node_data.keys()[0] + ": " + str(node_data[node_data.keys()[0]])
		$Score_Board.add_child(l)


	save_game.close()
	
	var children =$Score_Board.get_children()
#	for i in range (0, len(children)-1):
#		for j in range (0, len(children)-1):
#			var child1 = children[j]
#			var child2 = children[j+1]
#			var score1 = int(child1.text.split(": ")[1])
#			var score2 = int(child2.text.split(": ")[1])
#			if score2 > score1:
#				$Score_Board.move_child(child2, 0)
				

	
	for i in range (0, len(children)-1):
		for j in range (0, len(children)-1):
			var child1 = children[j]
			var child2 = children[j+1]
			var score1 = int(child1.text.split(": ")[1])
			var score2 = int(child2.text.split(": ")[1])
			if score1 > score2:
				print(child1.text + " is bigger than " + child2.text )
				var temp_index = child1.get_index()
				$Score_Board.move_child(child1, child2.get_index())
				$Score_Board.move_child(child2, temp_index)
				


func _on_Button_button_down():
	save_game()
	load_game()
