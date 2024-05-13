shader_type spatial;
render_mode blend_mix;

// https://godotshaders.com/shader/low-poly-water/

uniform float metallic = 0.6;
uniform float specular = 0.5;
uniform float roughness = 0.3;
uniform float amount = 0.9;
uniform float speed = 1.0;
// Water color
uniform vec4 out_color: source_color = vec4(0.0, 0.2, 1.0, 0.8);
uniform float depth_factor = 0.0;

// Vertex shader variables
varying vec2 vertex_uv;
uniform float circle_radius = 0.5; // radius of terrarium
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

float generateOffset(float x, float z, float val1, float val2, float time) {
	float absX = abs(x); 
    float radiansX = ((mod(absX + z * absX * val1, amount) / amount) + (time * speed) * mod(absX * 0.8 + z, 1.5)) * 2.0 * PI;
    float radiansZ = ((mod(val2 * (z * absX + absX * z), amount) / amount) + (time * speed) * 2.0 * mod(absX, 2.0)) * 2.0 * PI;
    return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time) {
	float xd = generateOffset(vertex.x, vertex.z, 0.3, 0.15, time);
    float yd = generateOffset(vertex.x, vertex.z, 0.15, 0.45, time);
    float zd = generateOffset(vertex.x, vertex.z, 0.225, 0.3, time); 
    return vertex + vec3(xd, yd, zd);
}

void vertex(){
	VERTEX = applyDistortion(VERTEX, TIME * 0.1);
	vertex_uv = UV; // Pass UV to fragment shader
}

void fragment() {
	vec2 center = vec2(0.5, 0.5); // UV coordinates at center
    if (distance(vertex_uv, center) > circle_radius) {
        discard; // Dispose fragments outside of radius
    }
	
	ALBEDO = out_color.xyz;
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	ALPHA = out_color.a;
	
	//float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	//depth = depth * 2.0 - 1.0;
	//depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	//depth = depth + VERTEX.z;
//
	//float linear_depth = clamp(1.0 - depth, 0.0, 1.0);
	//ALPHA = clamp(1.0 - linear_depth * depth_factor, 0.0, 1.0); 
}
