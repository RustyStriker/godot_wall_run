extends Spatial
class_name GunBase

func shoot():
	print("ERROR",name,"shoot() NOT IMPLEMENTED ON GUN")

func reload():
	print("ERROR",name, "reload() NOT IMPLEMENTED ON GUN")

func add_ammo(amount : int):
	print("ERROR",name,"add_ammo() NOT IMPLEMENTED ON GUN")

func get_ammo() -> int:
	print("ERROR",name,"get_ammo() NOT IMPLEMENTED ON GUN")
	return -1

func get_mag() -> int:
	print("ERROR",name,'get_mag() NOT IMPLEMENTED ON GUN')
	return -1
