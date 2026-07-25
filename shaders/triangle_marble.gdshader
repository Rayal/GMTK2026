shader_type canvas_item;

uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform float noise_scale = 0.005;
uniform float orbit_speed = 0.05;
uniform float orbit_radius = 4.0;
uniform float warp_strength = 0.4;
instance uniform vec4 color_a : source_color = vec4(0.42, 0.13, 0.55, 1.0);
instance uniform vec4 color_b : source_color = vec4(0.75, 0.45, 0.9, 1.0);
uniform float fill_alpha : hint_range(0.0, 1.0) = 0.35;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 base_uv = world_pos * noise_scale;
	float t = TIME * orbit_speed;

	// Sample the noise at points orbiting in a circle so the warp churns
	// in place instead of drifting off in one direction.
	vec2 warp_uv_x = base_uv + vec2(cos(t), sin(t)) * orbit_radius;
	vec2 warp_uv_y = base_uv + vec2(cos(t + 2.094), sin(t + 2.094)) * orbit_radius;
	float warp_x = texture(noise_tex, warp_uv_x).r;
	float warp_y = texture(noise_tex, warp_uv_y).r;

	vec2 warped_uv = base_uv + (vec2(warp_x, warp_y) - 0.5) * warp_strength;
	float n = texture(noise_tex, warped_uv).r;
	COLOR = vec4(mix(color_a.rgb, color_b.rgb, n), fill_alpha);
}
