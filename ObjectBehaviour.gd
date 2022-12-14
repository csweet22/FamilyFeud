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

var gmaSheet = preload("res://ObjectArt/GrandmaSheet.tres")
var woman1Sheet = preload("res://ObjectArt/Woman1Sheet.tres")
var man1Sheet = preload("res://ObjectArt/Man1Sheet.tres")
var pinkSheet = preload("res://ObjectArt/PinkSheet.tres")

func spawnVFX():
	$CPUParticles2D.restart()

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

func set_random_sprite():
	var temp = rand_range(0,4)
	
	if (temp < 1) and (temp > 0):
		$Single/SingleSprite.frames = gmaSheet
	elif (temp > 1) and (temp < 2):
		$Single/SingleSprite.frames = woman1Sheet
	elif (temp > 2) and (temp < 3):
		$Single/SingleSprite.frames = man1Sheet
	elif (temp > 3) and (temp < 4):
		$Single/SingleSprite.frames = pinkSheet
	
	

func _process(delta):
	set_animation()
	if Input.is_key_pressed(KEY_1):
		set_single()
	if Input.is_key_pressed(KEY_2):
		set_double_h()
	if Input.is_key_pressed(KEY_3):
		set_double_v()
	if Input.is_key_pressed(KEY_4):
		set_quad()
		
	if can_combine or is_quad:
		set_sprite_mod(Color(1,1,1,1))
	else:
		set_sprite_mod(Color(0.7,0.8,0.9,1.0))


func set_animation():
	if velocity.x > 0:
		if is_single:
			set_single_sprite_anim("right")
	else:
		if is_single:
			set_single_sprite_anim("left")


#set_double_sprite_anim("argue_right", "argue_left")
#set_quad_sprite_anim("argue_right", "argue_left", "argue_right", "argue_left")

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

func set_sprite_mod(color):
	$Single/SingleSprite.modulate = color
	$DoubleH/DoubleHSprite1.modulate = color
	$DoubleH/DoubleHSprite2.modulate = color
	$DoubleV/DoubleVSprite1.modulate = color
	$DoubleV/DoubleVSprite2.modulate = color
#	$Quad/QuadSprite1.modulate = color
#	$Quad/QuadSprite2.modulate = color
#	$Quad/QuadSprite3.modulate = color
#	$Quad/QuadSprite4.modulate = color

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
		$CombinePlayer.play()
		if flag == 1:
			if abs((collision.position - position).x) > abs((collision.position - position).y):
				call_deferred("set_double_h")
				set_double_sprite($Single/SingleSprite.frames, obj2.get_single_sprite())
				set_double_sprite_anim("argue_left", "argue_right")
			else:
				call_deferred("set_double_v")
				set_double_sprite($Single/SingleSprite.frames, obj2.get_single_sprite())
				set_double_sprite_anim("argue_left", "argue_right")
				
		elif flag == 2:
			call_deferred("set_quad")
			$Alert.play("mega_alert")
			set_quad_sprite(get_double_sprite()[0],get_double_sprite()[1], obj2.get_double_sprite()[0], obj2.get_double_sprite()[1])
			set_quad_sprite_anim("argue_left", "argue_left", "argue_right", "argue_right")
		obj2.queue_free()

var offset = 50

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
			obj.set_single_sprite(get_double_sprite()[0])
			set_single_sprite(get_double_sprite()[1])
			newPointUI.init("100")
			get_parent().add_child(newPointUI)
			vfx.position = position
			get_parent().add_child(vfx)
			$BreakApart.play()
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
			obj.set_single_sprite(get_double_sprite()[0])
			set_single_sprite(get_double_sprite()[1])
			newPointUI.init("100")
			get_parent().add_child(newPointUI)
			vfx.position = position
			get_parent().add_child(vfx)
			$BreakApart.play()
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
		
		$BreakApart.play()
		obj.set_double_sprite(get_quad_sprite()[0], get_quad_sprite()[1])
		obj.set_double_sprite_anim("argue_left","argue_right")
		set_double_sprite(get_quad_sprite()[2], get_quad_sprite()[3])
		emit_signal("quad_was_broken")
		get_parent().add_child(obj)
		
		
		vfx.position = position
		get_parent().add_child(vfx)
		newPointUI.init("600")
		$Alert.play("Alert")
		obj.set_reg_alert()
		get_parent().add_child(newPointUI)
	
	obj.velocity = -1 * velocity
	if (velocity.dot(obj.velocity) < 0):
		var temp = obj.velocity
		obj.velocity = velocity 
		velocity = temp

func set_reg_alert():
	$Alert.play("Alert")

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
	$Single/SingleSprite.frames = _tex

func set_double_sprite(_tex1, _tex2):
	$DoubleH/DoubleHSprite1.frames = _tex1
	$DoubleH/DoubleHSprite2.frames = _tex2
	$DoubleV/DoubleVSprite1.frames = _tex1
	$DoubleV/DoubleVSprite2.frames = _tex2

func set_quad_sprite(_tex1, _tex2, _tex3, _tex4):
	$Quad/QuadSprite1.frames = _tex1
	$Quad/QuadSprite2.frames = _tex2
	$Quad/QuadSprite3.frames = _tex3
	$Quad/QuadSprite4.frames = _tex4

func get_single_sprite():
	return $Single/SingleSprite.frames

func get_double_sprite():
	return [$DoubleH/DoubleHSprite1.frames, $DoubleH/DoubleHSprite2.frames]

func get_quad_sprite():
	return [$Quad/QuadSprite1.frames, $Quad/QuadSprite2.frames, $Quad/QuadSprite3.frames, $Quad/QuadSprite4.frames]

func set_single_sprite_anim(_tex):
	$Single/SingleSprite.animation = _tex

func set_double_sprite_anim(_tex1, _tex2):
	$DoubleH/DoubleHSprite1.animation = _tex1
	$DoubleH/DoubleHSprite2.animation = _tex2
	$DoubleV/DoubleVSprite1.animation = _tex1
	$DoubleV/DoubleVSprite2.animation = _tex2

func set_quad_sprite_anim(_tex1, _tex2, _tex3, _tex4):
	$Quad/QuadSprite1.animation = _tex1
	$Quad/QuadSprite2.animation = _tex2
	$Quad/QuadSprite3.animation = _tex3
	$Quad/QuadSprite4.animation = _tex4

func all_off():
	flag = 0
	$AlertSprite.position.y = 0
	$Single/SingleSprite.visible = false
	$DoubleH/DoubleHSprite1.visible = false
	$DoubleH/DoubleHSprite2.visible = false
	$DoubleV/DoubleVSprite1.visible = false
	$DoubleV/DoubleVSprite2.visible = false
	$Quad/QuadSprite1.visible = false
	$Quad/QuadSprite2.visible = false
	$Quad/QuadSprite3.visible = false
	$Quad/QuadSprite4.visible = false
	
	$Single/SingleDropShadow.visible = false
	$Quad/QuadShadow.visible = false
	$DoubleH/DoubleHShadow.visible = false
	$DoubleV/DoubleVShadow.visible = false
	
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
	$Single/SingleDropShadow.visible = true
	$SingleCollider.set_deferred("disabled", false)
	is_single = true
	$AlertSprite.visible = false

func set_double_h():
	all_off()
	flag = 2
	$DoubleH/DoubleHSprite1.visible = true
	$DoubleH/DoubleHSprite2.visible = true
	$DoubleH/DoubleHShadow.visible = true
	$AlertSprite.visible = true
	$DoubleHCollider.set_deferred("disabled", false)
	is_doubleh = true
	$SplitBox/DoubleH.set_deferred("disabled", false)

func set_double_v():
	all_off()
	flag = 2
	$AlertSprite.position.y -= offset
	$DoubleV/DoubleVSprite1.visible = true
	$DoubleV/DoubleVSprite2.visible = true
	$DoubleV/DoubleVShadow.visible = true
	$AlertSprite.visible = true
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
	$Quad/QuadShadow.visible = true
	$AlertSprite.visible = true
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
