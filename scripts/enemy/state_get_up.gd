class_name StateGetUp
extends EnemyState

@export var getup_duration: float = 1.5

var _timer: float     = 0.0
var stun_type: String = "head"

func enter() -> void:
	_timer = 0.0
	print("[StateGetUp] Getting up. Zone: %s" % stun_type)
	var anim = enemy.anim_set.get_up_anim(stun_type)
	_play_anim(anim)
	#if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
		#getup_duration = enemy.anim_player.get_animation(anim).length

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	_timer += delta
	if _timer >= getup_duration:
		state_machine.transition_to("StateHunt")

func handle_hit(_hit_data: Dictionary) -> String:
	return ""
