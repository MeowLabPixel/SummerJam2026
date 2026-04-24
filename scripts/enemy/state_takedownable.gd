class_name StateTakedownable
extends EnemyState

@export var takedown_window: float = 6.0
@export var act1_duration: float   = 1.2

var _timer: float      = 0.0
var _act1_timer: float = 0.0
var _in_act1: bool     = false
var stun_type: String  = "head"
var takedown_triggered: bool = false

func enter() -> void:
	_timer = 0.0
	takedown_triggered = false
	print("[StateTakedownable] TAKEDOWN-able! Type: %s" % stun_type)
	_start_act1()

func _start_act1() -> void:
	_in_act1 = true
	_act1_timer = 0.0
	var anim = enemy.anim_set.hit_reaction(stun_type)
	_force_anim(anim)
	if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
		act1_duration = enemy.anim_player.get_animation(anim).length

func exit() -> void:
	stun_type = "head"
	takedown_triggered = false
	_in_act1 = false

func physics_update(delta: float) -> void:
	if takedown_triggered:
		state_machine.transition_to("StateKnockdown")
		return
	if _in_act1:
		_act1_timer += delta
		if _act1_timer >= act1_duration:
			_in_act1 = false
			_force_anim(enemy.anim_set.stun_idle(stun_type))
	_timer += delta
	if _timer >= takedown_window:
		state_machine.transition_to("StateHunt")

func handle_hit(hit_data: Dictionary) -> String:
	match hit_data.get("hit_zone", "body"):
		"head", "left_leg", "right_leg":
			_timer = 0.0
			_start_act1()
			return ""
		_:
			return "StateStun"

func trigger_takedown() -> void:
	takedown_triggered = true
