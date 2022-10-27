extends Node


var ms = 1
var score = 0
func _on_counter_timeout():
	score += ms
	score = ms
	pass

func increase_points_per_second():
	ms += 1

func _process(delta):
	#if break apart signal received-> check if 2 break apart or 4 
	$Score.set_text("SCORE:" + str(score))
	
	# Have a way to detect every time objects collide 

func example():
	$Score/counter.wait_time = 1

func _on_KinematicBody2D_double_was_broken():
	print("double broken")
	score += 100

func _quad_was_broken():
	print("quad broken!")
	
func _object_became_quad():
	print("an obj has become quad!")
