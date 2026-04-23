## STATE: Evade (retired)
## Avoidance is now handled directly inside AshleyStateFollow as additive steering.
## This state immediately redirects to Follow so any legacy calls don't strand Ashley.
class_name AshleyStateEvade
extends AshleyState

func enter() -> void:
	print("[AshleyStateEvade] Redirecting to Follow (avoidance is now inline).")
	state_machine.transition_to("AshleyStateFollow")

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
