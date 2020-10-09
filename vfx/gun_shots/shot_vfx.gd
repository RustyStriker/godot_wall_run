extends Spatial

var lifetime : float = 1
var is_play : bool = false

func _ready():
	if not Engine.editor_hint:
		lifetime = 1

func play(normal : Vector3):
	normal = normal.normalized()
	var up = Vector3.UP
	#printt(normal,up)
	if compare_vector(normal,up):
		up = Vector3.LEFT
	look_at_from_position(translation ,translation + normal, up)
	is_play = true
	$Particles.emitting = true

func vfx_done():
	queue_free()

func _process(delta):
	if is_play:
		if lifetime < 0:
			queue_free()
		else:
			lifetime -= delta


func compare_vector(a : Vector3, b : Vector3) -> bool:
	return abs(a.x) == abs(b.x) and abs(a.z) == abs(b.z) and abs(a.y) == abs(b.y)
