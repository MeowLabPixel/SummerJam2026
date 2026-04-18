## STATE: Defeated
## HP has reached 0. Enemy is out of the fight.
## Plays defeated animation on loop.
## If the player aims at the enemy, it waves to indicate
## it no longer wants to play Songkran (visual gag / mercy signal).
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
	_play_anim("rig|Duck")

func exit() -> void:
	pass  # Defeated is a terminal state — should never exit normally.

func physics_update(_delta: float) -> void:
	# React to being aimed at: play wave animation.
	if player_is_aiming and not _was_aiming:
		_was_aiming = true
		print("[StateDefeated]")
		# TODO: play wave animation (transition from defeated idle to wave).
	elif not player_is_aiming and _was_aiming:
		_was_aiming = false
		# TODO: return to defeated idle animation.

## Defeated enemies cannot be hit further.
func handle_hit(_hit_data: Dictionary) -> String:
	return ""

## Call from the player's aiming/raycasting system each frame.
func set_aimed_at(aimed: bool) -> void:
	player_is_aiming = aimed
