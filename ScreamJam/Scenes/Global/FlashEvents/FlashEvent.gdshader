shader_type canvas_item;

// Screen Alterer
uniform sampler2D screen: hint_screen_texture;
uniform float inverseScreen = 0.0;
uniform bool gridInverse = false;

// Opaque color
uniform vec3 color: source_color;

// Blending between screen and color
uniform float alpha = 0.0;


float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float shouldInverseScreen = inverseScreen;
	if (gridInverse) {
		vec2 gridCell = floor(UV * 100.0);
		float gridId = gridCell.y * 100.0 + gridCell.x;
		
		float randomValue = random(vec2(gridId, 1.0));
		
		shouldInverseScreen = float(randomValue < 0.5);
	}
	
	vec2 screenUv = UV;
	screenUv.y = mix(screenUv.y, (1.0 - screenUv.y), shouldInverseScreen);
	
	COLOR = mix(texture(screen, screenUv), vec4(color, 1.0), alpha);
}
