## STATE: Knockdown
## Enemy falls to the ground. Plays knockdown animation for a brief period,
## then automatically transitions to GetUp.
class_name StateKnockdown
extends EnemyState

## How long the knockdown animation plays before GetUp begins.
@export var knockdown_duration: float = 2.0

var _timer: float = 0.0

func enter() -> void:
	_timer = 0.0
	print("[StateKnockdown] Enemy knocked down!")
	_play_anim("rig|Duck")  # Placeholder — swap for a knockdown anim when available.

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	_timer += delta
	if _timer >= knockdown_duration:
		state_machine.transition_to("StateGetUp")

## Cannot be stunned while on the ground.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""
