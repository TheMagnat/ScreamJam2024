shader_type spatial;

uniform sampler2D noise;

void vertex() {

	VERTEX += NORMAL * texture(noise, UV + TIME).r * 0.025;
}

void fragment() {
	ALBEDO = COLOR.rgb;
	//ALPHA = COLOR.a;
	ALPHA = 0.5 * COLOR.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
