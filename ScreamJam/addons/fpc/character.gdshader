shader_type canvas_item;

uniform sampler2D viewport : hint_screen_texture, repeat_disable, filter_linear;
uniform float distortion : hint_range(0.0, 0.6, 0.001);
uniform float blink : hint_range(0.0, 1.0, 0.001);

float crt(vec2 uv, float offset) {
	return 0.95 + (cos(uv.x * 1200.0 + offset) * 0.25 + cos(uv.y * 1000.0 + offset)) * 0.05;
}

vec4 distort(vec2 CENTER, float zoom, float distort) {
	vec2 c = CENTER * zoom * (1.0 - length(CENTER) * distort);
	return texture(viewport, vec2(0.5, 0.5) + c);
}

void fragment() {
	float LENS_DISTORT = distortion * 0.9;
	float ZOOM = 1.0 - distortion;

	vec2 CENTER = (SCREEN_UV - vec2(0.5));
	COLOR = distort(CENTER, ZOOM, LENS_DISTORT);

	float dist = length(CENTER * 1.0);
	COLOR *= vec4(1.0 - dist) + distort(CENTER, ZOOM * 0.99, LENS_DISTORT) * dist;
	COLOR.rgb *= sqrt(1.0 - length(CENTER * 1.25));

	//COLOR.rgb = vec3(1.0); //That's just for test purposes
	vec2 c3 = vec2(CENTER.x * 0.5, CENTER.y);
	COLOR.rgb *= max(0.0, 1.0 - blink - length(c3 * blink * 4.0));

	COLOR.r *= crt(UV, 0.0);
	COLOR.g *= crt(UV + cos(TIME * 0.005), 1.0);
	COLOR.b *= crt(UV, 2.0);
}
