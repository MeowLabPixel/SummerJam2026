#extends MeshInstance3D
#const BULLET = preload("uid://csdtdj7sci5vk")
#@onready var node_3d: Node3D = $Node3D
#@onready var player: Player = $".."
#
#
#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_pressed("click")and player.Ammo!=0:
		#var instance = BULLET.instantiate()
		#var lo = node_3d.global_position
		#instance.position = lo
		#instance.transform.basis = node_3d.transform.basis
		#instance.add_to_group("bullet")
		#get_parent().add_child(instance)
		#player.Ammo-=1
