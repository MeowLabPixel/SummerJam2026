shader_type spatial;

uniform vec3 color: source_color;

// Cel shader
void light() {
	float diffuse_intensity = dot(NORMAL, LIGHT) > 0.5 ? 1.0 : 0.0;
	DIFFUSE_LIGHT = diffuse_intensity == 0.0 ? color / 2.0 : color;
	
	float specular_intensity = dot(NORMAL, LIGHT) > 0.990 ? 1.0 : 0.0;
	SPECULAR_LIGHT = color * 2.0 * specular_intensity;
	
	float rim_dot_product = 1.0 - dot(VIEW, NORMAL);
	float rim_intensity = pow(smoothstep(0.0, 2.0, rim_dot_product) * 2.0, 4);
	DIFFUSE_LIGHT += rim_intensity;
}