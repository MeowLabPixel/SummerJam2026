## Base class for all Enemy AI states.
## Each state extends this and overrides the relevant methods.
class_name EnemyState
extends Node

# Reference back to the enemy that owns this state machine.
# Set by EnemyStateMachine on ready.
var enemy = null  # CharacterBody3D — untyped to avoid circular dependency
var state_machine = null  # EnemyStateMachine — untyped to avoid circular dependency

## Called when this state becomes active.
func enter() -> void:
	pass

## Called when this state is exited.
func exit() -> void:
	pass

## Called every physics frame while this state is active.
func physics_update(_delta: float) -> void:
	pass

## Called every frame while this state is active.
func update(_delta: float) -> void:
	pass

## Called when the enemy takes a hit.
## hit_data: Dictionary with keys: damage, hit_zone (String: "body","head","foot")
## Return the name (String) of the state to transition to, or "" to stay in current state.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""

## Plays an animation, skipping only if it is actively mid-play right now.
## Uses is_playing() + current_animation so a finished one-shot can replay.
func _play_anim(anim_name: String) -> void:
	if not (enemy and enemy.anim_player):
		return
	var ap: AnimationPlayer = enemy.anim_player
	# Only skip if this exact animation is actively running (not just last played).
	if ap.is_playing() and ap.current_animation == anim_name:
		return
	ap.play(anim_name)

## Force-replays an animation even if it is currently mid-play.
## Use this for re-stun hits that must restart the flinch from frame 0.
func _force_anim(anim_name: String) -> void:
	if not (enemy and enemy.anim_player):
		return
	enemy.anim_player.play(anim_name)
