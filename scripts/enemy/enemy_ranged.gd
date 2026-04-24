class_name EnemyRanged
extends EnemyBase

@export var shoot_interval: float = 2.0
@export var shoot_range: float = 10.0
@export var projectile_scene: PackedScene
@export var shoot_point: Node3D

var _shoot_timer: float = 0.0

func _ready() -> void:
	super._ready()
	# Override the state machine start to use ranged states
	state_machine.initialize("StateIdle")
