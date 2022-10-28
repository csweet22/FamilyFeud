extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var properties = [Vector2.ZERO, Vector2.ZERO]
var object = load("res://Object.tscn")

func _get_property_list():
	var properties = []
	# Same as "export(int) var my_property"
	properties.append({
		name = "my_property",
		type = TYPE_INT
	})
	return properties
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartTimer_timeout():
	for child in $SpawnPoints.get_children():
		if child.is_in_group("SpawnPoint"):
			print("trying to make one")
			var obj = object.instance()
			obj.call_deferred("set_single")
			obj.position = child.position
			add_child(obj)
