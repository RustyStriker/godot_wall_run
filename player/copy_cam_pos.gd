extends Camera

export(NodePath) var main_cam = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if main_cam == null:
		print("ERR","COPY_CAM_POS","NO MAIN CAM")
		queue_free()
	elif not get_node(main_cam) is Camera:
		print("Not a cam")
		queue_free()


func _process(_delta):
	var cam : Camera = get_node(main_cam)
	global_transform = cam.global_transform
