extends Area

var radius : float = 0.5

const SPEED : float = 20.0 # Units / sec

var direction : Vector3 = Vector3()

func _ready():
	if radius <= 0:
		printt("ERROR",name, "RADIUS <= 0")
		queue_free()
	if direction == Vector3():
		printt("ERROR", name, "NO DIRECTION GIVEN")
		queue_free()
	var col_shape = SphereShape.new()
	col_shape.radius = radius * 0.8
	$CollisionShape.shape = col_shape
	$sphere.radius = radius
	var _c = connect("body_entered",self,"on_body_enter")

func on_body_enter(body):
	printt("DEBUG",name,"BODY ENTER",body,body.name)
	queue_free()


func _physics_process(delta):
	translate(direction * SPEED * delta)
