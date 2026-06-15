shader_type canvas_item; // For 2D, or spatial for 3D

uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red tint
uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV); // Get the original pixel color
    
    // Mix the original color with the tint color based on strength
    vec3 mixed_rgb = mix(original_color.rgb, tint_color.rgb, tint_strength);
    
    COLOR = vec4(mixed_rgb, original_color.a); // Set the final color
}
