extends KinematicBody

# Camera control
var cam_sensitivity_x = 0.3
var cam_sensitivity_y = 0.3
var can_rotate_cam : bool = true

# Basic movement
const MAX_SPEED : float = 9.5 # Units / sec
const ACC : float = 10.5 # Units / sec ^ 2
const AIR_ACC : float = 3.5 # Units / sec ^ 2

const GRAVITY : float = 9.8 # Units / sec ^ 2
const TERMINAL_VELOCITY : float = 19.6 # Units / sec

const JUMP_FORCE : float = 7.0 # Units / sec
const CAYOTE_TIME : float = 0.2 # sec
const JQUEUE_TIME : float = 0.1 # sec

var cayote : float = -1.0
var jqueue : float = -1.0 # jump queueing

var speed : Vector3 = Vector3()
var on_floor : bool = false
var was_floor : bool = false

# Wall running
const WALL_RUN_MAX_SPEED : float = 14.5 # Units - figure out how to keep it later
const WALL_RUN_RANGE : float = 1.0 # Units sideways
const WALL_RUN_TIME : float = 1.25 # Seconds
const WALL_RUN_HEAD_TILT : float = deg2rad(10) # Keep in radians to avoid further conversions
export(CurveTexture) var WALL_RUN_Y_SPEED = null

var is_wall_running : bool = false
var wall_run_timer : float = 0.0 # Seconds
var last_wall_collider = null # Last wall the player ran on

# Weapons
var weapon_active : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Lock the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var _r = $circle_gui.connect("on_item_pick",self, "change_weapon")

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
	
	if is_wall_running:
		wall_run_timer -= delta
	else:
		if abs($cam.rotation.z) == WALL_RUN_HEAD_TILT:
			tween_cam_z(0)

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
		#printt(temp_speed.length(), input)
		if temp_speed.length_squared() > 1:
			input = input * (1 - temp_speed.normalized().dot(input) + 0.1)
		else:
			input = input / delta
			#printt("BUMPED",input.length_squared())
		
		temp_speed = (temp_speed.normalized() + input * AIR_ACC * delta) * temp_speed.length()
		if temp_speed.length_squared() > pow(MAX_SPEED, 2):
			temp_speed = temp_speed.normalized() * MAX_SPEED
	
	speed.x = temp_speed.x
	speed.z = temp_speed.z
	
	# Do wall running
	wall_running()
	
	# Lets apply the movement(as a move_and_slide for now)
	var coll = move_and_collide(speed * delta)
	
	was_floor = on_floor
	if coll != null: # We have a collision omg omg omg
		var _c = move_and_collide(coll.remainder.slide(coll.normal)) # Move the remaining portion
		speed = speed.slide(coll.normal) # Slide the movement ( Maybe change later for diff behavior 
		var dot = coll.normal.dot(Vector3.UP)
		on_floor = dot > 0.7
		# Walls detection will be made using raycasting
		# I legit dont care about getting hit by the ceiling
	else:
		on_floor = false
	
	if on_floor:
		# Jumping related stuff
		if jqueue > 0:
			do_jump()
		cayote = CAYOTE_TIME
	
	if Input.is_action_just_pressed("jump"):
		if cayote > 0:
			do_jump()
		elif not is_wall_running:
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

func wall_running():
	if on_floor or was_floor:
		is_wall_running = false
		last_wall_collider = null
		$cam.rotation.z = 0
		return
	# Walls detection
	var phy : PhysicsDirectSpaceState = PhysicsServer.space_get_direct_state(get_world().space)
	#var cam_x : Vector3 = get_viewport().get_camera().get_camera_transform().basis.x
	var wall_axis : Vector3 = Vector3(speed.x,0,speed.z).rotated(Vector3(0,1,0),deg2rad(90)).normalized()
	var from : Vector3 = global_transform.origin
	var left_ray = phy.intersect_ray(from, from + wall_axis * WALL_RUN_RANGE, [], 1)
	var right_ray = phy.intersect_ray(from, from - wall_axis * WALL_RUN_RANGE, [], 1)
	#printt("LEFT RAY",not left_ray.empty())
	# Just an exit case and is_wall_running_reset
	if left_ray.empty() and right_ray.empty():
		is_wall_running = false
		return
	if Vector3(speed.x,0,speed.z).length_squared() > 16.0:
		if not left_ray.empty():
			run_on_the_wall(left_ray, true)
		if not right_ray.empty():
			run_on_the_wall(right_ray, false)

func run_on_the_wall(data : Dictionary, left : bool):
	if (not is_wall_running or wall_run_timer <= 0) and last_wall_collider == data["collider"]:
		is_wall_running = false
		return
	if WALL_RUN_Y_SPEED != null:
		speed.y = WALL_RUN_Y_SPEED.curve.interpolate_baked(1 - wall_run_timer / WALL_RUN_TIME)
	#printt(speed,speed.slide(left_ray["normal"]))
	speed = speed.slide(data["normal"])
	if not is_wall_running:
		# Basically init a wall run
		last_wall_collider = data["collider"]
		is_wall_running = true
		wall_run_timer = WALL_RUN_TIME
		# Change cam Z angle
		if left:
			tween_cam_z(-WALL_RUN_HEAD_TILT)
		else:
			tween_cam_z(WALL_RUN_HEAD_TILT)
	if Input.is_action_just_pressed("jump"):
		# Do wall jump
		do_jump()
		speed += data["normal"] * JUMP_FORCE
		wall_run_timer = -1
		tween_cam_z(0)

func tween_cam_z(angle : float):
	$tn.interpolate_method(self,"tween_cam_z_helper", $cam.rotation.z, angle, 0.1)
	$tn.start()

func tween_cam_z_helper(angle : float):
	$cam.rotation.z = angle





