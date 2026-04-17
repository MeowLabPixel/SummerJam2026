## STATE: TAKEDOWNable
## Triggered by Head Shot or Foot Shot.
## Enemy staggers / falls back, stops moving.
## Plays HEADSHOT or FOOTSHOT stun animation.
## Player can now perform a takedown (melee finisher).
## If no takedown is performed within the window, transitions to Knockdown.
class_name StateTakedownable
extends EnemyState

## How long the takedown window stays open (seconds).
@export var takedown_window: float = 3.0

var _timer: float = 0.0
## Tracks which animation to play ("head" or "foot").
var stun_type: String = "head"

## Called externally by the player's takedown input system.
var takedown_triggered: bool = false

func enter() -> void:
	_timer = 0.0
	takedown_triggered = false
	print("[StateTakedownable] TAKEDOWN-able! Type: %s" % stun_type)
	# TODO: play HEADSHOT_stun or FOOTSHOT_stun animation based on stun_type.
	# TODO: stop all movement.

func exit() -> void:
	stun_type = "head"
	takedown_triggered = false

func physics_update(delta: float) -> void:
	# If the player triggered a takedown, go to Knockdown immediately.
	if takedown_triggered:
		state_machine.transition_to("StateKnockdown")
		return

	_timer += delta
	if _timer >= takedown_window:
		# Window expired — enemy recovers and goes back to Hunt.
		state_machine.transition_to("StateHunt")

## Cannot be re-stunned while in this state.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""  # Absorb all hits silently; no re-stun.

## Call this from the player's takedown logic.
func trigger_takedown() -> void:
	takedown_triggered = true
