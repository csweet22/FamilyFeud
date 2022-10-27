extends RichTextLabel

var ms = 0
var score = 0
func _on_counter_timeout():
	ms+=1
	score = ms
	pass

func _process(delta):
	#if break apart signal received-> check if 2 break apart or 4 
	set_text("SCORE:" + str(score))
	
	# Have a way to detect every time objects collide 
