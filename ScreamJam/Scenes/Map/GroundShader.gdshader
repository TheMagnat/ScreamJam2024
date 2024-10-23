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

global uniform float sanity;
uniform float sanityFactor = 1.0;

varying vec3 world_position;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	
	float time = TIME * breathing * 0.005;

	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Cool
	vec2 uv = vec2(world_position.x + world_position.y, world_position.z) * 0.25;
	float noiseValue = texture(noise, uv * 0.005 + time).r * 1.0;

	VERTEX += NORMAL * noiseValue * (0.01 + sanity * sanityFactor);

	float randValue = texture(noise, vec2(world_position.x, world_position.z + world_position.y) + time).r;
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

		//vec2 p = view_dir.xy * heightmap_scale * 0.01;
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
	
	float randValue = texture(noise, UV * 0.2 + vec2(sin(time) * 0.00001, -0.05) * time).r;
	float modifier = randValue * (0.075 + wall_distort * 0.9) * 0.05;
	vec2 vecModifier = vec2(0.4, 0.0) * modifier;
	base_uv += vecModifier;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

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
}
