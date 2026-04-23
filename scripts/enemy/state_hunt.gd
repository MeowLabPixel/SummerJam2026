## STATE: Hunt
## Enemy pathfinds toward the player (placeholder: mouse-projected position).
## Checks attack cone each frame; if player is in front → Attack.
## If player is behind the 180° threshold → TurnBack.
class_name StateHunt
extends EnemyState

@export var move_speed: float = 2.5
## Half-angle (degrees) of the forward attack cone.
@export var attack_cone_half_angle: float = 45.0
## Distance at which the enemy will attempt to attack.
@export var attack_range: float = 0.8
## Name of the state to transition to when in attack range.
## Change to "StateRangedAttack" on ranged enemy scenes.
@export var attack_state: String = "StateAttack"

@onready var nav_agent: NavigationAgent3D = enemy.get_node_or_null("NavigationAgent3D") if enemy else null

## Walk animation chosen on enter — fixed for the duration of this Hunt.
var _walk_anim: String = ""

func enter() -> void:
	print("[StateHunt] Entered Hunt — pathfinding to target.")
	_walk_anim = ZombieAnims.random_walk()
	_play_anim(_walk_anim)

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	var target_pos: Vector3 = _get_target_position()

	# ── Update navigation target ─────────────────────────────────────────
	if nav_agent:
		nav_agent.target_position = target_pos

	# ── Direction to target ──────────────────────────────────────────────
	var to_target: Vector3 = (target_pos - enemy.global_position)
	to_target.y = 0.0
	var flat_dist: float = to_target.length()

	if flat_dist < 0.1:
		_play_anim(ZombieAnims.IDLE)
		return  # Already on top of target.

	var dir_to_target: Vector3 = to_target.normalized()
	var forward: Vector3 = -enemy.global_transform.basis.z  # Godot default forward

	# ── Behind check (TurnBack) ──────────────────────────────────────────
	var dot: float = forward.dot(dir_to_target)
	# dot < 0 means target is behind the 90° threshold; we use 0 for strict 180° split.
	if dot < 0.0:
		state_machine.transition_to("StateTurnBack")
		return

	# ── Attack range + cone check ────────────────────────────────────────
	if flat_dist <= attack_range:
		var angle_to_target: float = rad_to_deg(acos(clampf(dot, -1.0, 1.0)))
		if angle_to_target <= attack_cone_half_angle:
			state_machine.transition_to(attack_state)
			return

	# ── Move toward target via nav agent ────────────────────────────────
	var move_dir: Vector3
	if nav_agent and not nav_agent.is_navigation_finished():
		var next_pos: Vector3 = nav_agent.get_next_path_position()
		move_dir = (next_pos - enemy.global_position).normalized()
	else:
		move_dir = dir_to_target
	move_dir.y = 0.0

	if move_dir.length() > 0.01:
		enemy.velocity = move_dir * move_speed
		enemy.move_and_slide()
		var look_target: Vector3 = enemy.global_position + move_dir
		enemy.look_at(look_target, Vector3.UP)
		_play_anim(_walk_anim)
	else:
		enemy.velocity = Vector3.ZERO
		_play_anim(ZombieAnims.IDLE)

func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot", "left_leg", "right_leg":
			return "StateTakedownable"
		_:
			return "StateStun"

# ─── Helpers ───────────────────────────────────────────────────────────────
func _get_target_position() -> Vector3:
	var player = _get_player()
	if player:
		return player.global_position
	return enemy.global_position

func _get_player() -> Node3D:
	var players = enemy.get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null
