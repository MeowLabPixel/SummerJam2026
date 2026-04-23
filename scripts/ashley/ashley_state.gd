## Base class for all Ashley AI states.
## Mirrors the EnemyState pattern — same lifecycle hooks, same untyped refs.
class_name AshleyState
extends Node

# Set by AshleyStateMachine on ready.
var ashley = null   # CharacterBody3D — untyped to avoid circular dependency
var state_machine = null  # AshleyStateMachine — untyped

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass

## Plays an animation only if it isn't already playing.
func _play_anim(anim_name: String) -> void:
	if ashley and ashley.anim_player and ashley.anim_player.current_animation != anim_name:
		ashley.anim_player.play(anim_name)
