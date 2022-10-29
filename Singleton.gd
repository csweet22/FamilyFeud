extends Node

var obj_id = 0

var score = 0

var enemy_difficulty = 1


onready var singleton_audio = get_node("AudioStreamPlayer")
var is_playing

func _process(delta):
	is_playing = $AudioStreamPlayer.playing
