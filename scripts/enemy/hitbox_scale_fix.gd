## Resets scale to uniform (1,1,1) every physics frame.
## Attached to hitbox Area3D nodes whose BoneAttachment3D parents inherit
## non-uniform scale from Blender's armature export, causing Jolt Physics errors.
extends Area3D

func _physics_process(_delta: float) -> void:
	if global_basis.get_scale().is_equal_approx(Vector3.ONE):
		return
	var t := global_transform
	t.basis = t.basis.orthonormalized()
	global_transform = t
