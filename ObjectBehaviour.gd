extends KinematicBody2D

var object = load("res://Object.tscn")

var dir = Vector2(1,1)
var speed = 300
var velocity = speed * dir

var flag = 1
var id = 0

var is_single = false
var is_doublev = false
var is_doubleh = false
var is_quad = false


signal object_became_quad
signal quad_was_broken
signal double_was_broken

func _ready():
	id = Singleton.obj_id
	Singleton.obj_id += 1
	all_off()

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
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	
	if collision:
#		print(collision.collider.get_collision_layer())
		if (collision.collider.get_collision_layer() == 2):
			velocity = velocity.bounce(collision.normal)
		else:
			if can_combine(self, collision.collider):
				combine(collision.collider, collision)
			else:
				velocity = velocity.bounce(collision.normal)
		# else hit the player

func can_combine(obj1, obj2):
	if not obj2.is_in_group("Player"):
		if obj1.flag == obj2.flag:
			return true
		else:
			return false
	else:
		return false

func combine(obj2, collision: KinematicCollision2D):
	if (id > obj2.id):
		if flag == 1:
			pass
			if abs((collision.position - position).x) > abs((collision.position - position).y):
				call_deferred("set_double_h")
			else:
				call_deferred("set_double_v")
		if flag == 2:
			call_deferred("set_quad")
		obj2.queue_free()

func split(body):
	
	if is_doubleh:
		if abs(body.velocity.y) > abs(body.velocity.x * 2):
			call_deferred("set_single")
			var obj = object.instance()
			obj.position = position + Vector2(10,0)
			obj.velocity = obj.speed * get_random_vector()
			obj.call_deferred("set_single")
			get_parent().add_child(obj)
			emit_signal("double_was_broken")
			print("horz to sing")
	elif is_doublev:
		if abs(body.velocity.x) > abs(body.velocity.y * 2):
			call_deferred("set_single")
			var obj = object.instance()
			obj.position = position + Vector2(0,10)
			obj.velocity = -1 * velocity
			obj.call_deferred("set_single")
			get_parent().add_child(obj)
			emit_signal("double_was_broken")
			print("vert to sing")
	elif is_quad:
		if abs(body.velocity.x) > abs(body.velocity.y):
			call_deferred("set_double_h")
			var obj = object.instance()
			obj.position = position + Vector2(0,10)
			obj.velocity = -1 * velocity
			obj.call_deferred("set_double_h")
			get_parent().add_child(obj)
			print("quad to vert")
		else:
			call_deferred("set_double_v")
			var obj = object.instance()
			obj.position = position + Vector2(10,0)
			obj.velocity = -1 * velocity
			obj.call_deferred("set_double_v")
			get_parent().add_child(obj)
			print("quad to horz")
		emit_signal("quad_was_broken")

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

func _on_SplitBox_body_exited(body):
	if body.dashing:
		split(body)


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
	
	$SingleCollider.disabled = true
	$DoubleHCollider.disabled = true
	$DoubleVCollider.disabled = true
	$QuadCollider.disabled = true
	
	is_single = false
	is_doublev = false
	is_doubleh = false
	is_quad = false
	
	$SplitBox/DoubleH.disabled = true
	$SplitBox/DoubleV.disabled = true
	$SplitBox/Quad.disabled = true

func set_single():
	all_off()
	flag = 1
	$Single/SingleSprite.visible = true
	$SingleCollider.disabled = false
	is_single = true

func set_double_h():
	all_off()
	flag = 2
	$DoubleH/DoubleHSprite1.visible = true
	$DoubleH/DoubleHSprite2.visible = true
	$DoubleHCollider.disabled = false
	is_doubleh = true
	$SplitBox/DoubleH.disabled = false

func set_double_v():
	all_off()
	flag = 2
	$DoubleV/DoubleVSprite1.visible = true
	$DoubleV/DoubleVSprite2.visible = true
	$DoubleVCollider.disabled = false
	is_doublev = true
	$SplitBox/DoubleV.disabled = false

func set_quad():
	all_off()
	emit_signal("object_became_quad")
	flag = 4
	$Quad/QuadSprite1.visible = true
	$Quad/QuadSprite2.visible = true
	$Quad/QuadSprite3.visible = true
	$Quad/QuadSprite4.visible = true
	$QuadCollider.disabled = false
	is_quad = true
	$SplitBox/Quad.disabled = false

