## STATE: Wait
## Ashley holds position until ordered to follow again.
## Triggered by pressing the ashley_wait action (Z) while she is following.
## Pressing Z again returns her to AshleyStateFollow.
class_name AshleyStateWait
extends AshleyState

func enter() -> void:
	ashley.velocity = Vector3.ZERO
	print("[AshleyStateWait] Waiting.")
	_play_anim(AshleyAnims.IDLE)

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	# Keep her frozen in place.
	ashley.velocity = Vector3.ZERO
	ashley.move_and_slide()
