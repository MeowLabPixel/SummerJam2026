extends Node


func _enter_tree() -> void:
	get_tree().node_added.connect(func(node:Node):
		if node is GeometryInstance3D:
			node.add_to_group('to_appy_material')
	)
	
	
func change_material(material:Material) -> void:
	get_tree().set_group('to_appy_material', 'material_override', material)
