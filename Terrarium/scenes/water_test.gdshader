shader_type spatial;
render_mode blend_mix; // Enable transparency

// Shared uniforms with the water shader
uniform float metallic;
uniform float specular;
uniform float roughness;
uniform float amount; 
uniform float speed;
uniform vec4 out_color; 
uniform float depth_factor;  

// For sampling the water plane's rendered output
uniform sampler2D SCREEN_TEXTURE; 

varying vec2 vertex_uv; 

void vertex() {
    // Adjust the following if your cylinder's placement is different
    VERTEX.y -= 0.1; // Slightly lower the cylinder 
    VERTEX.xz *= 0.95; // Slightly shrink the cylinder horizontally

    // Keep the UVs for texture sampling
    vertex_uv = UV;
}

void fragment() {
    // Sample the textured water from screen coordinates
    vec4 water_color = vec4(0.2, 0.3, 0.8, 1.0); // A soft blue

    // Apply distortion (optional - keep consistent with water shader)
    vec2 distort_uv = vertex_uv; 
    // ... Add distortion logic if you're using it in your main water shader

    water_color = texture(SCREEN_TEXTURE, distort_uv); 

    // Simplified depth effect 
    float depth = 1.2 - VERTEX.y;  // Adjust the 1.2 offset as needed
    float alpha = clamp(1.0 - depth * depth_factor, 0.0, 1.0);

    // Combine with base color of cylinder
    ALBEDO = mix(out_color.xyz, water_color.xyz, 0.5); // Adjust mix ratio
    ALPHA = alpha * water_color.a; // Use water's opacity as well
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness; 
}