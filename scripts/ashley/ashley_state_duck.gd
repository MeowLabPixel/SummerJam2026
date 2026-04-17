## STATE: Duck
## Ashley crouches in place — triggered by:
##   (a) Player is actively shooting, OR
##   (b) Ashley is cornered (zombie blocking path to player).
## Holds for duck_duration seconds before re-checking threats.
## Shows "Leon, help!" label while cornered; hides it on exit.
class_name AshleyStateDuck
extends AshleyState

## Minimum time Ashley stays crouched before re-evaluating. Prevents jitter.
@export var duck_duration: float = 1.2

var _timer: float = 0.0

func enter() -> void:
	ashley.velocity = Vector3.ZERO
	ashley.is_cornered = true
	_timer = 0.0
	print("[AshleyStateDuck] Ducking!")
	# TODO: play duck/scared-crouch animation.

func exit() -> void:
	# Always clear the label when leaving duck, regardless of why we entered.
	ashley.is_cornered = false
	print("[AshleyStateDuck] Recovering.")
	# TODO: play stand-up / recover animation.

func physics_update(delta: float) -> void:
	# Keep velocity zeroed every frame so physics don’t drift her.
	ashley.velocity = Vector3.ZERO

	# Don’t check anything until the minimum hold has elapsed.
	_timer += delta
	if _timer < duck_duration:
		return

	# Shooting takes priority — stay ducked while active.
	if ashley.is_player_shooting():
		return

	# Hold duration elapsed and no longer shooting — return to Follow.
	# Follow will immediately re-evaluate threats and corner again if needed.
	state_machine.transition_to("AshleyStateFollow")
