shader_type canvas_item;

uniform float deform : hint_range(0.0, 1.0, 0.001);

void fragment() {
	COLOR.a *= texture(TEXTURE, UV + cos(TIME * 3.0 + (UV.x + UV.y) * 100.0) * deform).a;
}