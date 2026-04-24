class_name StateStun
extends EnemyState

@export var stun_duration: float = 1.0

var _timer: float  = 0.0
var hit_zone: String = "body"

func enter() -> void:
	_timer = 0.0
	print("[StateStun] Stun! Zone: %s" % hit_zone)
	var anim: String = enemy.anim_set.hit_reaction(hit_zone)
	_force_anim(anim)
	if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
		stun_duration = enemy.anim_player.get_animation(anim).length
	else:
		stun_duration = 1.0

func exit() -> void:
	hit_zone = "body"

func physics_update(delta: float) -> void:
	_timer += delta
	if _timer >= stun_duration:
		state_machine.transition_to("StateHunt")

func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot", "left_leg", "right_leg":
			return "StateTakedownable"
		_:
			_timer = 0.0
			hit_zone = zone
			var anim: String = enemy.anim_set.hit_reaction(hit_zone)
			_force_anim(anim)
			if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
				stun_duration = enemy.anim_player.get_animation(anim).length
			return ""
