class_name EnemyRanged
extends EnemyBase

func _ready() -> void:
	super._ready()
	var model := get_node_or_null("ZombieModel") as ZombieModel
	if not model:
		push_warning("[EnemyRanged] ZombieModel not found")
		return

	var ranged_state := get_node_or_null("EnemyStateMachine/StateRangedAttack")
	if not ranged_state:
		push_warning("[EnemyRanged] StateRangedAttack not found")
		return

	if model.gun_spawn_point:
		ranged_state.gun_spawn_point = model.gun_spawn_point
	if model.gun_model:
		ranged_state.gun_model = model.gun_model
