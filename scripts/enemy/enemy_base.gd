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

# ─── References ────────────────────────────────────────────────────────────
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine

# ─── Ready ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	current_hp = MAX_HP
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

# ─── Debug ─────────────────────────────────────────────────────────────────
func _on_state_changed(old_state: String, new_state: String) -> void:
	print("[EnemyBase] State: %s → %s  |  HP: %d/%d" % [old_state, new_state, current_hp, MAX_HP])
