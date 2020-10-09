extends Spatial
class_name BlasterCannon

var active : bool = false

func set_active(status : bool):
	active = status
	if not status:
		set_radius()
		$charging.emitting = false
		charge = 0

const MAX_CHARGE : float = 5.5 # Units
const CHARGE_SCALE : float = 0.1 # Scale for the blast sphere

var charge : float = 0.0 # How much charge is in the current bullet

func _process(delta):
	if active:
		if Input.is_action_pressed("attack"):
			# Do charging
			if charge < MAX_CHARGE:
				charge += delta
				$charging.emitting = true
			else:
				charge = MAX_CHARGE
				$charging.emitting = false
			set_radius()
		else:
			if charge > 0:
				# Shoot the charge we have
				printt("DEBUG",name,"SHOOTING BULLET CHARGE", charge, "OUT OF", MAX_CHARGE)
				spawn_bullet()
				charge = 0
				set_radius()
			$charging.emitting = false

func set_radius():
	$blast.radius = CHARGE_SCALE * charge + 0.001

func spawn_bullet():
	var bullet = VFX.BlasterBullet.instance()
	bullet.radius = CHARGE_SCALE * charge
	var dir : Vector3 = -get_viewport().get_camera().get_camera_transform().basis.z
	#$muzzle/dir.global_transform.origin - $muzzle.global_transform.origin
	dir = dir.normalized()
	var phy = PhysicsServer.space_get_direct_state(get_world().space)
	var from = get_viewport().get_camera().global_transform.origin
	#$muzzle.global_transform.origin
	var ray = phy.intersect_ray(from,from + dir * 1000, [] ,1)
	if not ray.empty():
		bullet.direction = (ray["position"] - $blast.global_transform.origin).normalized()
	else:
		bullet.direction = dir
	$AnimationPlayer.play("Fire")
	VFX.add_child(bullet)
	bullet.global_transform.origin = $blast.global_transform.origin
















