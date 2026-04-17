## STATE: TurnBack
## Player is outside the enemy's 180° forward arc.
## Plays the 180° turn animation, then returns to Hunt.
class_name StateTurnBack
extends EnemyState

## Duration of the turn animation (seconds). Swap with anim length later.
@export var turn_duration: float = 0.6

var _timer: float = 0.0

# Store the target rotation so we can slerp toward it.
var _target_basis: Basis

func enter() -> void:
	_timer = 0.0
	print("[StateTurnBack] Turning 180°.")
	# Compute target basis: rotate enemy 180° around Y from current facing.
	_target_basis = enemy.global_transform.basis.rotated(Vector3.UP, PI)

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	_timer += delta
	# Slerp toward the 180° target over the turn duration.
	# orthonormalized() prevents basis drift from move_and_slide causing slerp to crash.
	var t: float = clampf(_timer / turn_duration, 0.0, 1.0)
	var from_basis: Basis = enemy.global_transform.basis.orthonormalized()
	var to_basis: Basis = _target_basis.orthonormalized()
	enemy.global_transform.basis = from_basis.slerp(to_basis, t)
	if _timer >= turn_duration:
		# Snap to exact target and return to Hunt.
		enemy.global_transform.basis = _target_basis.orthonormalized()
		state_machine.transition_to("StateHunt")

func handle_hit(hit_data: Dictionary) -> String:
	# Can still be interrupted mid-turn.
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot":
			return "StateTakedownable"
		_:
			return "StateStun"
