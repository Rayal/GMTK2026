shader_type canvas_item;

uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform vec2 scroll_speed = vec2(0.03, 0.02);
uniform float noise_scale = 0.005;
uniform vec4 color_a : source_color = vec4(0.42, 0.13, 0.55, 1.0);
uniform vec4 color_b : source_color = vec4(0.75, 0.45, 0.9, 1.0);
uniform float fill_alpha : hint_range(0.0, 1.0) = 0.35;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 uv = world_pos * noise_scale + TIME * scroll_speed;
	float n = texture(noise_tex, uv).r;
	COLOR = vec4(mix(color_a.rgb, color_b.rgb, n), fill_alpha);
}
