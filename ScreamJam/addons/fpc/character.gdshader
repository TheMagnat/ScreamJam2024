shader_type canvas_item;

uniform sampler2D viewport : hint_screen_texture, repeat_disable, filter_linear;
uniform float distortion : hint_range(0.0, 0.6, 0.001);
uniform float blink : hint_range(0.0, 1.0, 0.001);
uniform float damage : hint_range(0.0, 1.0, 0.001);
uniform float tookPower : hint_range(0.0, 1.0, 0.001);

float crt(vec2 uv, float offset) {
	return 0.95 + (cos(uv.x * 1200.0 + offset) * 0.25 + cos(uv.y * 1000.0 + offset)) * 0.05;
}

vec4 distort(vec2 CENTER, float zoom, float distort) {
	vec2 c = CENTER * zoom * (1.0 - length(CENTER) * distort);
	return texture(viewport, vec2(0.5, 0.5) + c);
}

void fragment() {
	//float tookPower = sin(tookPower * PI);
	float real_distort = (tookPower * 2.0 + distortion + damage * 0.1);
	float LENS_DISTORT = real_distort * 0.9;
	float ZOOM = 1.0 - real_distort;

	// distortion/displacement
	vec2 CENTER = (SCREEN_UV - vec2(0.5));
	CENTER.x *= 1.0 + cos(UV.y * 2.0 + TIME * 0.25) * damage * 0.25;
	CENTER.x += cos(float(int(UV.y + TIME * 1015341.0))) * damage * 0.005;
	CENTER.y += cos(float(int(UV.x + TIME * 7486484.0))) * damage * 0.0005;
	COLOR = distort(CENTER, ZOOM, LENS_DISTORT);

	float dist = length(CENTER * 1.0);
	COLOR *= vec4(1.0 - dist) + distort(CENTER, ZOOM * 0.99, LENS_DISTORT) * dist;

	// blink
	vec2 c3 = vec2(CENTER.x * 0.5, CENTER.y);
	COLOR.rgb *= max(0.0, 1.0 - blink - length(c3 * blink * 4.0));

	// damage colors
	COLOR.rgb *= sqrt(1.0 - length(CENTER * 1.25));
	COLOR.r += cos(float(int(UV.y * 200.0 + TIME * 10000.0))) * damage * 0.05;
	COLOR.r *= 1.0 + length(CENTER) * damage * (1.0 + blink * 4.0);
	COLOR.gb *= 1.0 - length(CENTER * 0.25) * damage;
	COLOR.rgb *= 1.0 - length(CENTER * 0.5) * damage;
	COLOR.rgb *= mix(1.0, 0.6 + length(CENTER * 2.0), damage);
	//COLOR.rgb = vec3(1.0); //That's just for test purposes

	// CRT
	float dFact = damage * 10.0;
	COLOR.r *= crt(UV + sin(TIME * 41.0) * dFact, 0.0);
	COLOR.g *= crt(UV + cos(TIME * 0.005), 1.0);
	COLOR.b *= crt(UV + cos(TIME * 13.45131) * dFact, 2.0);
	
	COLOR.rgb = mix(COLOR.rgb, (1.0 - COLOR.rgb) * 0.5, tookPower);
}
