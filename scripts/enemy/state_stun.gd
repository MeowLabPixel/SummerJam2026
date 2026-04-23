## STATE: Stun
## Short hit-reaction interrupt. Enemy cannot move or attack.
## Triggered by body hits. Does NOT trigger on Head Shot or Foot Shot.
class_name StateStun
extends EnemyState

## Duration of the stun / hit-reaction animation.
@export var stun_duration: float = 1.0

var _timer: float = 0.0
## Which body part was hit — drives the animation variant.
var hit_zone: String = "body"

func enter() -> void:
	_timer = 0.0
	print("[StateStun] Stun! Zone: %s" % hit_zone)
	var anim: String = ZombieAnims.hit_reaction(hit_zone)
	print("[StateStun] Playing anim: '%s' exists=%s" % [anim, enemy.anim_player.has_animation(anim) if enemy and enemy.anim_player else false])
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

## Stun can be extended/re-triggered by another body hit.
func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot", "left_leg", "right_leg":
			return "StateTakedownable"
		_:
			# Re-stun: restart the timer AND replay the flinch animation.
			_timer = 0.0
			hit_zone = zone
			var anim: String = ZombieAnims.hit_reaction(hit_zone)
			_force_anim(anim)
			if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
				stun_duration = enemy.anim_player.get_animation(anim).length
			return ""
