class_name StateKnockdown
extends EnemyState

@export var act3_duration: float      = 1.15
@export var knockdown_duration: float = 2.0

var _timer: float      = 0.0
var _act3_timer: float = 0.0
var _in_act3: bool     = false
var stun_type: String  = "head"
var skip_act3: bool    = false

func enter() -> void:
	_timer = 0.0
	_act3_timer = 0.0
	if skip_act3:
		_in_act3 = false
		_force_anim(enemy.anim_set.takedown_idle(stun_type))
	else:
		_in_act3 = true
		_force_anim(enemy.anim_set.takedown_anim(stun_type))
	print("[StateKnockdown] Knocked down. Zone: %s skip_act3=%s" % [stun_type, skip_act3])

func exit() -> void:
	_in_act3  = false
	skip_act3 = false

func physics_update(delta: float) -> void:
	if _in_act3:
		_act3_timer += delta
		if _act3_timer >= act3_duration:
			_in_act3 = false
			_force_anim(enemy.anim_set.takedown_idle(stun_type))
	else:
		_timer += delta
		if _timer >= knockdown_duration:
			var getup = state_machine._states.get("StateGetUp")
			if getup:
				getup.stun_type = stun_type
			state_machine.transition_to("StateGetUp")

func handle_hit(_hit_data: Dictionary) -> String:
	return ""
