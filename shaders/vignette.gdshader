    shader_type canvas_item;

    uniform float alpha = 0.5;
    uniform float inner_radius = 0.5;
    uniform float outer_radius = 1.5;
    uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Default to black

    void fragment() {
        float x = abs(UV.x - 0.5) * 2.0;
        float y = abs(UV.y - 0.5) * 2.0;
        float dist = sqrt(x * x + y * y); // Distance from center

        // Calculate vignette intensity based on radii
        float vignette_intensity = smoothstep(inner_radius, outer_radius, dist);

        // Apply vignette color and alpha
        COLOR = mix(vec4(0.0, 0.0, 0.0, 0.0), vignette_color, vignette_intensity * alpha);
    }