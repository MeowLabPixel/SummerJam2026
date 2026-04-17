## STATE: Follow
## Player-following is the ALWAYS-ON base behaviour.
## Zombie avoidance is layered ON TOP as an additive repulsion vector —
## it never switches off following, it only nudges the direction.
## Duck is the only true interrupt (shooting / cornered).
class_name AshleyStateFollow
extends AshleyState

@export var move_speed: float = 3.5
## Stop moving once within this distance of the player.
@export var follow_stop_distance: float = 2.0
## Threat repulsion radius — zombie influence fades beyond this (units).
@export var repulsion_radius: float = 4.0
## Maximum extra speed added when fleeing a close zombie.
@export var flee_speed_bonus: float = 1.0
## Rotation smoothing (higher = snappier).
@export var rotation_speed: float = 10.0

func enter() -> void:
	print("[AshleyStateFollow] Following player.")
	# TODO: play walk / idle animation.

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	# ── Duck interrupt: player is shooting ───────────────────────────────
	if ashley.is_player_shooting():
		state_machine.transition_to("AshleyStateDuck")
		return

	var my_pos: Vector3 = ashley.global_position
	var target_pos: Vector3 = ashley.get_follow_target()

	var to_target: Vector3 = (target_pos - my_pos)
	to_target.y = 0.0
	var dist_to_target: float = to_target.length()

	# ── Base follow vector ────────────────────────────────────────────────
	# Always points toward player. Zero when already close enough.
	var follow_vec: Vector3 = Vector3.ZERO
	if dist_to_target > follow_stop_distance:
		follow_vec = to_target.normalized()

	# ── Additive repulsion vector (zombie avoidance) ──────────────────────
	# Sum repulsion from every nearby threat, weighted by proximity.
	# Closer zombies push harder. This is ADDED to follow, never replaces it.
	var repulsion_vec: Vector3 = Vector3.ZERO
	var strongest_threat_dist: float = repulsion_radius  # Track closest for speed bonus.
	for threat in ashley.nearby_threats:
		if not is_instance_valid(threat):
			continue
		var away: Vector3 = (my_pos - threat.global_position)
		away.y = 0.0
		var d: float = away.length()
		if d < 0.01 or d > repulsion_radius:
			continue
		# Weight: 1.0 at d=0, 0.0 at d=repulsion_radius.
		var weight: float = 1.0 - (d / repulsion_radius)
		repulsion_vec += away.normalized() * weight
		if d < strongest_threat_dist:
			strongest_threat_dist = d

	# ── Combine and move ─────────────────────────────────────────────────
	var steer: Vector3 = follow_vec + repulsion_vec
	steer.y = 0.0

	if steer.length() < 0.01:
		# Perfectly cancelled — already at player with zombie on top of us.
		# Just stop; duck will handle the cornered case via stuck timer.
		ashley.velocity = Vector3.ZERO
	else:
		var move_dir: Vector3 = steer.normalized()
		# Speed bonus when a zombie is very close.
		var proximity_t: float = 1.0 - clampf(strongest_threat_dist / repulsion_radius, 0.0, 1.0)
		var speed: float = move_speed + flee_speed_bonus * proximity_t

		ashley.nav_agent.target_position = target_pos
		ashley.velocity = move_dir * speed
		ashley.move_and_slide()
		if move_dir.length() > 0.01:
			_face_toward(move_dir, delta)

	# ── Cornered check ───────────────────────────────────────────────────
	# Conditions that must ALL be true:
	#   1. A zombie is actively pushing her (repulsion has real magnitude).
	#   2. That push is opposing her path to the player (dot < -0.15).
	#   3. She's already within the follow stop radius (can't get any closer).
	if not ashley.nearby_threats.is_empty() \
			and repulsion_vec.length() > 0.4 \
			and dist_to_target <= follow_stop_distance + 0.3 \
			and repulsion_vec.normalized().dot(to_target.normalized()) < -0.15:
		print("[AshleyStateFollow] Cornered — ducking. dist=%.2f rep=%.2f" \
				% [dist_to_target, repulsion_vec.length()])
		# Set is_cornered AFTER exit() can no longer clear it — pass via Duck's enter.
		state_machine.transition_to("AshleyStateDuck")
		return

# ─── Helpers ───────────────────────────────────────────────────────────────
func _face_toward(dir: Vector3, delta: float) -> void:
	var look_target: Vector3 = ashley.global_position + dir
	var target_basis: Basis = ashley.global_transform.looking_at(look_target, Vector3.UP).basis
	ashley.global_transform.basis = ashley.global_transform.basis.slerp(
		target_basis.orthonormalized(), clampf(rotation_speed * delta, 0.0, 1.0))
