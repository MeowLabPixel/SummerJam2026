extends Node3D
class_name ZombieModel

@export var gun_model: Node3D          # assign the gun mesh in inspector
@onready var balloon_spawn_point: Node3D = $rig_001/Skeleton3D/HitboxAttachRightHand/BalloonSpawnPoint
@onready var gun_spawn_point: Node3D = $rig_001/Skeleton3D/HitboxAttachRightHand/GunSpawnPoint
