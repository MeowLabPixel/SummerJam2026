extends Node3D
class_name Gun

@export var camera: Camera3D
@export var spawn_point: Node3D
@export var shot_vfx_scene: PackedScene
@export var hit_vfx_scene: PackedScene

var water_tank: GunController

@export_group("Gun Stats")
@export var damage: float = 10.0
@export var water_consumption: float = 2.0
@export var air_consumption: float = 10.0
@export var shoot_interval: float = 0.3
@export var pump_air_gain: float = 10.0
@export var max_air: float = 100.0
@export var super_threshold: float = 120.0

# Air
var air: float = 0.0

# Interval
var shoot_timer: float = 0.0

# Super shot
var is_super_ready: bool = false
var is_super_active: bool = false
var super_shot_time: float = 2.0
var super_timer: float = 0.0

# Accuracy
@export var min_spread: float = 0.5
@export var max_spread: float = 8.0
var current_spread: float = 0.0

func _process(delta):
	if shoot_timer > 0.0:
		shoot_timer -= delta

	if is_super_active:
		super_timer -= delta
		if super_timer <= 0.0:
			is_super_active = false
			on_super_end()
			update_accuracy()
			print("Super End")
			
	update_accuracy()

func on_super_end():
	air = max_air # Default behavior

func can_shoot() -> bool:
	var has_water = water_tank.current_water >= water_consumption if water_tank else false
	var has_air = air >= air_consumption
	return shoot_timer <= 0.0 and (is_super_active or (has_water and has_air))

func shoot():
	if not can_shoot():
		return

	# Activate Super Shot if ready
	if is_super_ready and not is_super_active:
		is_super_active = true
		is_super_ready = false
		super_timer = super_shot_time
		print("SUPER ACTIVATED BY SHOT!")

	if is_super_active:
		print("SUPER SHOOT! (Infinite Water/Air)")
	else:
		# Consume resources
		if water_tank:
			water_tank.current_water -= water_consumption
			water_tank.current_water = max(water_tank.current_water, 0.0)
		
		air -= air_consumption
		air = max(air, 0.0)

	fire_projectiles()
	shoot_timer = shoot_interval

func fire_projectiles():
	fire_pellet()

func fire_pellet():
# ... (rest of fire_pellet unchanged)
	var horizontal_spread: float = deg_to_rad(randf_range(-current_spread, current_spread))
	var vertical_spread: float = deg_to_rad(randf_range(-current_spread, current_spread))
	
	var direction: Vector3 = -camera.global_transform.basis.z
	direction = direction.rotated(Vector3.UP, horizontal_spread)
	direction = direction.rotated(camera.global_transform.basis.x, vertical_spread)

	# Raycast
	var from: Vector3 = camera.global_transform.origin
	var to: Vector3 = from + direction * 1000.0	

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)
	
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

func update_accuracy():
	var t: float = clamp(air / max_air, 0.0, 1.0)
	current_spread = lerp(max_spread, min_spread, t)	

func pump_air():
	if is_super_active:
		return

	var old_air = air
	
	if air < max_air:
		air += pump_air_gain
		if air > max_air:
			air = max_air
	else:
		# Already at or above max_air, pumping goes toward super_threshold
		air += pump_air_gain
		if air >= super_threshold:
			air = super_threshold
			is_super_ready = true
			print("SUPER READY")

	update_accuracy()

func reload_water(water_gain):
	if water_tank:
		water_tank.current_water += water_gain
		water_tank.current_water = clamp(water_tank.current_water, 0.0, water_tank.max_water)
		print("Reload Water! Water:", water_tank.current_water)
