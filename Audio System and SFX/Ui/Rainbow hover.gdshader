shader_type canvas_item;

// Match glass shader corner settings exactly
uniform float corner_radius : hint_range(0.0, 1.0) = 1.0;
uniform float edge_smoothness : hint_range(0.5, 3.0) = 1.0;

// Rainbow effect
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Rounded box (exact copy from glass shader)
float rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void fragment() {
    // Exact same corner calculation as glass shader
    float dx = dFdx(UV.x);
    float dy = dFdy(UV.y);
    dx = sign(dx) * max(abs(dx), 0.0001);
    dy = sign(dy) * max(abs(dy), 0.0001);
    vec2 size = abs(vec2(1.0 / dx, 1.0 / dy));
    size = clamp(size, vec2(1.0), vec2(4096.0));
    vec2 half_size = size * 0.5;
    vec2 pixel = UV * size;
    vec2 centered = pixel - half_size;
    float max_r = min(half_size.x, half_size.y);
    float r = corner_radius * max_r;
    float sdf = rounded_box(centered, half_size, r);
    float alpha = 1.0 - smoothstep(-edge_smoothness, edge_smoothness, sdf);
    
    if (alpha < 0.001) {
        discard;
    }
    
    // Apply rainbow effect
    COLOR = texture(TEXTURE, UV);
    float hue = (UV.x + UV.y) * 0.25 + mod(TIME * 0.5, 1.0);
    COLOR.rgb *= hsv2rgb(vec3(hue, 0.6, 1.0));
    COLOR.a *= alpha;
}
