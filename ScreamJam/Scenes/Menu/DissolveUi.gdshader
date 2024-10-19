shader_type canvas_item;
render_mode blend_mix;
render_mode unshaded;

uniform sampler2D noise;
uniform float dissolveFactor = 1.0;
uniform float scrollSpeed = 1.0;
uniform float alphaThreshold : hint_range(0.0, 1.0);
uniform float borderSize : hint_range(0.0, 1.0) = 0.1;
uniform float borderStrength : hint_range(0.0, 1.0) = 0.05;
uniform float xTranslate = 1.0;
uniform vec4 frontColor : source_color;
uniform vec4 backColor : source_color;

void fragment() {
	COLOR = frontColor;
	vec2 scroll =  mod(UV + vec2(TIME * scrollSpeed, 0.0), 1.0);
	float alpha = log(UV.x + xTranslate) / dissolveFactor + texture(noise, scroll).r;
	if(alpha < alphaThreshold + borderSize)
	{
		COLOR.rgb = COLOR.rgb + vec3(borderStrength,borderStrength,borderStrength);
	}
	if(alpha < alphaThreshold)
	{
		COLOR = backColor;
	}
}