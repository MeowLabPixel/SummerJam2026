## STATE: GetUp
## Ashley rises from her duck crouch after the threat clears.
## Plays the GetUp animation, checks that it's safe to move,
## then transitions back to Follow.
class_name AshleyStateGetUp
extends AshleyState

## Duration to hold the get-up animation before returning to Follow.
@export var getup_duration: float = 1.2

var _timer: float = 0.0

func enter() -> void:
	_timer = 0.0
	ashley.velocity = Vector3.ZERO
	print("[AshleyStateGetUp] Getting up.")
	_play_anim(AshleyAnims.GET_UP)

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	# Stay frozen during the animation.
	ashley.velocity = Vector3.ZERO
	_timer += delta
	if _timer >= getup_duration:
		state_machine.transition_to("AshleyStateFollow")

## Ignore all hits while getting up — can't be re-ducked mid-rise.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""
