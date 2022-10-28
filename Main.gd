extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var object = load("res://Object.tscn")


func _process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().change_scene("res://Main_Menu.tscn")


func _on_StartTimer_timeout():
	
	for child in $SpawnPoints.get_children():
		if child.is_in_group("SpawnPoint"):
			var obj = object.instance()
			obj.set_random_sprite()
			obj.call_deferred("set_single")
			obj.position = child.position
			obj.spawnVFX()
			add_child(obj)
