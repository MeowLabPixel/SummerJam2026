extends Gun
class_name ShotgunWaterGun

@export var pellet_count: int = 5

func _ready():
	damage = 10.0
	shoot_interval = 0.8
	max_water = 80.0
	max_air = 120.0