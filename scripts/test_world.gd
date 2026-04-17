## TestWorld — prototype controller.
## Mouse position on the ground plane acts as the "player" target.
## Left-click shoots the enemy (body hit).
## Shift+Left-click = head shot, Ctrl+Left-click = foot shot.
extends Node3D

@export var enemy_path: NodePath = ^"Enemy"
@export var ashley_path: NodePath = ^"Ashley"
@export var camera_path: NodePath = ^"CamRig/Camera3D"

@onready var enemy: CharacterBody3D = get_node(enemy_path)
@onready var ashley: CharacterBody3D = get_node(ashley_path)
@onready var camera: Camera3D = get_node(camera_path)

## How long after the last shot the "shooting" flag stays true (seconds).
const SHOOT_FLAG_DURATION: float = 0.4
var _shoot_flag_timer: float = 0.0

# Ground plane at y = 0 for mouse raycasting.
var _ground_plane := Plane(Vector3.UP, 0.0)

func _ready() -> void:
	print("[TestWorld] Ready. Left-click = shoot body. Shift+Click = head. Ctrl+Click = foot.")

func _process(delta: float) -> void:
	_update_targets()
	_tick_shoot_flag(delta)
	_check_shoot()
	_check_takedown()

## Project mouse onto the ground plane and store it on both the enemy and Ashley.
func _update_targets() -> void:
	if not camera:
		return
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)
	var hit: Variant = _ground_plane.intersects_ray(ray_origin, ray_dir)
	if hit:
		if enemy:
			enemy.set_meta("target_position", hit)
		if ashley:
			ashley.set_meta("target_position", hit)

## Counts down the shooting flag so Ashley knows when to un-duck.
func _tick_shoot_flag(delta: float) -> void:
	if _shoot_flag_timer > 0.0:
		_shoot_flag_timer -= delta
		if _shoot_flag_timer <= 0.0 and ashley:
			ashley.set_meta("player_shooting", false)

## Shoot on left mouse button press.
func _check_shoot() -> void:
	if not Input.is_action_just_pressed("shoot"):
		return
	if not enemy:
		return

	var zone := "body"
	if Input.is_key_pressed(KEY_CTRL):
		zone = "foot"
	elif Input.is_key_pressed(KEY_SHIFT):
		zone = "head"

	var hit_data := {"damage": 5, "hit_zone": zone}
	print("[TestWorld] Shot fired! Zone: %s, Damage: 5" % zone)
	enemy.take_hit(hit_data)
	# Tell Ashley the player is shooting so she ducks.
	if ashley:
		ashley.set_meta("player_shooting", true)
		_shoot_flag_timer = SHOOT_FLAG_DURATION

## E key = perform takedown while enemy is in TAKEDOWNable state.
func _check_takedown() -> void:
	if not Input.is_action_just_pressed("takedown"):
		return
	if not enemy:
		return
	# Find the StateTakedownable node and call trigger_takedown() if it's active.
	var sm = enemy.get_node_or_null("EnemyStateMachine")
	if not sm:
		return
	var td_state = sm.get_node_or_null("StateTakedownable")
	if td_state and sm.current_state == td_state:
		print("[TestWorld] TAKEDOWN executed!")
		td_state.trigger_takedown()
	else:
		print("[TestWorld] Takedown attempted but enemy is not in TAKEDOWNable state.")
