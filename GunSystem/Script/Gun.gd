extends Node3D
class_name Gun

@export var camera: Camera3D
@export var spawn_point: Node3D
@export var shot_vfx_scene: PackedScene
@export var hit_vfx_scene: PackedScene

# Water
var water: float = 100.0
var max_water: float = 100.0

# Air
var air: float = 0.0
var max_air: float = 100.0

# Interval
var shoot_interval: float = 0.3
var shoot_timer: float = 0.0

# Pump
var pump_air_gain: float = 10.0

# Super shot
var super_threshold: float = 100.0
var is_super_shot: bool = false
var super_shot_time: float = 2.0
var super_timer: float = 0.0
var is_super_active: bool = false

# Accuracy
var min_spread: float = 0.5
var max_spread: float = 8.0
var current_spread: float = 0.0

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	if shoot_timer > 0.0:
		shoot_timer -= delta

	if is_super_active:
		super_timer -= delta
		if super_timer <= 0.0:
			is_super_active = false
			air = 0.0
			update_accuracy()
			print("Super End")
			
	update_accuracy()

func can_shoot() -> bool:
	return shoot_timer <= 0.0 and (water > 0.0 or is_super_active)

func shoot():
	if not can_shoot():
		return

	var horizontal_spread: float = deg_to_rad(randf_range(-current_spread, current_spread))
	var vertical_spread: float = deg_to_rad(randf_range(-current_spread, current_spread))
	
	var direction: Vector3 = -camera.global_transform.basis.z
	direction = direction.rotated(Vector3.UP, horizontal_spread)
	direction = direction.rotated(camera.global_transform.basis.x, vertical_spread)

	# Raycast
	var from: Vector3 = camera.global_transform.origin
	var to: Vector3 = from + direction * 1000.0	

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result: Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	var start_pos: Vector3 = spawn_point.global_transform.origin if spawn_point else from

	var end_pos: Vector3 = to
	if result:
		end_pos = result.position

	if shot_vfx_scene:
		var shot_vfx: Node = shot_vfx_scene.instantiate()
		get_tree().current_scene.add_child(shot_vfx)

		if shot_vfx.has_method("set_line"):
			shot_vfx.set_line(start_pos, end_pos)

	if result and hit_vfx_scene:
		var hit_vfx: Node = hit_vfx_scene.instantiate()
		get_tree().current_scene.add_child(hit_vfx)
		hit_vfx.global_transform.origin = result.position

	if is_super_active:
		print("SUPER SHOOT!")
	else:
		water -= 10.0
		water = max(water, 0.0)

	shoot_timer = shoot_interval

func update_accuracy():
	var t: float = clamp(air / max_air, 0.0, 1.0)
	current_spread = lerp(max_spread, min_spread, t)	

func pump_air():
	air += pump_air_gain

	if air > super_threshold:
		is_super_active = true
		super_timer = super_shot_time
		print("SUPER START")

	air = clamp(air, 0.0, max_air)
	update_accuracy()

func reload_water(water_gain):
	water += water_gain
	water = clamp(water, 0.0, max_water)

	print("Reload Water! Water:", water)
