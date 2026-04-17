## AshleyBase: root script for the Ashley follower character.
## Handles the state machine, threat tracking, and exposes helpers to states.
class_name AshleyBase
extends CharacterBody3D

# ─── Signals ───────────────────────────────────────────────────────────────
signal threat_entered()
signal threat_cleared()

# ─── References ────────────────────────────────────────────────────────────
@onready var state_machine: AshleyStateMachine = $AshleyStateMachine
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var threat_area: Area3D = $ThreatArea
@onready var help_label: Label3D = $HelpLabel

# ─── Threat tracking ───────────────────────────────────────────────────────
## All CharacterBody3D nodes (enemies) currently inside the threat radius.
var nearby_threats: Array = []

## Set by AshleyStateFollow when Ashley is stuck against the follow radius.
## ashley_base reads this each frame to show/hide the help label.
var is_cornered: bool = false:
	set(value):
		if value == is_cornered:
			return
		is_cornered = value
		# help_label is @onready — only safe to touch after _ready() has run.
		if is_node_ready() and help_label:
			help_label.visible = value

func _ready() -> void:
	help_label.visible = false  # Guarantee hidden at start regardless of exported default.
	threat_area.body_entered.connect(_on_threat_entered)
	threat_area.body_exited.connect(_on_threat_exited)
	state_machine.initialize("AshleyStateFollow")
	state_machine.state_changed.connect(_on_state_changed)

# ─── Threat sensor callbacks ───────────────────────────────────────────────
func _on_threat_entered(body: Node3D) -> void:
	# Only track CharacterBody3D nodes that aren't Ashley herself.
	if body == self:
		return
	if body is CharacterBody3D and body not in nearby_threats:
		nearby_threats.append(body)
		print("[Ashley] Threat entered: %s  (total: %d)" % [body.name, nearby_threats.size()])
		threat_entered.emit()

func _on_threat_exited(body: Node3D) -> void:
	if nearby_threats.has(body):
		nearby_threats.erase(body)
		print("[Ashley] Threat left: %s  (remaining: %d)" % [body.name, nearby_threats.size()])
		if nearby_threats.is_empty():
			is_cornered = false
			threat_cleared.emit()

# ─── Helpers for states ────────────────────────────────────────────────────

## Returns the world-space follow target (mouse position placeholder).
func get_follow_target() -> Vector3:
	if has_meta("target_position"):
		return get_meta("target_position")
	return global_position

## Returns the nearest threat position, or Vector3.ZERO if none.
func get_nearest_threat_position() -> Vector3:
	if nearby_threats.is_empty():
		return Vector3.ZERO
	var nearest: Node3D = nearby_threats[0]
	var nearest_dist: float = global_position.distance_to(nearest.global_position)
	for body in nearby_threats:
		var d: float = global_position.distance_to(body.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = body
	return nearest.global_position

## True while the TestWorld controller is actively shooting.
func is_player_shooting() -> bool:
	return get_meta("player_shooting", false)

# ─── Debug ─────────────────────────────────────────────────────────────────
func _on_state_changed(old_state: String, new_state: String) -> void:
	print("[Ashley] State: %s → %s" % [old_state, new_state])
