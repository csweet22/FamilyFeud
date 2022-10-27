extends Node


var s = 0
var score = 0
var prog_time = 0
func _on_counter_timeout():
	#score += ms
	s+=1
	score+=1
	pass

func _process(delta):
	$Score.set_text("SCORE:" + str(score))
	score_multipliers()
		

func score_multipliers():
	if s >= 0 and s <180:
		$Score/counter.wait_time = 1
	if s > 180:
		$Score/counter.wait_time = 0.75   #Can add more and vary values after seeing gameplay
	elif s > 300:
		$Score/counter.wait_time = 0.5
	
	
func _on_KinematicBody2D_double_was_broken():
	print("double broken")
	score += 100

func _quad_was_broken():
	print("quad broken!")
	score += 600
	
func _object_became_quad():
	print("an obj has become quad!")
	_on_ProgressTime_timeout()


func _on_ProgressTime_timeout():
	while $ProgressBar.value <100:
		$ProgressBar.value += 1
		

	
		
	
