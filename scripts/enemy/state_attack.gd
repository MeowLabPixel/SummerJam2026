## STATE: Attack
## Enemy is in attack range and facing the player.
## Randomly chooses between a standard attack swing and a grab attempt.
##
## ATTACK FLOW:
##   1. Play a random ZombieAnims.ATTACK_* animation.
##   2. Enable both hand hitboxes during the swing window (fraction of anim).
##   3. If a hand Area3D overlaps the player, deal attack_damage once.
##   4. Return to Hunt when the animation finishes.
##
## GRAB FLOW:
##   Phase 1 – GRAB_REACH  : zombie lunges; must make hand contact to latch.
##   Phase 2 – GRAB_HOLD   : zombie holds on, GrabQteHud spawns on screen.
##     QTE: player shakes mouse to escape within the time limit.
##     Success (escaped) -> Phase 3b GRAB_FAIL anim -> Hunt (no damage).
##     Failure (caught)  -> Phase 3a GRAB_SUCCESS anim -> Hunt + grab_damage.
##   If the reach whiffs (no contact), skip straight back to Hunt.
class_name StateAttack
extends EnemyState

## Probability (0-1) of choosing Grab over a standard Attack.
@export var grab_chance: float      = 0.25
## Damage dealt when the grab QTE is failed by the player.
@export var grab_damage: int        = 12
## Damage dealt by a successful standard-attack hit.
@export var attack_damage: int      = 6
## Fraction of the attack anim length at which the swing hitbox opens.
@export var swing_start_frac: float = 0.5
## Fraction at which the swing hitbox closes.
@export var swing_end_frac: float   = 0.75

@export var grab_start_frac: float = 0.5
@export var grab_end_frac: float   = 0.9

## How long the grab QTE window lasts (seconds).
@export var qte_duration: float     = 2.5
## Mouse shakes needed to escape the grab.
@export var qte_shakes_needed: int  = 5

# ---- Phase enum ----
enum Phase { ATTACK, GRAB_REACHING, GRAB_HOLDING, GRAB_RESOLVING, DONE }

var _phase: Phase         = Phase.DONE
var _timer: float         = 0.0
var _anim_duration: float = 1.2
var _damage_dealt: bool   = false
var _hitboxes_active: bool = false
var _grab_made_contact: bool = false
var _qte_hud              = null  # GrabQteHud instance (untyped to avoid preload)

# Cached hand Area3D refs.
var _hand_left:  Area3D = null
var _hand_right: Area3D = null

# Path prefix for the new "All zombie fix" model sub-scene.
const _MODEL := "\"All zombie fix\""

func enter() -> void:
	_timer          = 0.0
	_damage_dealt   = false
	_hitboxes_active = false
	_grab_made_contact = false
	_qte_hud        = null

	_cache_hand_hitboxes()
	_set_hand_hitboxes(false)

	if randf() < grab_chance:
		_start_grab_reach()
	else:
		_start_attack()

func exit() -> void:
	_set_hand_hitboxes(false)
	_dismiss_qte()
	_disconnect_anim_finished()

func physics_update(delta: float) -> void:
	_timer += delta
	match _phase:
		Phase.ATTACK:
			_tick_attack()
		Phase.GRAB_REACHING:
			_tick_grab_reach()
		Phase.GRAB_HOLDING:
			pass  # QTE drives resolution via signals; nothing to poll here
		Phase.GRAB_RESOLVING:
			# Wait for the outro animation to finish (handled via signal).
			pass
		Phase.DONE:
			pass

func handle_hit(hit_data: Dictionary) -> String:
	# Can still be staggered during a standard attack swing.
	if _phase == Phase.ATTACK:
		var zone: String = hit_data.get("hit_zone", "body")
		match zone:
			"head", "foot":
				return "StateTakedownable"
	# During grab phases the zombie is committed and absorbs hits.
	return ""

# =========================================================
# Attack sub-flow
# =========================================================

func _start_attack() -> void:
	_phase = Phase.ATTACK
	for hand in [_hand_left, _hand_right]:
		if hand and hand is AttackHitbox:
			hand.attack_type = "attack"
	var anim: String = ZombieAnims.random_attack()
	_force_anim(anim)
	_anim_duration = _anim_length(anim)
	print("[StateAttack] Attack: %s (%.2fs)" % [anim, _anim_duration])

func _tick_attack() -> void:
	_update_hitbox_window()
	# Deal damage once when a hand overlaps the player during the swing window.
	if (_hitboxes_active and not _damage_dealt) and _hand_touches_player():
		print("Player attacked!")
		_damage_dealt = true
		_deal_damage(attack_damage, "attack")
	if _timer >= _anim_duration:
		_finish()

# =========================================================
# Grab sub-flow
# =========================================================

func _start_grab_reach() -> void:
	_phase = Phase.GRAB_REACHING
	_force_anim(ZombieAnims.GRAB_REACH)
	for hand in [_hand_left, _hand_right]:
		if hand and hand is AttackHitbox:
			hand.attack_type = "grab"
	_anim_duration = _anim_length(ZombieAnims.GRAB_REACH)
	# Enable hands during the reach so contact can be detected.

	print("[StateAttack] Grab: reaching (%.2fs)" % _anim_duration)

func _tick_grab_reach() -> void:
	_update_grab_window()

	# Only allow grab if window is active
	if _hitboxes_active and not _grab_made_contact and _hand_touches_player():
		_grab_made_contact = true
		print("[StateAttack] Grab: contact — entering QTE hold")
		_set_hand_hitboxes(false)
		_start_grab_hold()
		return

	if _timer >= _anim_duration:
		print("[StateAttack] Grab: whiffed — returning to Hunt")
		_finish()

func _start_grab_hold() -> void:
	_phase = Phase.GRAB_HOLDING
	_force_anim(ZombieAnims.GRAB_HOLD)

	# Spawn the QTE HUD.
	var hud_script = load("res://scripts/ui/grab_qte_hud.gd")
	_qte_hud = hud_script.new(qte_duration, qte_shakes_needed)
	_qte_hud.escaped.connect(_on_qte_escaped)
	_qte_hud.caught.connect(_on_qte_caught)
	enemy.get_tree().root.add_child(_qte_hud)

func _on_qte_escaped() -> void:
	# Player shook free — play fail anim, no damage.
	print("[StateAttack] Grab: player ESCAPED")
	_qte_hud = null  # HUD will free itself
	_phase = Phase.GRAB_RESOLVING
	_force_anim(ZombieAnims.GRAB_FAIL)
	_anim_duration = _anim_length(ZombieAnims.GRAB_FAIL)
	_timer = 0.0
	_connect_anim_finished()

func _on_qte_caught() -> void:
	# Player failed the QTE — deal damage, play success anim.
	print("[StateAttack] Grab: player CAUGHT — %d damage" % grab_damage)
	_qte_hud = null
	_deal_damage(grab_damage, "grab")
	_phase = Phase.GRAB_RESOLVING
	_force_anim(ZombieAnims.GRAB_SUCCESS)
	_anim_duration = _anim_length(ZombieAnims.GRAB_SUCCESS)
	_timer = 0.0
	_connect_anim_finished()

func _on_anim_finished(_anim_name: StringName) -> void:
	_finish()

# =========================================================
# Shared helpers
# =========================================================

func _finish() -> void:
	_phase = Phase.DONE
	_set_hand_hitboxes(false)
	_dismiss_qte()
	state_machine.transition_to("StateHunt")

func _update_hitbox_window() -> void:
	var frac: float = _timer / max(_anim_duration, 0.01)
	var should: bool = frac >= swing_start_frac and frac <= swing_end_frac
	if should != _hitboxes_active:
		_hitboxes_active = should
		_set_hand_hitboxes(_hitboxes_active)

func _update_grab_window() -> void:
	var frac: float = _timer / max(_anim_duration, 0.01)
	var should: bool = frac >= grab_start_frac and frac <= grab_end_frac

	if should != _hitboxes_active:
		_hitboxes_active = should
		_set_hand_hitboxes(_hitboxes_active)

func _cache_hand_hitboxes() -> void:
	var base := "ZombieModel/rig_001/Skeleton3D"
	_hand_left  = enemy.get_node_or_null("%s/HitboxAttachLeftHand/AttackHitbox" % base)
	_hand_right = enemy.get_node_or_null("%s/HitboxAttachRightHand/AttackHitbox" % base)
	if not _hand_left:
		push_warning("[StateAttack] AttackHitbox not found on left hand")
	if not _hand_right:
		push_warning("[StateAttack] AttackHitbox not found on right hand")

	# Configure layers so hand hitboxes can overlap player hitbox areas.
	# Layer 5 (bit 4, value 16): enemy attack hitboxes.
	# Layer 4 (bit 3, value 8): player hitboxes.
	# AttackHitbox must:
	#   - be on layer 5 so it's monitorable by anything scanning layer 5
	#   - scan layer 4 (collision_mask includes layer 4) to find player hitboxes
	#   - have monitorable=true so player hitbox areas can see it via area_entered
	for hand in [_hand_left, _hand_right]:
		if not hand:
			continue
		hand.collision_layer = 16  # layer 5
		hand.collision_mask  = 8   # layer 4
		hand.monitorable     = true
		hand.monitoring      = false  # starts disabled; _set_hand_hitboxes enables it
		if not hand.is_in_group("enemy_attack"):
			hand.add_to_group("enemy_attack")


func _set_hand_hitboxes(enabled: bool) -> void:
	if _hand_left:
		_hand_left.monitoring  = enabled
		_hand_left.monitorable = enabled
	if _hand_right:
		_hand_right.monitoring  = enabled
		_hand_right.monitorable = enabled

func _hand_touches_player() -> bool:
	for hitbox in [_hand_left, _hand_right]:
		if not (hitbox and hitbox.monitoring):
			continue
		# Check overlapping areas — player hitboxes are Area3D, not bodies.
		for area in hitbox.get_overlapping_areas():
			if area.is_in_group("player_hitbox"):
				print("Player found!")
				return true
	return false

func _deal_damage(amount: int, source: String) -> void:
	var player := _get_player()
	if player and player.has_method("take_damage"):
		player.take_damage(amount)
	print("[StateAttack] %s dealt %d damage" % [source, amount])

func _get_player() -> Node3D:
	var players: Array = enemy.get_tree().get_nodes_in_group("player")
	return players[0] as Node3D if players.size() > 0 else null

func _anim_length(anim_name: String) -> float:
	#if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim_name):
		#return enemy.anim_player.get_animation(anim_name).length
	return 1.5  # safe fallback

func _connect_anim_finished() -> void:
	if enemy and enemy.anim_player:
		var ap: AnimationPlayer = enemy.anim_player
		if not ap.animation_finished.is_connected(_on_anim_finished):
			ap.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func _disconnect_anim_finished() -> void:
	if enemy and enemy.anim_player:
		var ap: AnimationPlayer = enemy.anim_player
		if ap.animation_finished.is_connected(_on_anim_finished):
			ap.animation_finished.disconnect(_on_anim_finished)

func _dismiss_qte() -> void:
	if _qte_hud and is_instance_valid(_qte_hud):
		_qte_hud.queue_free()
	_qte_hud = null
