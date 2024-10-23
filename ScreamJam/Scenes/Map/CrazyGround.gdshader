shader_type spatial;

global uniform float sanity;
global uniform float wall_distort : hint_range(0.0, 0.9, 0.001);

uniform sampler2D noise;
uniform float sanityFactor = 3.0;

varying vec3 world_position;


void vertex() {

	float time = TIME * 0.005;

	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Cool
	vec2 uv = vec2(world_position.x + world_position.y, world_position.z) * 0.25;
	float noiseValue = texture(noise, uv + time).r;

	VERTEX += NORMAL * noiseValue * (0.1 + pow(sanity, 1.25) * sanityFactor);

	float randValue = texture(noise, vec2(world_position.x, world_position.z + world_position.y) + time).r;


	//VERTEX += randValue * sanity;

	// Cool 2
	//vec2 uv = vec2(world_position.x + world_position.y, world_position.z) * 0.005;
	//float noiseValue = texture(noise, uv + time).r;
	//VERTEX += NORMAL * noiseValue * 2.0;
}
