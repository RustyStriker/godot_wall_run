extends Node

# Bullets(?)
var BlasterBullet = preload("res://assets/gunz/Blaster/BlasterBullet.tscn")

# Effects
func clear_effects():
	for c in get_children():
		c.queue_free()
	#print("DEBUG","VFX","CLEARING EFFECTS")

# Shooting vfx
var shot_vfx = preload("res://vfx/gun_shots/shot_vfx.tscn")
func spawn_shot_vfx(position : Vector3, normal : Vector3):
	var inst = shot_vfx.instance()
	inst.translation = position
	inst.play(normal)
	add_child(inst)
