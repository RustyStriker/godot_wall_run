extends GunBase

# Timers
var action : float = -1

func _process(delta):
	if action > 0:
		action -= delta

# Ammo
const MAG_SIZE : int = 30 # Bullets in mag

var mag : int = MAG_SIZE # Current mag
var bullets_left : int = MAG_SIZE * 3 # Total amount of bullets

func add_ammo(amount : int):
	bullets_left += amount
	if bullets_left < 0:
		bullets_left = 0

func get_ammo() -> int:
	return bullets_left

func get_mag() -> int:
	return mag

const RELOAD_CD : float = 1.5 # Seconds
func reload():
	if action <= 0:
		if bullets_left > MAG_SIZE:
			mag = MAG_SIZE
		else:
			mag = bullets_left
		action = RELOAD_CD

# Shooting

const SHOOT_CD : float = 0.24
func shoot():
	if action <= 0:
		# Do actual shooting here
		action = SHOOT_CD
		var dir : Vector3 = -get_viewport().get_camera().get_camera_transform().basis.z
		#$muzzle/dir.global_transform.origin - $muzzle.global_transform.origin
		dir = dir.normalized()
		var phy = PhysicsServer.space_get_direct_state(get_world().space)
		var from = get_viewport().get_camera().global_transform.origin
		#$muzzle.global_transform.origin
		var ray = phy.intersect_ray(from,from + dir * 1000, [] ,1)
		if not ray.empty():
			VFX.spawn_shot_vfx(ray["position"], ray["normal"])
		$AnimationPlayer.play("Fire")



























