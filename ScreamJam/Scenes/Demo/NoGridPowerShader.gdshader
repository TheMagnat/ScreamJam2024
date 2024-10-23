shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D noise: repeat_enable;
uniform sampler2D screen: hint_screen_texture;

uniform float fadeOut = 0.0;

void vertex() {
	VERTEX += NORMAL * texture(noise, UV + TIME * 0.2).r * (0.5 + 0.5 * sin(TIME * 1.0));
}

void fragment() {
	float noiseValue = texture(noise, UV + TIME * 0.5).r;
	//ALBEDO = vec3(SCREEN_UV.x, SCREEN_UV.y, 0.0);
	ALBEDO = mix(texture(screen, SCREEN_UV + noiseValue * 0.05).rgb, vec3(cos(VERTEX.x + TIME * 1.125) * 0.1, 0.0, sin(VERTEX.y + TIME * 0.875) * 0.1), 0.4);
	
	float inverseFadeOut = 1.0 - fadeOut;
	ALPHA = step(noiseValue, inverseFadeOut);
}
