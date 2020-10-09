extends GunBase

# Action timer
var action : float = -1

func _process(delta):
	if action > 0:
		action -= delta

# Ammo
const MAG_SIZE : int = 6

var mag : int = MAG_SIZE # Starts fully loaded
var ammo_left : int = MAG_SIZE * 2

func add_ammo(amount : int):
	ammo_left += amount
	if ammo_left < 0:
		ammo_left = 0

func get_ammo() -> int:
	return ammo_left

func get_mag() -> int:
	return mag

const RELOAD_CD : float = 1.0 # Seconds - loads 1 bullet
func reload():
	if action <= 0:
		if mag < MAG_SIZE and mag < ammo_left:
			mag += 1
			action = RELOAD_CD

# Shooting
const SHOOT_CD : float = 0.8
func shoot():
	if action <= 0:
		# Do actual shooting here
		action = SHOOT_CD
		var dir : Vector3 = -get_viewport().get_camera().get_camera_transform().basis.z
		#$muzzle/dir.global_transform.origin - $muzzle.global_transform.origin
		dir = dir.normalized()
		var phy = PhysicsServer.space_get_direct_state(get_world().space)
		for _i in range(0,5):
			shoot_bullet(phy, dir)
		$AnimationPlayer.play("Fire")

func shoot_bullet(phy : PhysicsDirectSpaceState , dir : Vector3):
	var from = get_viewport().get_camera().global_transform.origin
	dir = dir.rotated(Vector3(1 - 2  * randf(),1 - 2 * randf(),1 - 2 * randf()).normalized(), deg2rad(randf() * 15) )
	var ray = phy.intersect_ray(from, from + dir * 1000)
	if not ray.empty():
		VFX.spawn_shot_vfx(ray["position"], ray["normal"])














