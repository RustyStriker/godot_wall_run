extends KinematicBody
class_name PlayerController

# Camera control
var cam_sensitivity_x = 0.3
var cam_sensitivity_y = 0.3
var can_rotate_cam : bool = true

# Basic movement
const MAX_SPEED : float = 9.5 # Units / sec
const ACC : float = 10.5 # Units / sec ^ 2
const AIR_ACC : float = 5.5 # Units / sec ^ 2

const GRAVITY : float = 9.8 # Units / sec ^ 2
const TERMINAL_VELOCITY : float = 19.6 # Units / sec

const JUMP_FORCE : float = 7.0 # Units / sec
const CAYOTE_TIME : float = 0.2 # sec
const JQUEUE_TIME : float = 0.5 # sec

var cayote : float = -1.0
var jqueue : float = -1.0

var speed : Vector3 = Vector3()
var on_floor : bool = false
var was_floor : bool = false

# Weapons
var weapon_active : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Lock the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$circle_gui.connect("on_item_pick",self, "change_weapon")

func _input(event):
	# Camera Control
	if event is InputEventMouseMotion and can_rotate_cam:
		# Get the distance
		var distance = event.relative
		# Change the yaw(Rotation along the Y axis)
		rotation_degrees.y = fmod(rotation_degrees.y - distance.x * cam_sensitivity_x, 360)
		# Change the pitch(Rotation along the X axis)
		$cam.rotation_degrees.x = max(min(89, $cam.rotation_degrees.x - distance.y * cam_sensitivity_y),-89)
	if Input.is_action_just_pressed("ui_pick"):
		$circle_gui.show_gui()
		can_rotate_cam = false

func change_weapon(index):
	can_rotate_cam = true
	printt(index, $circle_gui.items[index])
	weapon_active = index
	$cam/P90.visible = false
	$cam/Shotgun.visible = false
	$cam/Blaster.visible = false
	$cam/Blaster.set_active(false)
	if index == 1:
		$cam/P90.visible = true
	elif index == 2:
		$cam/Shotgun.visible = true
	elif index == 3:
		$cam/Blaster.visible = true
		$cam/Blaster.set_active(true)

func _process(delta):
	if cayote >= 0:
		cayote -= delta
	if jqueue >= 0:
		jqueue -= delta

func _physics_process(delta):
	# ##############################################
	# ################## MOVEMENT ##################
	# ############################################## 
	# Get input
	var basis = $cam.get_camera_transform().basis
	var input = Vector3()
	input -= (int(Input.is_action_pressed("move_w")) - int(Input.is_action_pressed("move_s"))) * basis.z
	input += (int(Input.is_action_pressed("move_d")) - int(Input.is_action_pressed("move_a"))) * basis.x
	input.y = 0 # We dont want input over the Y axis since this is reserved for gravity
	input = input.normalized()
	
	# Do gravity
	speed.y -= GRAVITY * delta
	if speed.y < -TERMINAL_VELOCITY:
		speed.y = -TERMINAL_VELOCITY
	
	var temp_speed : Vector3 = speed
	temp_speed.y = 0
	if was_floor and on_floor:
		temp_speed = temp_speed.linear_interpolate(input * MAX_SPEED, ACC * delta)
	else:
		input = input * (1 - temp_speed.normalized().dot(input) + 0.5)
		temp_speed = (temp_speed.normalized() + input * AIR_ACC * delta) * temp_speed.length()
		if temp_speed.length_squared() > pow(MAX_SPEED, 2):
			temp_speed = temp_speed.normalized() * MAX_SPEED
	
	speed.x = temp_speed.x
	speed.z = temp_speed.z
	
	# Lets apply the movement(as a move_and_slide for now)
	var coll = move_and_collide(speed * delta)
	
	was_floor = on_floor
	var on_wall = false
	if coll != null: # We have a collision omg omg omg
		move_and_collide(coll.remainder.slide(coll.normal)) # Move the remaining portion
		speed = speed.slide(coll.normal) # Slide the movement ( Maybe change later for diff behavior 
		var dot = coll.normal.dot(Vector3.UP)
		on_floor = dot > 0.7
		on_wall = abs(dot) <= 0.7
		# I legit dont care about getting hit by the ceiling
	else:
		on_floor = false
		on_wall = false
	
	if on_floor:
		# Jumping related stuff
		if jqueue > 0:
			do_jump()
		cayote = CAYOTE_TIME
	
	if Input.is_action_just_pressed("jump"):
		if cayote > 0:
			do_jump()
		else:
			jqueue = JQUEUE_TIME
	
	# ###########################################
	# ################# SHOOTING ################
	# ###########################################
	if Input.is_action_pressed("attack"):
		shoot()

func do_jump():
	speed.y = JUMP_FORCE
	cayote = -1
	jqueue = -1

func shoot():
	if weapon_active == 0:
		return
	var weapon = $cam.get_child(weapon_active - 1)
	if weapon is GunBase:
		weapon.shoot()
	elif weapon is BlasterCannon:
		pass
	else:
		printt("ERROR",name,"shoot() CHILD IS NOT GunBase")











