## STATE: Knockdown
## Enemy falls to the ground. Plays knockdown animation for a brief period,
## then automatically transitions to GetUp.
class_name StateKnockdown
extends EnemyState

## How long Act 3 (takedown animation) plays before switching to Act 4 (ground idle).
@export var act3_duration: float = 1.15
## How long the enemy sits in the ground idle before getting up.
@export var knockdown_duration: float = 2.0

var _timer: float = 0.0
var _act3_timer: float = 0.0
var _in_act3: bool = false

func enter() -> void:
	_timer = 0.0
	_act3_timer = 0.0
	_in_act3 = true
	print("[StateKnockdown] Enemy knocked down!")
	_force_anim(ZombieAnims.HIT_HEAD_ACT3_TAKEDOWN)

func exit() -> void:
	_in_act3 = false

func physics_update(delta: float) -> void:
	if _in_act3:
		_act3_timer += delta
		if _act3_timer >= act3_duration:
			_in_act3 = false
			_force_anim(ZombieAnims.HIT_HEAD_ACT4_TAKEDOWN_IDLE)
	else:
		_timer += delta
		if _timer >= knockdown_duration:
			state_machine.transition_to("StateGetUp")

## Cannot be stunned while on the ground.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""
