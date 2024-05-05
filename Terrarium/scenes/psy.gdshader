shader_type spatial;

// Uniforms for controlling the effect
uniform float intensity = 0.5;
uniform float speed = 0.1;
uniform sampler2D noise_texture;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Helper function to convert RGB to HSV
vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Helper function to convert HSV to RGB
vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // Get the current pixel color in RGB
    vec4 current_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Convert RGB to HSV
    vec3 hsv = rgb_to_hsv(current_color.rgb);

    // Calculate hue offset using Perlin noise
    float noise_value = texture(noise_texture, SCREEN_UV).r;
    float time_factor = TIME * speed;
    float hue_offset = mod(noise_value * intensity + time_factor, 1.0);

    // Shift hue by the calculated offset
    hsv.x += hue_offset; // Hue is the x component in HSV

    // Wrap around hue if it exceeds 1
    if (hsv.x > 1.0) hsv.x -= 1.0;

    // Convert HSV back to RGB
    vec3 new_color = hsv_to_rgb(hsv);

    // Mix the new color with the original color based on alpha for partial transparency
    vec3 final_color = mix(current_color.rgb, new_color, 0.7); // 0.7 is the blend factor for partial transparency

    // Output the final color and alpha
    ALBEDO = final_color;
    ALPHA = current_color.a;
}
