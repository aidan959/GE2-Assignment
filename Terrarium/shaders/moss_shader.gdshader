shader_type spatial;
uniform sampler2D dirt_texture;
uniform sampler2D moss_texture;
uniform sampler2D grass_texture;
uniform sampler2D noise_texture;

uniform float blend_strength;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
