## EnemyBase: root script for a Songkran Hazard 4 enemy (zombie).
## Handles HP, the second-chance mechanic, hit registration,
## and boots the state machine.
class_name EnemyBase
extends CharacterBody3D

# ─── Signals ───────────────────────────────────────────────────────────────
signal health_changed(current_hp: int, max_hp: int)
signal enemy_defeated()
signal enemy_hit(hit_data: Dictionary)

# ─── HP Constants ──────────────────────────────────────────────────────────
const MAX_HP: int = 40

# ─── State ─────────────────────────────────────────────────────────────────
var current_hp: int = MAX_HP
var _second_chance_used: bool = false   # Can only trigger once per life.
var is_defeated: bool = false

# ─── Drop Table ────────────────────────────────────────────────────────────
## Each entry is a Dictionary with keys:
##   item_type : String  — matches ItemPickup.item_type ("coin", "health", etc.)
##   value     : int     — worth of each individual pickup spawned
##   count_min : int     — minimum number of pickups dropped
##   count_max : int     — maximum number of pickups dropped
## Example default: drop 2–4 coins worth 1 each.
@export var drop_table: Array[Dictionary] = [
	{"item_type": "coin", "value": 1, "count_min": 2, "count_max": 4}
]

# ─── References ────────────────────────────────────────────────────────────
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine
var anim_player: AnimationPlayer = null

## Finds the AnimationPlayer that actually contains the gameplay animations.
## The GLB may place multiple AnimationPlayers under ZombieModel — the correct
## one has more than just the rest-pose "Base" track.
func _find_anim_player() -> AnimationPlayer:
	# Try both the old model name and the new one so this works during transition.
	var model_names := ["All zombie fix", "ZombieModel"]
	for model_name in model_names:
		var model := get_node_or_null(model_name)
		if not model:
			continue
		# Prefer a direct AnimationPlayer child that has gameplay animations (>1 clip).
		for child in model.get_children():
			if child is AnimationPlayer:
				var ap := child as AnimationPlayer
				if ap.get_animation_list().size() > 1:
					return ap
		# Fallback: any AnimationPlayer anywhere under this model node.
		var fallback := model.find_child("AnimationPlayer", true, false)
		if fallback:
			return fallback as AnimationPlayer
	return null

# ─── Ready ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	current_hp = MAX_HP
	anim_player = _find_anim_player()
	if not anim_player:
		push_error("[EnemyBase] No AnimationPlayer with gameplay animations found under ZombieModel")
	else:
		print("[EnemyBase] AnimationPlayer found at: %s (animations: %d)" % [anim_player.get_path(), anim_player.get_animation_list().size()])
		# Print every animation name so we can verify ZombieAnims constants match exactly.
		for anim_name in anim_player.get_animation_list():
			print("  [ANIM] '%s'" % anim_name)
	# Boot into Idle once the scene tree is fully built.
	state_machine.initialize("StateIdle")
	state_machine.state_changed.connect(_on_state_changed)

# ─── HP / Damage ───────────────────────────────────────────────────────────

## Main entry point for dealing damage to this enemy.
## hit_data keys:
##   "damage"   : int     — how much HP to remove
##   "hit_zone" : String  — "body" | "head" | "foot"
func take_hit(hit_data: Dictionary) -> void:
	if is_defeated:
		return
	print("[EnemyBase] take_hit — zone:'%s' dmg:%d state:%s hp:%d" % [
		hit_data.get("hit_zone", "?"),
		hit_data.get("damage", 0),
		state_machine.get_current_state_name(),
		current_hp
	])

	var dmg: int = hit_data.get("damage", 1)
	var new_hp: int = current_hp - dmg

	# ── Second-chance mechanic ───────────────────────────────────────────
	# If this hit would kill the enemy AND second chance hasn't fired yet,
	# clamp to 1 HP instead and mark it used.
	if new_hp <= 0 and not _second_chance_used:
		new_hp = 1
		_second_chance_used = true
		_on_second_chance_triggered()

	current_hp = clampi(new_hp, 0, MAX_HP)
	health_changed.emit(current_hp, MAX_HP)
	enemy_hit.emit(hit_data)

	# Forward hit to the state machine so the active state can react.
	state_machine.handle_hit(hit_data)

	if current_hp <= 0:
		_trigger_defeat()

## Called once when the second-chance fires.
## Hook this up to a visual/audio cue later.
func _on_second_chance_triggered() -> void:
	print("[EnemyBase] Second chance triggered! HP saved at 1.")
	# TODO: play a near-death stagger visual / audio effect.

func _trigger_defeat() -> void:
	is_defeated = true
	state_machine.transition_to("StateDefeated")
	enemy_defeated.emit()
	_spawn_drops()

## Spawns all drops defined in drop_table at the enemy's current position.
func _spawn_drops() -> void:
	var parent: Node = get_tree().current_scene
	for entry in drop_table:
		var item_type: String = entry.get("item_type", "coin")
		var value: int = entry.get("value", 1)
		var count_min: int = entry.get("count_min", 1)
		var count_max: int = entry.get("count_max", 1)
		var count: int = randi_range(count_min, count_max)
		print("[EnemyBase] Dropping %d x %s" % [count, item_type])
		for i in count:
			ItemPickup.instantiate_drop(parent, global_position, item_type, value)

# ─── Debug ─────────────────────────────────────────────────────────────────
func _on_state_changed(old_state: String, new_state: String) -> void:
	print("[EnemyBase] State: %s → %s  |  HP: %d/%d" % [old_state, new_state, current_hp, MAX_HP])
