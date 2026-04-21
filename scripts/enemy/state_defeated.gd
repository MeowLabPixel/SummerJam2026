## STATE: Defeated
## HP has reached 0. Enemy is out of the fight.
## Plays defeated animation on loop.

class_name StateDefeated
extends EnemyState

## Whether the player is currently aiming at this enemy.
## Set externally by the player's aim/raycasting system.
var player_is_aiming: bool = false

var _was_aiming: bool = false

func enter() -> void:
	player_is_aiming = false
	_was_aiming = false
	print("[StateDefeated] Enemy defeated!")
	_play_anim(ZombieAnims.IDLE)  # Placeholder — swap for a real defeated-collapse anim when available.

func exit() -> void:
	pass  # Defeated is a terminal state — should never exit normally.

func physics_update(_delta: float) -> void:
	if player_is_aiming and not _was_aiming:
		_was_aiming = true
		print("[StateDefeated]")
	elif not player_is_aiming and _was_aiming:
		_was_aiming = false
		# TODO: return to defeated idle animation.

## Defeated enemies cannot be hit further.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""

## Call from the player's aiming/raycasting system each frame.
func set_aimed_at(aimed: bool) -> void:
	player_is_aiming = aimed
