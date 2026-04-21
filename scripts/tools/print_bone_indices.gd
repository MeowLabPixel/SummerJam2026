## Temporary tool: prints bone names and indices from the zombie skeleton.
## Delete this file after getting the bone index list.
@tool
extends EditorScript

func _run() -> void:
	var scene: PackedScene = load("res://scenes/enemy/zombie_animated.tscn")
	if not scene:
		print("ERROR: Could not load zombie_animated.tscn")
		return
	var root: Node = scene.instantiate()
	var skeleton: Skeleton3D = root.get_node_or_null("rig/Skeleton3D")
	if not skeleton:
		print("ERROR: Could not find rig/Skeleton3D")
		root.queue_free()
		return
	print("=== Bone indices for rig/Skeleton3D ===")
	for i in skeleton.get_bone_count():
		print("  [%d] %s" % [i, skeleton.get_bone_name(i)])
	print("=== End bone list ===")
	root.queue_free()
