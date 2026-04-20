extends Gun
class_name SniperWaterGun

func _init():
	# Very slow but high pressure usage
	shoot_interval = 1.2
	max_water = 60.0
	max_air = 150.0