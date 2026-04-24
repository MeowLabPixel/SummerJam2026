class_name StateAttack
extends EnemyState

@export var grab_chance: float      = 0.25
@export var grab_damage: int        = 12
@export var attack_damage: int      = 6
@export var swing_start_frac: float = 0.5
@export var swing_end_frac: float   = 0.75
@export var grab_start_frac: float  = 0.5
@export var grab_end_frac: float    = 0.9
@export var qte_duration: float     = 2.5
@export var qte_shakes_needed: int  = 5

enum Phase { ATTACK, GRAB_REACHING, GRAB_HOLDING, GRAB_RESOLVING, DONE }

var _phase: Phase          = Phase.DONE
var _timer: float          = 0.0
var _anim_duration: float  = 1.5
var _damage_dealt: bool    = false
var _hitboxes_active: bool = false
var _grab_made_contact: bool = false
var _go_knockdown_after_anim := false
var _qte_hud               = null
var _hand_left:  Area3D    = null
var _hand_right: Area3D    = null

func enter() -> void:
	_timer             = 0.0
	_damage_dealt      = false
	_hitboxes_active   = false
	_grab_made_contact = false
	_qte_hud           = null

	_cache_hand_hitboxes()
	_set_hand_hitboxes(false)

	var player := _get_player()
	if player and player.is_grab:
		_start_attack()
	elif randf() < grab_chance:
		_start_grab_reach()
	else:
		_start_attack()

func exit() -> void:
	_set_hand_hitboxes(false)
	_dismiss_qte()
	_disconnect_anim_finished()
	# Disconnect hand signals
	for hand in [_hand_left, _hand_right]:
		if hand and hand.area_entered.is_connected(_on_hand_area_entered):
			hand.area_entered.disconnect(_on_hand_area_entered)

func physics_update(delta: float) -> void:
	_timer += delta
	match _phase:
		Phase.ATTACK:         _tick_attack()
		Phase.GRAB_REACHING:  _tick_grab_reach()
		Phase.GRAB_HOLDING:   pass
		Phase.GRAB_RESOLVING: pass
		Phase.DONE:           pass

func handle_hit(hit_data: Dictionary) -> String:
	if _phase == Phase.ATTACK:
		match hit_data.get("hit_zone", "body"):
			"head", "foot":
				return "StateTakedownable"
	return ""

# ── Attack ────────────────────────────────────────────────────────────────

func _start_attack() -> void:
	_phase = Phase.ATTACK
	for hand in [_hand_left, _hand_right]:
		if hand and hand is AttackHitbox:
			hand.attack_type = "attack"
	var anim: String = enemy.anim_set.random_attack()
	_force_anim(anim)
	#_anim_duration = _anim_length(anim)
	print("[StateAttack] Attack: %s (%.2fs)" % [anim, _anim_duration])

func _tick_attack() -> void:
	_update_hitbox_window()
	if _timer >= _anim_duration:
		_finish()


# ── Grab ──────────────────────────────────────────────────────────────────

func _start_grab_reach() -> void:
	_phase = Phase.GRAB_REACHING
	_force_anim(enemy.anim_set.grab_reach)
	for hand in [_hand_left, _hand_right]:
		if hand and hand is AttackHitbox:
			hand.attack_type = "grab"
	#_anim_duration = _anim_length(enemy.anim_set.grab_reach)
	print("[StateAttack] Grab: reaching (%.2fs)" % _anim_duration)



func _tick_grab_reach() -> void:
	_update_grab_window()
	if _timer >= _anim_duration and not _grab_made_contact:
		print("[StateAttack] Grab: whiffed")
		_finish()

func _start_grab_hold() -> void:
	_phase = Phase.GRAB_HOLDING
	_force_anim(enemy.anim_set.grab_hold)
	var hud_script = load("res://scripts/ui/grab_qte_hud.gd")
	_qte_hud = hud_script.new(qte_duration, qte_shakes_needed)
	_qte_hud.escaped.connect(_on_qte_escaped)
	_qte_hud.caught.connect(_on_qte_caught)
	enemy.get_tree().root.add_child(_qte_hud)

func _on_qte_escaped() -> void:
	print("[StateAttack] Grab: player ESCAPED")
	var player := _get_player()
	var sm = player.get_node("Statemachine")
	if sm:
		var grab_state = sm.get_node_or_null("Grab")
		if grab_state:
			grab_state.resolve_grab(false)
	_qte_hud = null
	_phase = Phase.GRAB_RESOLVING
	_go_knockdown_after_anim = true
	_force_anim(enemy.anim_set.grab_fail)
	_timer = 0.0
	_connect_anim_finished()

func _on_qte_caught() -> void:
	print("[StateAttack] Grab: player CAUGHT — %d damage" % grab_damage)
	_go_knockdown_after_anim = false
	var player := _get_player()
	var sm = player.get_node("Statemachine")
	if sm:
		var grab_state = sm.get_node_or_null("Grab")
		if grab_state:
			grab_state.resolve_grab(true)
	_qte_hud = null
	_deal_damage(grab_damage, "grab")
	_phase = Phase.GRAB_RESOLVING
	_force_anim(enemy.anim_set.grab_success)
	#_anim_duration = _anim_length(enemy.anim_set.grab_success)
	_timer = 0.0
	_connect_anim_finished()

func _on_anim_finished(_anim_name: StringName) -> void:
	if _go_knockdown_after_anim:
		var knockdown = state_machine._states.get("StateKnockdown")
		if knockdown:
			knockdown.skip_act3 = true
		state_machine.transition_to("StateKnockdown")
	else:
		_finish()

# ── Shared helpers ────────────────────────────────────────────────────────

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
	for skel_base in ["ZombieModel/rig_001/Skeleton3D", "ZombieModel/rig/Skeleton3D", "ZombieModel/rig_002/Skeleton3D"]:
		var l := enemy.get_node_or_null("%s/HitboxAttachLeftHand/AttackHitbox" % skel_base)
		var r := enemy.get_node_or_null("%s/HitboxAttachRightHand/AttackHitbox" % skel_base)
		if l or r:
			_hand_left  = l
			_hand_right = r
			break
	if not _hand_left:
		push_warning("[StateAttack] AttackHitbox not found on left hand")
	if not _hand_right:
		push_warning("[StateAttack] AttackHitbox not found on right hand")
	for hand in [_hand_left, _hand_right]:
		if not hand:
			continue
		hand.collision_layer = 16
		hand.collision_mask  = 8
		hand.monitorable     = true
		hand.monitoring      = false
		if not hand.is_in_group("enemy_attack"):
			hand.add_to_group("enemy_attack")
		# Connect signal instead of polling
		if not hand.area_entered.is_connected(_on_hand_area_entered):
			hand.area_entered.connect(_on_hand_area_entered)

func _on_hand_area_entered(area: Area3D) -> void:
	if not area.is_in_group("player_hitbox"):
		return
	match _phase:
		Phase.ATTACK:
			if _hitboxes_active and not _damage_dealt:
				print("[StateAttack] Signal hit — player attacked!")
				_damage_dealt = true
				_deal_damage(attack_damage, "attack")
		Phase.GRAB_REACHING:
			if _hitboxes_active and not _grab_made_contact:
				var player := _get_player()
				if player and player.is_grab:
					print("[StateAttack] Grab blocked — player already grabbed")
					_finish()
					return
				print("[StateAttack] Signal hit — grab contact!")
				_grab_made_contact = true
				_set_hand_hitboxes(false)
				_start_grab_hold()

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
		for area in hitbox.get_overlapping_areas():
			if area.is_in_group("player_hitbox"):
				return true
	return false

func _deal_damage(amount: int, source: String) -> void:
	var player := _get_player()
	if player and player.has_method("take_damage"):
		player.take_damage(amount)
	print("[StateAttack] %s dealt %d damage" % [source, amount])

func _anim_length(anim_name: String) -> float:
	if enemy and enemy.anim_player and enemy.anim_player.has_animation(anim_name):
		return enemy.anim_player.get_animation(anim_name).length
	return 1.5

func _get_player() -> Node3D:
	var players: Array = enemy.get_tree().get_nodes_in_group("player")
	return players[0] as Node3D if players.size() > 0 else null

func _connect_anim_finished() -> void:
	if enemy and enemy.anim_player:
		if not enemy.anim_player.animation_finished.is_connected(_on_anim_finished):
			enemy.anim_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func _disconnect_anim_finished() -> void:
	if enemy and enemy.anim_player:
		if enemy.anim_player.animation_finished.is_connected(_on_anim_finished):
			enemy.anim_player.animation_finished.disconnect(_on_anim_finished)

func _dismiss_qte() -> void:
	if _qte_hud and is_instance_valid(_qte_hud):
		_qte_hud.queue_free()
	_qte_hud = null
