extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var object = load("res://Object.tscn")

func _ready():
	if not Singleton.is_playing:
		Singleton.singleton_audio.play()

func _process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().change_scene("res://Main_Menu.tscn")
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused


func _on_StartTimer_timeout():
	
	$AudioStreamPlayer.play()
	
	for child in $SpawnPoints.get_children():
		if child.is_in_group("SpawnPoint"):
			var obj = object.instance()
			obj.set_random_sprite()
			obj.call_deferred("set_single")
			obj.position = child.position
			obj.spawnVFX()
			add_child(obj)
