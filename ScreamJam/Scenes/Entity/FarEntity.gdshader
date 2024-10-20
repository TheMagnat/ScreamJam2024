shader_type spatial;
render_mode fog_disabled;

uniform sampler2D tex;
uniform float dist;

global uniform float sanity;

void vertex() {
	// Billboard Mode: Y-Billboard
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			vec4(normalize(cross(vec3(0.0, 1.0, 0.0), MAIN_CAM_INV_VIEW_MATRIX[2].xyz)), 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(normalize(cross(MAIN_CAM_INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	
	VERTEX.z -= (1.0 - dist) * 3.0;
}

void fragment() {
	vec4 img = texture(tex, UV);
	ALBEDO = mix(img.rgb, vec3(1.0, 0.0, 0.0), sanity) * 1.5 * (1.0 + sanity * 25.0);
	ALPHA = img.a * dist;
	ALPHA_SCISSOR_THRESHOLD = 0.1;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
