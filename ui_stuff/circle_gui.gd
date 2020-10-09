tool
extends Control

signal on_item_pick(index)

export(Array) var items = []
export(int) var radius = 150
export(float,0.01,1.00) var time_slow = 0.1


# Sweet reminder keep it on Process if you want to be able to pause the game
func _ready():
	if not Engine.editor_hint:
		self.hide()
		# Generate everything(images? i dont know)
		var angle = 360.0 / items.size()
		for i in range(0,items.size()):
			var label : Label = Label.new()
			label.text = str(items[i])
			label.rect_position = polar2cartesian(radius, deg2rad(angle * i - 95))
			$Panel/items.add_child(label)
#			var image : Sprite = Sprite.new()
#			image.texture = items[i]
#			image.position = polar2cartesian(radius, deg2rad(angle * i - 90))
#			$Panel/items.add_child(image)

func _input(event):
	if visible: # Choose here how to end the thingy
		if Input.is_action_just_released("ui_pick"):
			pick_gui()

func show_gui():
	self.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	slow_engine_time()

func pick_gui():
	var polar = $Panel/items.get_local_mouse_position()
	polar = cartesian2polar(polar.x,polar.y)
	var angle = wrap_to(rad2deg(polar.y),360)
	var index = fmod(int(round(items.size() * (angle + 90) / 360)),items.size())
	self.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	revert_engine_time()
	emit_signal("on_item_pick",index)

func _draw():
	if Engine.editor_hint:
		draw_arc($Panel/items.rect_global_position ,radius,0,TAU,100,Color.black,2.0)
	else:
		var angle = 360.0 / items.size()
		var base_pos = $Panel/items.rect_global_position
		for i in range(0, items.size()):
			var line_pos = polar2cartesian(1, deg2rad(angle * i - 0.5 * angle - 90))
			draw_line(base_pos + line_pos * 0.05 * radius, base_pos + line_pos * radius * 1.2, Color.gray, 2.0, true)

func wrap_to(value : float, wrap : float) -> float:
	while value > wrap:
		value -= wrap
	if value < 0:
		value += wrap
	return value

func slow_engine_time():
	Engine.time_scale *= time_slow

func revert_engine_time():
	Engine.time_scale = 1


