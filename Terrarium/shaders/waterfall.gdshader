shader_type spatial;

uniform float metallic = 0.6;
uniform float specular = 0.5;
uniform float roughness = 0.3;
uniform float amount = 1.9;
uniform float speed = 2.0;
uniform vec4 out_color : source_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform float depth_factor = 1.0;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

varying vec2 vertex_uv;

// Helper functions to generate offsets, ensuring smooth wrapping
float generateOffset(float angle, float height, float val1, float val2, float time) {
    float adjustedAngle = mod(angle + val1 * height, amount) / amount;
    float radianOffset = (adjustedAngle + time * speed) * 2.0 * PI;
    return 0.1 * sin(radianOffset); // Reduce amplitude to limit distortion
}

vec3 applyDistortion(vec3 vertex, float time) {
    // Convert vertex position to cylindrical coordinates (theta, y)
    float theta = atan(vertex.x, vertex.z);
    float radius = length(vertex.xz);
    float y = vertex.y;

    // Apply distortions based on cylindrical coordinates
    float radialDist = generateOffset(theta, y, 0.3, 0.15, time);
    float heightDist = generateOffset(theta, y, 0.15, 0.45, time);

    // Ensure theta wraps correctly
    float newTheta = theta + radialDist;
    newTheta = mod(newTheta + PI, 2.0 * PI) - PI; // Correct wrapping around the cylinder

    // Convert back to Cartesian coordinates with controlled distortions
    return vec3(radius * cos(newTheta), y + heightDist, radius * sin(newTheta));
}

void vertex() {
    VERTEX = applyDistortion(VERTEX, TIME * 0.1);
    vertex_uv = UV;
}

void fragment() {
    ALBEDO = out_color.xyz;
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
    METALLIC = metallic;
    SPECULAR = specular;
    ROUGHNESS = roughness;
    
  
}
