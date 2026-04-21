## STATE: TAKEDOWNable
## Triggered by Head Shot or Foot Shot.
## Enemy staggers / falls back, stops moving.
## Plays HEADSHOT or FOOTSHOT stun animation.
## Player can now perform a takedown (melee finisher).
## If no takedown is performed within the window, transitions to Knockdown.
class_name StateTakedownable
extends EnemyState

## How long the takedown window stays open (seconds).
@export var takedown_window: float = 4.0
## Duration of Act 1 jerk animation before switching to the stun idle loop.
@export var act1_duration: float = 0.4

var _timer: float = 0.0
var _act1_timer: float = 0.0
var _in_act1: bool = false
## Tracks which animation to play ("head" or "foot").
var stun_type: String = "head"

## Called externally by the player's takedown input system.
var takedown_triggered: bool = false

func enter() -> void:
	_timer = 0.0
	takedown_triggered = false
	print("[StateTakedownable] TAKEDOWN-able! Type: %s" % stun_type)
	_start_act1()

func _start_act1() -> void:
	_in_act1 = true
	_act1_timer = 0.0
	_force_anim(ZombieAnims.HIT_HEAD_ACT1)

func exit() -> void:
	stun_type = "head"
	takedown_triggered = false
	_in_act1 = false

func physics_update(delta: float) -> void:
	if takedown_triggered:
		state_machine.transition_to("StateKnockdown")
		return

	# Advance Act 1 timer; once it elapses, switch to looping Act 2.
	if _in_act1:
		_act1_timer += delta
		if _act1_timer >= act1_duration:
			_in_act1 = false
			_force_anim(ZombieAnims.HIT_HEAD_ACT2_STUN_IDLE)

	_timer += delta
	if _timer >= takedown_window:
		state_machine.transition_to("StateHunt")

## Head/foot hits reset the stun window and replay Act 1.
## Body/arm hits play their hit reaction and transition to StateStun.
func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot":
			_timer = 0.0
			_start_act1()
			return ""
		_:
			return "StateStun"

## Call this from the player's takedown logic.
func trigger_takedown() -> void:
	takedown_triggered = true
