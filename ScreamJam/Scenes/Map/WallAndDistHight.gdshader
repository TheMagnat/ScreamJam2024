// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_heightmap : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform float heightmap_scale : hint_range(-16.0, 16.0, 0.001);
uniform int heightmap_min_layers : hint_range(1, 64);
uniform int heightmap_max_layers : hint_range(1, 64);
uniform vec2 heightmap_flip;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform sampler2D noise;
global uniform float wall_distort : hint_range(0.0, 0.9, 0.001);
global uniform float breathing : hint_range(0.0, 1.0, 0.001);
global uniform vec3 player_pos;

varying vec3 world_position;

float f(sampler2D n, float t, vec2 uv, float offset, float jitter) {
	float o = offset + jitter * (player_pos.x + player_pos.y + player_pos.z) * 0.005 * wall_distort;
	return texture(n, (1.0 + cos(vec2(o, 0.0) + vec2(0.0, t + float(int((t + o) * jitter)) * 0.25) * 0.005 + vec2(uv.x * 0.0625, 0.0))) * 0.5).r < uv.y * wall_distort ? wall_distort * 0.25 : 0.0;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	float time = TIME * breathing;

	{
		// Height: Enabled
		vec3 view_dir = normalize(normalize(-VERTEX + EYE_OFFSET) * mat3(TANGENT * heightmap_flip.x, -BINORMAL * heightmap_flip.y, NORMAL));

		// Height Deep Parallax: Enabled
		float num_layers = mix(float(heightmap_max_layers), float(heightmap_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
		float layer_depth = 1.0 / num_layers;
		float current_layer_depth = 0.0;
		// Breathing effect here with the "wall_distort" and cos(TIME)
		vec2 p = view_dir.xy * (heightmap_scale * (1.0 + cos(time * 2.0) * (0.02 + wall_distort * 0.98) * 6.0)) * 0.01;
		vec2 delta = p / num_layers;
		vec2 ofs = base_uv;
		float depth = 1.0 - texture(texture_heightmap, ofs).r;

		float current_depth = 0.0;
		while (current_depth < depth) {
			ofs -= delta;
			depth = 1.0 - texture(texture_heightmap, ofs).r;

			current_depth += layer_depth;
		}

		vec2 prev_ofs = ofs + delta;
		float after_depth = depth - current_depth;
		float before_depth = (1.0 - texture(texture_heightmap, prev_ofs).r) - current_depth + layer_depth;

		float weight = after_depth / (after_depth - before_depth);
		ofs = mix(ofs, prev_ofs, weight);
		base_uv = ofs;
	}

	// Rainy / Water effect
	float randValue = texture(noise, UV * 0.2 + vec2(sin(time) * 0.00001, -0.05) * time).r;
	float modifier = randValue * (0.075 + wall_distort * 0.9) * 0.05;
	vec2 vecModifier = vec2(0.0, 0.4) * modifier;
	base_uv += vecModifier;
	//base_uv += vec2(1.0, 0.0) * wall_distort * sin(TIME * 1.2145) * cos(TIME * 0.954) * 0.2;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb + vec3(1.0, 0.0, 0.0) * randValue * 0.0;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;

	// Ambient Occlusion: Enabled
	AO = dot(texture(texture_ambient_occlusion, base_uv), ao_texture_channel);
	AO_LIGHT_AFFECT = ao_light_affect;


	float oldAO = AO;
	//AO = mix(AO, (1.0 - AO), pow(wall_distort, 8.0)); // Color inversion
	AO = mix(AO, (1.0 - AO), smoothstep(0.6, 1.0, wall_distort));

	ALBEDO += ((1.0 - oldAO) * 10.0 * pow(wall_distort, 4.0)); // Flash White


	//vec3 redRes = vec3(1.0, 0.03138, 0.03138) * ((1.0 - oldAO) * 80.0 * pow(wall_distort, 16.0));
	//ALBEDO += redRes; // Flash Red at the end

	vec2 independantUv = vec2((world_position.x + world_position.z), world_position.y) * 0.25;
	vec2 uv = vec2(base_uv.x, 1.0 - base_uv.y);
	//uv = independantUv;
	//vec2 uv2 = vec2(base_uv.x, 1.0 - base_uv.y);

	float t = TIME * 0.5;
	float multiplier = 1.0 + (
		//f(noise, t, independantUv, 0.0, 0.15135) +
		f(noise, t, uv, 10.0, 0.5426) +
		f(noise, t, uv, 20.0, 0.275363) +
		f(noise, t, uv, 30.0, 0.1341) +
		0.0
	);
	ALBEDO *= multiplier;

	vec2 uv2 = vec2(uv.x, 1.0 - min(1.0, uv.y * 0.8));
	ALBEDO *= (1.0 - texture(noise, uv2 + vec2(cos(TIME * 0.15315), sin(TIME * 0.134151)) * 0.01).r * wall_distort * (1.0 - uv2.y) * 0.5);
	ALBEDO *= sqrt(uv2.y * 0.125 * wall_distort + (1.0 - wall_distort));
}
