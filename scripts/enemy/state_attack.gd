## STATE: Attack / Grab
## Enemy is in attack range and facing the player.
## Mostly attacks (timed lunge + damage pulse); small random chance to grab.
##
## GRAB FLOW:
##   1. Play ZOMBIE_ATTEMPT_GRAB
##   2. Player has until _escape_window_end to press "grab_escape"
##   3a. Player escapes → ZOMBIE_GRAB_FAIL → back to Hunt
##   3b. Player doesn't escape → ZOMBIE_GRAB_SUCCESS → deal grab_damage → back to Hunt
##
## ATTACK FLOW:
##   1. Play ZOMBIE_ATTEMPT_GRAB as a stand-in melee swing (TODO: replace)
##   2. At _damage_pulse_time deal attack_damage to player
##   3. Return to Hunt when anim finishes
class_name StateAttack
extends EnemyState

## Probability (0–1) of choosing Grab over Attack.
@export var grab_chance: float = 0.15
## Damage dealt by a successful grab.
@export var grab_damage: int = 8
## Damage dealt by the standard attack hit pulse.
@export var attack_damage: int = 5
## Fraction through the attack anim at which the damage pulse fires (0–1).
@export var attack_damage_frac: float = 0.5

var _timer: float = 0.0
var _anim_duration: float = 1.4
var _chose_grab: bool = false
var _grab_resolved: bool = false  # true once success/fail has been chosen
var _damage_pulsed: bool = false
## Seconds from enter() during which the player can press grab_escape.
var _escape_window_end: float = 0.0

func enter() -> void:
	_timer = 0.0
	_grab_resolved = false
	_damage_pulsed = false
	_chose_grab = randf() < grab_chance

	var anim: String = ZombieAnims.ZOMBIE_ATTEMPT_GRAB
	_force_anim(anim)

	if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim):
		_anim_duration = enemy.anim_player.get_animation(anim).length
	else:
		_anim_duration = 1.4

	# Escape window = first half of the attempt animation.
	_escape_window_end = _anim_duration * 0.5

	if _chose_grab:
		print("[StateAttack] GRAB attempt — mash grab_escape to escape!")
	else:
		print("[StateAttack] ATTACK")

func exit() -> void:
	# Disconnect the animation_finished signal if it's still connected.
	if enemy and enemy.anim_player:
		if enemy.anim_player.animation_finished.is_connected(_on_attempt_finished):
			enemy.anim_player.animation_finished.disconnect(_on_attempt_finished)

func physics_update(delta: float) -> void:
	_timer += delta

	if _chose_grab and not _grab_resolved:
		# Check if the player pressed grab_escape during the window.
		if _timer < _escape_window_end:
			if Input.is_action_just_pressed("grab_escape"):
				_resolve_grab(false)  # player escaped
				return
		else:
			# Window closed — grab succeeds.
			_resolve_grab(true)
			return

	if not _chose_grab and not _damage_pulsed:
		# Fire the attack damage at the midpoint of the swing.
		if _timer >= _anim_duration * attack_damage_frac:
			_damage_pulsed = true
			_deal_attack_damage()

	# Return to Hunt once animation is done.
	if _timer >= _anim_duration:
		state_machine.transition_to("StateHunt")

func handle_hit(hit_data: Dictionary) -> String:
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot":
			return "StateTakedownable"
		_:
			return ""  # Body hits don't interrupt an attack.

# ─── Grab resolution ───────────────────────────────────────────────────────

func _resolve_grab(success: bool) -> void:
	_grab_resolved = true
	if success:
		print("[StateAttack] Grab SUCCESS — dealing %d damage" % grab_damage)
		_force_anim(ZombieAnims.ZOMBIE_GRAB_SUCCESS)
		_notify_player_grabbed(true)
		_deal_grab_damage()
	else:
		print("[StateAttack] Grab FAIL — player escaped")
		_force_anim(ZombieAnims.ZOMBIE_GRAB_FAIL)
		_notify_player_grabbed(false)
	# Wait for this new anim to finish, then return to Hunt.
	var finish_anim: String = ZombieAnims.ZOMBIE_GRAB_SUCCESS if success else ZombieAnims.ZOMBIE_GRAB_FAIL
	if enemy and enemy.anim_player:
		var ap: AnimationPlayer = enemy.anim_player as AnimationPlayer
		if ap.has_animation(finish_anim):
			_anim_duration = _timer + ap.get_animation(finish_anim).length
		if not ap.animation_finished.is_connected(_on_attempt_finished):
			ap.animation_finished.connect(_on_attempt_finished, CONNECT_ONE_SHOT)

func _on_attempt_finished(_anim_name: StringName) -> void:
	state_machine.transition_to("StateHunt")

# ─── Damage helpers ────────────────────────────────────────────────────────

func _deal_attack_damage() -> void:
	var player := _get_player()
	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)
	else:
		print("[StateAttack] Attack hit player for %d (no take_damage method yet)" % attack_damage)

func _deal_grab_damage() -> void:
	var player := _get_player()
	if player and player.has_method("take_damage"):
		player.take_damage(grab_damage)
	else:
		print("[StateAttack] Grab dealt %d to player (no take_damage method yet)" % grab_damage)

func _notify_player_grabbed(success: bool) -> void:
	## Tell the player to freeze/unfreeze and play the matching Leon anim.
	var player := _get_player()
	if not player:
		return
	if player.has_method("on_grabbed"):
		player.on_grabbed(success)
	else:
		print("[StateAttack] Player grabbed=%s (no on_grabbed method yet)" % success)

func _get_player() -> Node3D:
	if enemy and enemy.has_meta("target_position"):
		# Walk the scene tree to find the node in the 'player' group.
		var players: Array = enemy.get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			return players[0] as Node3D
	return null
