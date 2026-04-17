## STATE: GetUp
## Enemy is rising from the ground.
## Cannot move. Cannot be stunned by water gun in this state.
## Plays get-up animation, then transitions back to Hunt.
class_name StateGetUp
extends EnemyState

## Duration of the get-up animation.
@export var getup_duration: float = 1.5

var _timer: float = 0.0

func enter() -> void:
	_timer = 0.0
	print("[StateGetUp] Enemy getting up.")
	# TODO: play get-up animation.
	# TODO: keep movement disabled.

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	_timer += delta
	if _timer >= getup_duration:
		state_machine.transition_to("StateHunt")

## Water gun hits are ignored in this state (spec requirement).
## Only lethal/finishing hits (damage that drops HP to 0) will be processed
## by EnemyBase — state machine just absorbs all hit signals here.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""
