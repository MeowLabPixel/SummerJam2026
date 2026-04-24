shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, blend_mix;

// Enable depth texture for edge detection
uniform sampler2D depth_texture : hint_depth_texture, filter_linear, repeat_disable;

// Gerstner Wave: (amplitude, frequency, speed, phase)
uniform vec4 wave_0 = vec4(0.3, 2.0, 1.0, 0.0);
uniform vec4 wave_1 = vec4(0.2, 1.5, 0.8, 2.5);
uniform vec4 wave_2 = vec4(0.15, 1.0, 1.2, 5.0);
uniform vec4 wave_3 = vec4(0.1, 0.8, 0.6, 8.0);

// Noise control
uniform float noise_scale : hint_range(0.0, 10.0) = 1.0;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.3;

// PBR
uniform vec4 albedo : source_color = vec4(0.76, 0.94, 0.93, 0.8);
uniform float metallic : hint_range(0.0, 1.0) = 0.1;
uniform float roughness : hint_range(0.0, 1.0) = 0.3;

// Extra control
uniform float water_level : hint_range(-5.0, 5.0, 0.01) = 0.0;

// Edge foam
uniform float edge_threshold : hint_range(0.0, 2.0, 0.01) = 0.1;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec3 v_view_pos;
varying vec3 v_world_pos;

// Simple noise function
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for(int i = 0; i < 3; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

vec3 calculate_wave(vec3 position_ws, float amplitude, float frequency, float speed, float phase_offset) {
    float phase = TIME * speed + phase_offset;
    float wave_input = position_ws.x * 0.5 + position_ws.z * 0.3;
    float y = amplitude * sin(wave_input * frequency + phase);
    return vec3(0.0, y, 0.0);
}

vec3 view_pos_from_depth(vec2 uv, float depth_raw, mat4 inv_projection_matrix) {
    vec4 clip = vec4(uv * 2.0 - 1.0, depth_raw, 1.0);
    vec4 view_space = inv_projection_matrix * clip;
    return view_space.xyz / max(view_space.w, 0.00001);
}

void vertex() {
    vec3 pos = VERTEX;
    
    // Primary waves
    vec3 offset = vec3(0.0);
    offset += calculate_wave(pos, wave_0.x, wave_0.y, wave_0.z, wave_0.w);
    offset += calculate_wave(pos, wave_1.x, wave_1.y, wave_1.z, wave_1.w);
    offset += calculate_wave(pos, wave_2.x, wave_2.y, wave_2.z, wave_2.w);
    offset += calculate_wave(pos, wave_3.x, wave_3.y, wave_3.z, wave_3.w);
    
    // Add noise for irregularity
    float noise_val = fbm(pos.xz * noise_scale + TIME * 0.5);
    offset.y += noise_val * noise_strength * (wave_0.x + wave_1.x);
    
    // Apply displacement
    VERTEX = pos + offset + vec3(0.0, water_level, 0.0);
    v_view_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Calculate flat normal for low-poly look
    vec3 ddx = dFdx(v_view_pos);
    vec3 ddy = dFdy(v_view_pos);
    vec3 flat_normal_vs = normalize(cross(ddx, ddy));
    
    if (dot(flat_normal_vs, NORMAL) < 0.0) {
        flat_normal_vs = -flat_normal_vs;
    }
    
    // Edge detection using depth texture
    float scene_depth = texture(depth_texture, SCREEN_UV).r;
    vec3 scene_pos = view_pos_from_depth(SCREEN_UV, scene_depth, INV_PROJECTION_MATRIX);

    float water_depth = FRAGCOORD.z;
    vec3 water_pos = view_pos_from_depth(SCREEN_UV, water_depth, INV_PROJECTION_MATRIX);

    // Calculate depth difference
    float depth_diff = water_pos.z - scene_pos.z;

    // Create foam at edges
    float foam = 1.0 - smoothstep(0.0, edge_threshold, depth_diff);
    foam = pow(foam, edge_softness);

    // Mix albedo with foam color
    vec3 final_color = mix(albedo.rgb, foam_color.rgb, foam * foam_color.a);

    NORMAL = flat_normal_vs;
    ALBEDO = final_color;
    ALPHA = albedo.a;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = 0.5;
}