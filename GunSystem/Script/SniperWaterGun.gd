extends Gun
class_name SniperWaterGun

func _ready():
	gun_name = "Water sniper"

func fire_projectiles():
	if is_super_active:
		fire_sniper_super_shot()
		# Immediately reset air and end super after this powerful shot
		air = 0.0
		is_super_active = false
		print("Sniper Super Shot Fired! Air Reset to 0.")
	else:
		fire_pellet()

func fire_sniper_super_shot():
	var direction: Vector3 = -camera.global_transform.basis.z
	var from: Vector3 = camera.global_transform.origin
	var to: Vector3 = from + direction * 1000.0

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var start_pos: Vector3 = spawn_point.global_transform.origin if spawn_point else from
	var exclude: Array[RID]  = []
	var max_penetration: int = 10
	var final_pos: Vector3 = to

	for i in range(max_penetration):
		var query = PhysicsRayQueryParameters3D.create(from, to, 0xFFFFFFFF, exclude)
		var result = space_state.intersect_ray(query)

		if result:
			if hit_vfx_scene:
				var hit_vfx: Node = hit_vfx_scene.instantiate()
				get_tree().current_scene.add_child(hit_vfx)
				hit_vfx.global_transform.origin = result.position

			exclude.append(result.rid)
			final_pos = result.position
		else:
			break

	if shot_vfx_scene:
		var shot_vfx: Node = shot_vfx_scene.instantiate()
		get_tree().current_scene.add_child(shot_vfx)
		if shot_vfx.has_method("set_line"):
			shot_vfx.set_line(start_pos, final_pos)

func on_super_end():
	air = 0.0
	print("Sniper Air Reset to 0 after Super.")
