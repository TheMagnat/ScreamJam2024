shader_type spatial;

uniform sampler2D noise: repeat_enable;


void vertex() {
	VERTEX += NORMAL * texture(noise, UV + TIME * 0.2).r * 0.5;
}

void fragment() {

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
