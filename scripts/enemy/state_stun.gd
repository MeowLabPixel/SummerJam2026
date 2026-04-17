## STATE: Stun
## Short hit-reaction interrupt. Enemy cannot move or attack.
## Triggered by body hits. Does NOT trigger on Head Shot or Foot Shot.
class_name StateStun
extends EnemyState

## Duration of the stun / hit-reaction animation.
@export var stun_duration: float = 0.5

var _timer: float = 0.0
## Which body part was hit — drives the animation variant.
var hit_zone: String = "body"

func enter() -> void:
	_timer = 0.0
	print("[StateStun] Stun! Zone: %s" % hit_zone)
	# TODO: play hit-reaction animation for hit_zone variant.
	# TODO: stop movement / disable attack.

func exit() -> void:
	hit_zone = "body"

func physics_update(delta: float) -> void:
	_timer += delta
	if _timer >= stun_duration:
		state_machine.transition_to("StateHunt")

## Stun can be extended/re-triggered by another body hit.
func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot":
			return "StateTakedownable"
		_:
			# Re-stun: reset the timer instead of transitioning.
			_timer = 0.0
			hit_zone = zone
			return ""
