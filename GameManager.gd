extends Node

onready var fg_col: StyleBoxFlat = $ProgressBar.get_stylebox("fg")
onready var bg_col: StyleBoxFlat = $ProgressBar.get_stylebox("bg")

export(Color) var good_color_fg = Color(0,1,0)
export(Color) var bad_color_fg = Color(1,0,0)
export(Color) var good_color_bg = Color(0,1,0)
export(Color) var bad_color_bg = Color(1,0,0)

var quads_alive = 0

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
	fg_col.bg_color.r = lerp(good_color_fg.r, bad_color_fg.r, (1-$ProgressBar.value/100) + 0.2)
	fg_col.bg_color.g = lerp(good_color_fg.g, bad_color_fg.g, (1-$ProgressBar.value/100) + 0.2)
	fg_col.bg_color.b = lerp(good_color_fg.b, bad_color_fg.b, (1-$ProgressBar.value/100) + 0.2)
	bg_col.bg_color.r = lerp(good_color_bg.r, bad_color_bg.r, (1-$ProgressBar.value/100) + 0.2)
	bg_col.bg_color.g = lerp(good_color_bg.g, bad_color_bg.g, (1-$ProgressBar.value/100) + 0.2)
	bg_col.bg_color.b = lerp(good_color_bg.b, bad_color_bg.b, (1-$ProgressBar.value/100) + 0.2)
	
	Singleton.enemy_difficulty += delta/100000


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
	quads_alive -= 1
	Singleton.score += 600
	if quads_alive == 0:
		$ProgressBar/ProgressTime.stop()
		$ProgressBar.visible = false
		
	
func _object_became_quad():
	quads_alive += 1
	$ProgressBar.visible = true
	print("an obj has become quad!")
	if $ProgressBar/ProgressTime.time_left == 0:
		$ProgressBar/ProgressTime.start()


func _on_ProgressTime_timeout():
	print("Game over")
	get_tree().change_scene("res://GameOverScreen.tscn")
		

	
		
	
