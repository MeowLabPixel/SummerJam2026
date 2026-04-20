var shader_mat = ShaderMaterial.new()
shader_mat.shader = preload("res://your_shader.gdshader")

var mesh_instance = $YourMeshInstance3D
for i in mesh_instance.get_surface_override_material_count():
	mesh_instance.set_surface_override_material(i, shader_mat)
