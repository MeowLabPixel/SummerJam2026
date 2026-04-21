## STATE: Idle
## Plays random idle animations.
## Transitions to Hunt when combat is initiated
## (player walks too close OR shoots the enemy).
class_name StateIdle
extends EnemyState

## Distance at which the enemy auto-detects the player and enters Hunt.
@export var detection_radius: float = 5.0

## Set to true externally (e.g. by a bullet hit) to trigger combat.
var combat_initiated: bool = false

# Simple list of idle animation names — swap with real anim names later.
var IDLE_ANIMS: Array[String] = [ZombieAnims.IDLE]
var _idle_timer: float = 0.0
var _idle_interval: float = 3.0  # seconds between random idle swaps

func enter() -> void:
	combat_initiated = false
	_idle_timer = 0.0
	_pick_random_idle()
	print("[StateIdle] Entered Idle.")

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	# ── Proximity check ─────────────────────────────────────────────────
	# TODO: swap enemy.get_player_position() with real player node lookup.
	var player_pos: Vector3 = _get_placeholder_target_position()
	var dist: float = enemy.global_position.distance_to(player_pos)
	if dist <= detection_radius or combat_initiated:
		state_machine.transition_to("StateHunt")
		return

	# ── Random idle cycling ──────────────────────────────────────────────
	_idle_timer += delta
	if _idle_timer >= _idle_interval:
		_idle_timer = 0.0
		_idle_interval = randf_range(2.0, 5.0)
		_pick_random_idle()

func handle_hit(_hit_data: Dictionary) -> String:
	# Wake the enemy and immediately react to the hit zone.
	# Returning StateStun lets the state machine pre-load hit_zone before enter().
	combat_initiated = true
	var zone: String = _hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot":
			return "StateTakedownable"
		_:
			return "StateStun"

# ─── Helpers ───────────────────────────────────────────────────────────────
func _pick_random_idle() -> void:
	var anim: String = IDLE_ANIMS[randi() % IDLE_ANIMS.size()]
	_play_anim(anim)

func _get_placeholder_target_position() -> Vector3:
	# Reads mouse-projected world position set by TestWorld controller.
	if enemy and enemy.has_meta("target_position"):
		return enemy.get_meta("target_position")
	return Vector3(9999, 0, 9999)  # fallback: far away so idle stays idle
