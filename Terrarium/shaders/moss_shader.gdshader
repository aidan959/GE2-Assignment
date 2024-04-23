shader_type spatial;
uniform sampler2D dirt_texture;
uniform sampler2D dirt_normal_texture;

uniform sampler2D moss_texture;
uniform sampler2D moss_normal_texture;

uniform sampler2D grass_texture;
uniform sampler2D noise_texture;

uniform float blend_strength;
void vertex() {
	vec2 uv = VERTEX.xy / vec2(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y);
	
	float noise = texture(noise_texture, uv).r;	
	vec4 dirt_normal = texture(dirt_normal_texture, UV);
    vec4 moss_normal = texture(moss_normal_texture, UV);
	// Called for every vertex the material is visible on.
    NORMAL = mix(dirt_normal, moss_normal, noise).rgb * 100.0;
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = FRAGCOORD.xy / vec2(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y);
	float noise = texture(noise_texture, uv).r;
	    // Sample textures
    vec4 dirt_color = texture(dirt_texture, UV);
    vec4 moss_color = texture(moss_texture, UV);

    vec4 grass_color = texture(grass_texture, UV);
	vec4 final_color = mix(dirt_color, moss_color, noise);
    //final_color = mix(final_color, grass_color, noise);
	ALBEDO = final_color.rgb;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
