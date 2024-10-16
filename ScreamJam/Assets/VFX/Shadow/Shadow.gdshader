shader_type canvas_item;

uniform vec4 color : source_color;
uniform sampler2D noise : repeat_enable;

uniform float timeScale = 1.0;

// This scale UV to aspect ratio and to texture size for example
uniform vec2 uvScaler = vec2(1.0);

uniform float direction = 1.0;
uniform float timeDirection = 1.0;

void fragment() {
	
	vec2 target = vec2(1.0, 0.5) * uvScaler;
	
	vec2 uv = UV * uvScaler;
	
	float timeScaled = TIME * timeScale;
	
	//float dist = distance(uv, target) * 1.0;
	float dist = distance(uv.x, uvScaler.x * direction);
	
	float noiseValue = texture(noise, uv + vec2(timeDirection, 0.0) * timeScaled).r;
	
	
	//COLOR.rgb = vec3(float(noiseValue), 0.0, 0.0);
	COLOR = color;
	
	float finalNoiseValue = 1.0 - pow(noiseValue, 2.5);
	COLOR.a *= step(finalNoiseValue, dist);
	
	if (dist < finalNoiseValue) {
		COLOR.rgb = vec3(1.0);
		COLOR.a += 0.25 - abs(finalNoiseValue - dist) * 2.0;
	}
	
}
