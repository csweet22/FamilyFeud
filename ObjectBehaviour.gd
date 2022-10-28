extends KinematicBody2D

var object = load("res://Object.tscn")
var pointUI = load("res://PointsUpUI.tscn")
var splitVFX = load("res://SplitVFX.tscn")

onready var timer := $DivideTimer

var dir = get_random_vector()
var speed = 100
var velocity = speed * dir

var flag = 1
var id = 0

var is_single = false
var is_doublev = false
var is_doubleh = false
var is_quad = false

var can_combine = false

signal object_became_quad
signal quad_was_broken
signal double_was_broken

func _ready():
	id = Singleton.obj_id
	Singleton.obj_id += 1
	all_off()
	
	var children = get_parent().get_children()
	
	var gm
	for child in children:
		if child.is_in_group("GameManager"):
			gm = child
	
	self.connect("double_was_broken", gm, "_on_KinematicBody2D_double_was_broken")
	self.connect("quad_was_broken", gm, "_quad_was_broken")
	self.connect("object_became_quad", gm, "_object_became_quad")

func _process(delta):
	if Input.is_key_pressed(KEY_1):
		set_single()
	if Input.is_key_pressed(KEY_2):
		set_double_h()
	if Input.is_key_pressed(KEY_3):
		set_double_v()
	if Input.is_key_pressed(KEY_4):
		set_quad()

func _physics_process(delta):
	velocity = velocity * Singleton.enemy_difficulty
	if velocity.length() > 300:
		velocity = velocity.normalized() * 300
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	
	if collision:
		if (collision.collider.get_collision_layer() == 2):
			velocity = velocity.bounce(collision.normal)
		else:
			if can_combine and can_combine(self, collision.collider):
				combine(collision.collider, collision)
			else:
				velocity = velocity.bounce(collision.normal)

func can_combine(obj1, obj2):
	if not obj2.is_in_group("Player"):
		if obj1.flag == obj2.flag and obj1.flag != 4:
			return true
		else:
			return false
	else:
		return false

func combine(obj2, collision: KinematicCollision2D):
	if (id > obj2.id):
		if flag == 1:
			if abs((collision.position - position).x) > abs((collision.position - position).y):
				call_deferred("set_double_h")
			else:
				call_deferred("set_double_v")
		elif flag == 2:
			call_deferred("set_quad")
		obj2.queue_free()

func split(body):
	
	var obj = object.instance()
	var vfx = splitVFX.instance()
	
	var newPointUI = pointUI.instance()
	newPointUI.position = position
	if is_doubleh:
		if abs(body.velocity.y) > abs(body.velocity.x * 2):
			timer.start()
			can_combine = false
			call_deferred("set_single")
			obj.position = position + Vector2(0,80)
			obj.call_deferred("set_single")
			print("horz to sing")
			emit_signal("double_was_broken")
			get_parent().add_child(obj)
			newPointUI.init("100")
			get_parent().add_child(newPointUI)
			vfx.position = position
			get_parent().add_child(vfx)
	elif is_doublev:
		if abs(body.velocity.x) > abs(body.velocity.y * 2):
			timer.start()
			can_combine = false
			call_deferred("set_single")
			obj.position = position + Vector2(80,0)
			obj.call_deferred("set_single")
			emit_signal("double_was_broken")
			print("vert to sing")
			get_parent().add_child(obj)
			newPointUI.init("100")
			get_parent().add_child(newPointUI)
			vfx.position = position
			get_parent().add_child(vfx)
	elif is_quad:
		timer.start()
		can_combine = false
		if abs(body.velocity.x) > abs(body.velocity.y):
			call_deferred("set_double_h")
			obj.position = position + Vector2(0,80)
			obj.call_deferred("set_double_h")
			print("quad to horz")
		else:
			call_deferred("set_double_v")
			obj.position = position + Vector2(80,0)
			obj.call_deferred("set_double_v")
			print("quad to vert")
		emit_signal("quad_was_broken")
		get_parent().add_child(obj)
		
		
		vfx.position = position
		get_parent().add_child(vfx)
		newPointUI.init("600")
		get_parent().add_child(newPointUI)
	
	obj.velocity = -1 * velocity
	if (velocity.dot(obj.velocity) < 0):
		var temp = obj.velocity
		obj.velocity = velocity 
		velocity = temp


func get_random_vector():
	var angle = rand_range(PI/(3*2), PI/3)
	
	var x_negation = rand_range(0,1)
	if x_negation > 0.5:
		x_negation = 1
	else:
		x_negation = -1
	
	var y_negation = rand_range(0,1)
	if y_negation > 0.5:
		y_negation = 1
	else:
		y_negation = -1
	
	return Vector2(cos(angle) * x_negation, sin(angle) * y_negation).normalized()


func set_single_sprite(_tex):
	$Single/SingleSprite.texture = _tex

func set_double_sprite(_tex1, _tex2):
	$DoubleH/DoubleHSprite1.texture = _tex1
	$DoubleH/DoubleHSprite2.texture = _tex2
	$DoubleV/DoubleVSprite1.texture = _tex1
	$DoubleV/DoubleVSprite2.texture = _tex2

func set_quad_sprite(_tex1, _tex2, _tex3, _tex4):
	$Quad/QuadSprite1.texture = _tex1
	$Quad/QuadSprite2.texture = _tex2
	$Quad/QuadSprite3.texture = _tex3
	$Quad/QuadSprite4.texture = _tex4

func all_off():
	flag = 0
	$Single/SingleSprite.visible = false
	$DoubleH/DoubleHSprite1.visible = false
	$DoubleH/DoubleHSprite2.visible = false
	$DoubleV/DoubleVSprite1.visible = false
	$DoubleV/DoubleVSprite2.visible = false
	$Quad/QuadSprite1.visible = false
	$Quad/QuadSprite2.visible = false
	$Quad/QuadSprite3.visible = false
	$Quad/QuadSprite4.visible = false
	
	$SingleCollider.set_deferred("disabled", true)
	$DoubleHCollider.set_deferred("disabled", true)
	$DoubleVCollider.set_deferred("disabled", true)
	$QuadCollider.set_deferred("disabled", true)
	
	is_single = false
	is_doublev = false
	is_doubleh = false
	is_quad = false
	
	$SplitBox/DoubleH.set_deferred("disabled", true)
	$SplitBox/DoubleV.set_deferred("disabled", true)
	$SplitBox/Quad.set_deferred("disabled", true)

func set_single():
	all_off()
	flag = 1
	$Single/SingleSprite.visible = true
	$SingleCollider.set_deferred("disabled", false)
	is_single = true

func set_double_h():
	all_off()
	flag = 2
	$DoubleH/DoubleHSprite1.visible = true
	$DoubleH/DoubleHSprite2.visible = true
	$DoubleHCollider.set_deferred("disabled", false)
	is_doubleh = true
	$SplitBox/DoubleH.set_deferred("disabled", false)

func set_double_v():
	all_off()
	flag = 2
	$DoubleV/DoubleVSprite1.visible = true
	$DoubleV/DoubleVSprite2.visible = true
	$DoubleVCollider.set_deferred("disabled", false)
	is_doublev = true
	$SplitBox/DoubleV.set_deferred("disabled", false)

func set_quad():
	all_off()
	emit_signal("object_became_quad")
	flag = 4
	$Quad/QuadSprite1.visible = true
	$Quad/QuadSprite2.visible = true
	$Quad/QuadSprite3.visible = true
	$Quad/QuadSprite4.visible = true
	$QuadCollider.set_deferred("disabled", false)
	is_quad = true
	$SplitBox/Quad.set_deferred("disabled", false)



func _on_SplitBox_body_entered(body):
	if body.dashing:
		split(body)


func _on_DivideTimer_timeout():
	can_combine = true


func _on_SplitBox_body_exited(body):
	if body.dashing:
		split(body)
