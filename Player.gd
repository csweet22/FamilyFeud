extends KinematicBody2D

var move_vec: Vector2 = Vector2.ZERO
var move_right_pressed: bool = false
var move_left_pressed: bool = false
var move_down_pressed: bool = false
var move_up_pressed: bool = false

var dashing = false
var can_dash = true

var input_vec: Vector2 = Vector2.ZERO
var input_smoothing_amount: float = 1

var speed = 300
var intended_speed = 300
var dir := Vector2.ZERO
var velocity: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	update()
	if Input.is_action_just_pressed("dash"):
		try_dash()
	set_input_vec()
	set_input_dir()

func _draw():
	draw_line(Vector2.ZERO, Vector2(dir.x * 100,dir.y * 100), Color(0,1,1,0.5), 3)

func try_dash():
	if can_dash:
		dash()

func dash():
	intended_speed = 2000
	dashing = true
	can_dash = false
	set_collision_mask_bit(2, false)
	$DashingTimer.start()

func set_input_vec():
	var x_input = 0
	var y_input = 0
	
	x_input = Input.get_axis("move_left", "move_right")
	y_input = Input.get_axis("move_up", "move_down")
	
	input_vec.x = lerp(input_vec.x, x_input, input_smoothing_amount)
	input_vec.y = lerp(input_vec.y, y_input, input_smoothing_amount)

func set_input_dir():
	if not dashing:
		var x_input = Input.get_axis("move_left", "move_right")
		var y_input = Input.get_axis("move_up", "move_down")
		
		if abs(x_input) > 0.0:
			dir.x = x_input
		
		if abs(y_input) > 0.0:
			dir.y = y_input
			
		dir = dir.normalized()

func _physics_process(delta):
	if dashing:
		velocity = dir.normalized() * lerp(speed, intended_speed, 0.8)
	else:
		velocity = input_vec.normalized() * input_vec.length() * lerp(speed, intended_speed, 0.7)

	move_and_slide(velocity)


func _on_DashCooldownTimer_timeout():
	can_dash = true

func _on_DashingTimer_timeout():
	intended_speed = 300
	dashing = false
	set_collision_mask_bit(2, true)
	$DashCooldownTimer.start()
