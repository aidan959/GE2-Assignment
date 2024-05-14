shader_type spatial;

uniform float intensity : hint_range(0.0, 2.0) = 0.8;
uniform float speed : hint_range(0.0, 5.0) = 0.2;
uniform sampler2D noise_tex; 
uniform int segments = 6; 

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Function to convert RGB to HSV
vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Function to convert HSV to RGB
vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


vec2 rotate_uv(vec2 uv, float angle) {
    uv -= 0.5; // Center the rotation around the middle of the texture
    vec2 col1 = vec2(cos(angle), sin(angle)); // First column of the rotation matrix
    vec2 col2 = vec2(-sin(angle), cos(angle)); // Second column of the rotation matrix
    mat2 rotationMatrix = mat2(col1, col2); // Construct the matrix with two vec2 columns
    uv = rotationMatrix * uv; // Apply the rotation
    uv += 0.5; // Move back to original pivot
    return uv;
}

vec2 kaleidoscope_uv(vec2 uv, int seg) {
    float angle = 2.0 * PI / float(seg);
    float r = length(uv - vec2(0.5));
    float theta = atan(uv.y - 0.5, uv.x - 0.5);
    theta = mod(theta, angle) - angle / 2.0;
    return vec2(cos(theta), sin(theta)) * r + vec2(0.5);
}

void fragment() {
    vec2 uv = UV;

    // Rotate UV coordinates continuously
    float rotation_angle = TIME * speed; 
    uv = rotate_uv(uv, rotation_angle);

    // Apply kaleidoscope effect
    vec2 k_uv = kaleidoscope_uv(uv, segments);
    vec3 col = texture(SCREEN_TEXTURE, k_uv).rgb;
    vec3 hsv = rgb_to_hsv(col);

    float noise = texture(noise_tex, uv).r;
    float hue_offset = mod(noise * intensity + TIME * speed, 1.0);
    hsv.x += hue_offset; // Shift hue

    vec3 rgb = hsv_to_rgb(hsv);
    vec3 final_color = mix(col, rgb, hsv.y); // Mix based on saturation

    ALBEDO = final_color;
    ALPHA = 0.5; 
}
