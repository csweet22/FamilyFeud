extends Node


var s = 0
var prog_time = 0
func _on_counter_timeout():
	#score += ms
	s+=1
	Singleton.score+=1
	pass

func _process(delta):
	$Score.set_text("SCORE:" + str(Singleton.score))
	score_multipliers()
	$ProgressBar.value = ($ProgressBar/ProgressTime.time_left / $ProgressBar/ProgressTime.wait_time)*100
		

func score_multipliers():
	if s >= 0 and s <180:
		$Score/counter.wait_time = 1
	if s > 180:
		$Score/counter.wait_time = 0.75   #Can add more and vary values after seeing gameplay
	elif s > 300:
		$Score/counter.wait_time = 0.5
	
	
func _on_KinematicBody2D_double_was_broken():
	print("double broken")
	Singleton.score += 100

func _quad_was_broken():
	print("quad broken!")
	Singleton.score += 600
	$ProgressBar/ProgressTime.stop()
	
func _object_became_quad():
	print("an obj has become quad!")
	$ProgressBar/ProgressTime.start()


func _on_ProgressTime_timeout():
	print("Game over")
	get_tree().change_scene("res://GameOverScreen.tscn")
		

	
		
	
