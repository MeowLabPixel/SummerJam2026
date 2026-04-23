## STATE: RangedAttack
## Used by both the Water Gun zombie and the Balloon zombie.
## No hand contact required — damage fires when the attack animation reaches
## its release frame (fraction-based), representing the projectile leaving
## the zombie's hands.
##
## attack_type export selects which animation and damage profile to use.
## Set this in the inspector on the scene that uses this state.
class_name StateRangedAttack
extends EnemyState

enum AttackType { WATER_GUN, BALLOON }

## Which kind of ranged attack this zombie does.
@export var attack_type: AttackType = AttackType.WATER_GUN
## Damage dealt when the shot lands (player must be in range).
@export var attack_damage: int = 4
## Maximum range the shot can reach (units).
@export var attack_range: float = 8.0
## Fraction through the animation at which the "projectile fires" (0-1).
@export var release_frac: float = 0.5
## Minimum time between attacks (seconds) — cooldown before returning to Hunt.
@export var post_attack_delay: float = 0.5

var _timer: float = 0.0
var _anim_duration: float = 1.5
var _damage_dealt: bool = false
var _anim_done: bool = false

func enter() -> void:
	_timer = 0.0
	_damage_dealt = false
	_anim_done = false

	var anim := _pick_anim()
	_force_anim(anim)
	if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
		_anim_duration = enemy.anim_player.get_animation(anim).length
	else:
		_anim_duration = 1.5

	print("[StateRangedAttack] %s attack (%.2fs)" % [AttackType.keys()[attack_type], _anim_duration])

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	_timer += delta

	# Fire damage at the release frame (once per attack).
	if not _damage_dealt and _timer >= _anim_duration * release_frac:
		_damage_dealt = true
		_try_deal_damage()

	# Animation finished — wait for post_attack_delay then return to Hunt.
	if not _anim_done and _timer >= _anim_duration:
		_anim_done = true
		# Play idle while waiting out the cooldown.
		_play_anim(_pick_idle_anim())

	if _anim_done and _timer >= _anim_duration + post_attack_delay:
		state_machine.transition_to("StateHunt")

## Body hits still stagger the ranged zombie; head/foot shots take it down.
func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "left_leg", "right_leg", "foot":
			return "StateTakedownable"
		_:
			return "StateStun"

# ─── Helpers ─────────────────────────────────────────────────────────────────

func _pick_anim() -> String:
	match attack_type:
		AttackType.BALLOON: return ZombieAnims.BALLOON_THROW
		_:                  return ZombieAnims.RANGE_SHOOT

func _pick_idle_anim() -> String:
	match attack_type:
		AttackType.BALLOON: return ZombieAnims.BALLOON_IDLE
		_:                  return ZombieAnims.RANGE_IDLE

func _try_deal_damage() -> void:
	var player := _get_player()
	if not player:
		return
	var dist: float = enemy.global_position.distance_to(player.global_position)
	if dist > attack_range:
		print("[StateRangedAttack] Shot missed — player out of range (%.1f > %.1f)" % [dist, attack_range])
		return
	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
	print("[StateRangedAttack] Hit player for %d damage (dist %.1f)" % [attack_damage, dist])

func _get_player() -> Node3D:
	var players: Array = enemy.get_tree().get_nodes_in_group("player")
	return players[0] as Node3D if players.size() > 0 else null
