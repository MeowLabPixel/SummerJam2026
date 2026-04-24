## STATE: RangedAttack
## Used by both the Water Gun zombie and the Balloon zombie.
class_name StateRangedAttack
extends EnemyState

enum AttackType { WATER_GUN, BALLOON }

@export var attack_type: AttackType = AttackType.WATER_GUN
@export var attack_damage: int = 4
@export var attack_range: float = 8.0
@export var release_frac: float = 0.5
@export var post_attack_delay: float = 0.5

# Balloon-only settings
@export var balloon_scene: PackedScene
@export var balloon_arc_height: float = 3.0
@export var balloon_travel_time: float = 1.2
@export var balloon_splash_radius: float = 3.0
@export var balloon_spawn_point: Node3D

var _timer: float = 0.0
var _anim_duration: float = 1.5
var _damage_dealt: bool = false
var _anim_done: bool = false

func enter() -> void:
	_timer        = 0.0
	_damage_dealt = false
	_anim_done    = false

	var anim := _pick_anim()
	_force_anim(anim)

	if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
		_anim_duration = enemy.anim_player.get_animation(anim).length
	else:
		_anim_duration = 1.5

	print("[StateRangedAttack] %s attack (%.2fs)" % [AttackType.keys()[attack_type], _anim_duration])

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	_timer += delta

	# Fire at the release frame once per attack
	if not _damage_dealt and _timer >= _anim_duration * release_frac:
		_damage_dealt = true
		_try_deal_damage()

	# Animation finished — play idle during cooldown
	if not _anim_done and _timer >= _anim_duration:
		_anim_done = true
		_force_anim(_pick_idle_anim())

	if _anim_done and _timer >= _anim_duration + post_attack_delay:
		state_machine.transition_to("StateHunt")

func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "left_leg", "right_leg", "foot":
			return "StateTakedownable"
		_:
			return "StateStun"

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _pick_anim() -> String:
	match attack_type:
		AttackType.BALLOON: return ZombieAnims.BALLOON_THROW
		_:                  return ZombieAnims.RANGE_SHOOT

func _pick_idle_anim() -> String:
	match attack_type:
		AttackType.BALLOON: return ZombieAnims.BALLOON_IDLE
		_:                  return ZombieAnims.RANGE_IDLE

func _try_deal_damage() -> void:
	var player := _get_player()
	if not player:
		return

	match attack_type:
		AttackType.BALLOON:
			_throw_balloon(player)
		AttackType.WATER_GUN:
			_fire_water_gun(player)

func _fire_water_gun(player: Node3D) -> void:
	var dist: float = enemy.global_position.distance_to(player.global_position)
	if dist > attack_range:
		print("[StateRangedAttack] Shot missed — out of range (%.1f > %.1f)" % [dist, attack_range])
		return

	# Raycast to check line of sight
	var from: Vector3 = enemy.global_position + Vector3.UP * 1.5
	var to   := player.global_position + Vector3.UP * 1.0
	var space = enemy.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	query.collide_with_areas  = true
	query.exclude = [enemy.get_rid()]
	var result = space.intersect_ray(query)

	# Only deal damage if the ray hits the player directly (not a wall)
	if result and result.collider.is_in_group("player"):
		player.take_damage(attack_damage)
		print("[StateRangedAttack] Water gun hit player for %d (dist %.1f)" % [attack_damage, dist])
	else:
		print("[StateRangedAttack] Water gun blocked by obstacle")

func _throw_balloon(player: Node3D) -> void:
	if not balloon_scene:
		push_warning("[StateRangedAttack] No balloon_scene assigned")
		# Fallback to instant damage if no scene set
		player.take_damage(attack_damage)
		return

	var balloon: Node3D = balloon_scene.instantiate()
	enemy.get_tree().current_scene.add_child(balloon)

	var spawn_pos = balloon_spawn_point.global_position if balloon_spawn_point \
		else enemy.global_position + Vector3.UP * 1.8

	balloon.global_position = spawn_pos

	if balloon.has_method("launch"):
		balloon.launch(player.global_position, attack_damage, balloon_splash_radius,
			balloon_arc_height, balloon_travel_time)
	else:
		push_warning("[StateRangedAttack] Balloon scene has no launch() method")

func _get_player() -> Node3D:
	var players: Array = enemy.get_tree().get_nodes_in_group("player")
	return players[0] as Node3D if players.size() > 0 else null
