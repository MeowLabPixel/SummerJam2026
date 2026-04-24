class_name EnemyBalloon
extends EnemyBase

func _ready() -> void:
	super._ready()
	var model := get_node_or_null("ZombieModel") as ZombieModel
	if not model:
		push_warning("[EnemyBalloon] ZombieModel not found")
		return

	var ranged_state := get_node_or_null("EnemyStateMachine/StateRangedAttack")
	if not ranged_state:
		push_warning("[EnemyBalloon] StateRangedAttack not found")
		return

	if model.balloon_spawn_point:
		ranged_state.balloon_spawn_point = model.balloon_spawn_point
