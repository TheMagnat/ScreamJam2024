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

uniform float transition;
uniform sampler2D screen: hint_screen_texture, repeat_enable;

void fragment() {
	//COLOR.rgb = frontColor.rgb;
	//vec2 scroll =  mod(UV + vec2(TIME * scrollSpeed, 0.0), 1.0);
	//float alpha = log(UV.x + xTranslate) / dissolveFactor + texture(noise, scroll).r;
	//if(alpha < alphaThreshold + borderSize)
	//{
		//COLOR.rgb = COLOR.rgb + vec3(borderStrength,borderStrength,borderStrength);
	//}
	//if(alpha < alphaThreshold)
	//{
		//COLOR.rgb = backColor.rgb;
	//}
	
	
	vec2 factor = vec2(20.0, 13.0) * (1.0 + transition * 100.0);
	vec2 id = floor(UV * factor) / factor;
	
	// Cool 1
	vec3 menuBackground = texture(screen, vec2(UV.x + tan((id.y * 154.4147) + TIME) * 0.01 , UV.y + tan((id.x * 154.4147) + TIME) * 0.01 )).rgb * (1.0 - transition * 0.35);
	
	// Cool 2
	//vec3 menuBackground = texture(screen, vec2(UV.x + cos((id.y * 154.4147) + TIME) * 0.01 , UV.y + sin((id.x * 154.4147) + TIME) * 0.01 )).rgb;

	
	vec3 normalBackground = texture(screen, UV).rgb;
	COLOR.rgb = menuBackground;
	COLOR.a = 1.0;
	//COLOR.rgb = mix(normalBackground, menuBackground, transition);

}