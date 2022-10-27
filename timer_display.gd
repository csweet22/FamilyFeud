extends Label


var time = 0
var timer_on = false

func _process(delta):
	if(timer_on):
		time += delta
	pass




func _on_start_signal_pressed():
	timer_on = true
	pass


func _on_stop_signal_pressed():
	timer_on = false
	pass


func _on_reset_signal_pressed():
	time = 0
	pass # Replace with function body.
